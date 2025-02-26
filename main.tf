module "vpc" {
  source = "./modules/vpc"
  region = var.region
}

module "iam" {
  source = "./modules/iam"

}