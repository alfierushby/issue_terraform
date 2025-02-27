variable "priority_settings" {
  description = "Configuration for priority queues in a list."
  type = list(object({
    fifo     = optional(bool, false)
    message_retention_seconds    = optional(number, 345600)
    visibility_timeout_seconds = optional(number, 30)
  }))
  default = [{},{},{}]
}
