module "vpc" {
  source       = "./modules/vpc"
  region       = var.region
  cluster_name = module.eks.cluster_name
}

module "iam" {
  source         = "./modules/iam"
  sqs_queue_arns = module.sqs.sqs_queue_arns
  oidc_provider_arn = module.eks.oidc_provider_arn
}

module "sqs" {
  source = "./modules/sqs"
}

module "eks" {
  source             = "./modules/eks"
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  intra_subnet_ids   = module.vpc.intra_subnet_ids
  vpc_id             = module.vpc.vpc_id
  ebs_csi_role_arn   = module.iam.ebs_csi_role_arn
  ecr_read_policy_arn = module.iam.ecr_read_policy
}