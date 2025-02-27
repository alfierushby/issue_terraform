provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Environment = "Testing"
      managed_by  = "Terraform"
      Cost_Tag    = "AlfiesIssueCreator"
      Project     = "AlfiesIssueCreator"
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
