variable "region" {
  description = "Region of AWS"
  type        = string
  default     = "eu-north-1"
  validation {
    condition     = length(var.region) > 0
    error_message = "Region key cannot be empty"
  }
  validation {
    condition     = var.region == "eu-north-1"
    error_message = "Region key must be eu-north-1"
  }
}

variable cluster_name{
    description = "Cluster name of EKS cluster"
    type = string
    default = "alfie-issue-creator-cluster"
}