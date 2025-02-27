variable sqs_queue_arns {
    description = "Arns of the queues in a list"
    type = list(string)
}

variable oidc_provider_arn{
    description = "ARN of the oidc provider for EKS"
    type = string
}