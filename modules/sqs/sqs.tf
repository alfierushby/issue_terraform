locals {
    settings = [var.priority_1_settings,var.priority_2_settings,var.priority_3_settings]
}

module "priority_queues" {
  count  = 3
  source  = "terraform-aws-modules/sqs/aws"
  version = "4.2.1"
  name = "priority_queue-${count.index}"

  create_dlq = true
  message_retention_seconds= local.settings[count.index].message_retention_seconds
  visibility_timeout_seconds= local.settings[count.index].visibility_timeout_seconds
  fifo_queue= local.settings[count.index].fifo

  redrive_policy = {
        maxReceiveCount = 2
    }

  tags = {
    Environment = "dev"
  }
}

data "aws_iam_policy_document" "sqs" {
  statement {
    actions   = ["sqs:ListQueues"]
    resources = ["*"]
    effect = "Allow"
  }
   statement {
    actions   = ["sqs:SendMessage","sqs:ReceiveMessage","sqs:DeleteMessage","sqs:GetQueueAttributes"]
    resources = module.priority_queues[*].queue_arn
    effect = "Allow"
  }
}

resource "aws_iam_policy" "sqs" {
  name        = "SQS-Access"
  description = "Grants access to SQS queues."
  policy = data.aws_iam_policy_document.sqs.json
}
