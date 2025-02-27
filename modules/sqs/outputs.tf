output sqs_queue_arns {
    description = "Arns of the queues in a list"
    value = module.priority_queues[*].queue_arn
}