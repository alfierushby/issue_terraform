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