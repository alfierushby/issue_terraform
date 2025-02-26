locals{
  az_count = length(data.aws_availability_zones.available.names) > 2 ? 3 : 2
  private_subnets = [for index in range(local.az_count):
             cidrsubnet(var.cidr_block, 8, index)]
  public_subnets = [for index in range(local.az_count):
             cidrsubnet(var.cidr_block, 8, index+local.az_count)]
  infra_subnets = [for index in range(local.az_count):
             cidrsubnet(var.cidr_block, 8, index+local.az_count*2)]
}

data "aws_availability_zones" "available" {
  state = "available"
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available.names
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets
  intra_subnets = local.infra_subnets

  enable_nat_gateway = false
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
  private_subnet_tags ={
    "kubernetes.io/role/internal-elb" = 1
  }
}

module "internal_sg" {
  source = "terraform-aws-modules/security-group/aws"

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
