provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  default_tags {
    tags = {
      Environment = "Testing"
      managed_by  = "Terraform"
      Cost_Tag    = "AlfiesIssueCreator"
      Project     = "AlfiesIssueCreator"
    }
  }
}