module "vpc" {
  source = "./modules/vpc"
  region = var.region
}

module "iam" {
  source = "./modules/iam"
  sqs_policy_arn = module.sqs.sqs_policy_arn
}

module "sqs"{
    source = "./modules/sqs"
}