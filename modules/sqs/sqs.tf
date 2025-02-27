

module "priority_queues" {
  count  = 3
  source  = "terraform-aws-modules/sqs/aws"
  version = "4.2.1"
  name = "priority_queue-${count.index}"

  create_dlq = true
  message_retention_seconds= var.priority_settings[count.index].message_retention_seconds
  visibility_timeout_seconds= var.priority_settings[count.index].visibility_timeout_seconds
  fifo_queue= var.priority_settings[count.index].fifo

  redrive_policy = {
        maxReceiveCount = 2
    }

  tags = {
    Environment = "dev"
  }
}
