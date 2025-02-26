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

variable "cidr_block"{
    description = "CIDR block of subnets"
    type = string
    default = "10.0.0.0/16"
}