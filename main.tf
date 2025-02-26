module "vpc" {
  source = "./modules/vpc"
  region = var.region
  cluster_name = module.eks.cluster_name
}

module "iam" {
  source = "./modules/iam"
  sqs_policy_arn = module.sqs.sqs_policy_arn
}

module "sqs"{
    source = "./modules/sqs"
}

module "eks" {
  source = "./modules/eks"
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids = module.vpc.public_subnet_ids
  intra_subnet_ids = module.vpc.intra_subnet_ids
  vpc_id = module.vpc.vpc_id
}