output sqs_policy_arn {
    description = "ARN for the SQS policy"
    value = aws_iam_policy.sqs.arn
}