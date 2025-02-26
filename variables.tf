variable "access_key" {
  description = "Access Key for AWS"
  type        = string
  default     = ""
  validation {
    condition     = length(var.access_key) > 0
    error_message = "Access key cannot be empty"
  }
}

variable "secret_key" {
  description = "Secret Key for AWS"
  type        = string
  default     = ""
  validation {
    condition     = length(var.secret_key) > 0
    error_message = "Secret key cannot be empty"
  }
}

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