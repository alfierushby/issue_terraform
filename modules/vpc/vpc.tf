locals{
  az_count = length(data.aws_availability_zones.available.names) > 2 ? 3 : 2
  private_subnets = [for index in range(local.az_count):
             cidrsubnet(var.cidr_block, 4, index)]
  public_subnets = [for index in range(local.az_count):
             cidrsubnet(var.cidr_block, 8, index+48)]
  intra_subnets = [for index in range(local.az_count):
             cidrsubnet(var.cidr_block, 8, index+54)]
}

data "aws_availability_zones" "available" {
  state = "available"
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "alfie-vpc"
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names,0,3)
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets
  intra_subnets = local.intra_subnets

  enable_nat_gateway = true
  enable_dns_hostnames = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = 1
    Name                     = "${var.cluster_name}-public"
  }
  private_subnet_tags ={
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
    Name                     = "${var.cluster_name}-private"
  }
  intra_subnet_tags = {
    Name = "${var.cluster_name}-intra"
  }
}

module "internal_sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name        = "internal"
  description = "Allow all internal ping traffic"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = [var.cidr_block]
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 65535
      protocol    = "tcp"
      description = "Allows internal TCP communication"
      cidr_blocks = var.cidr_block
    },
    {
      from_port   = 80
      to_port     = 65535
      protocol    = "udp"
      description = "User-service ports"
      cidr_blocks = var.cidr_block
    },
    {
      rule        = "all-icmp"
      cidr_blocks = var.cidr_block
    },
  ]
  egress_rules = ["http-80-tcp","https-443-tcp"]
}
