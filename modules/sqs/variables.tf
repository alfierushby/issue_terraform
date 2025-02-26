variable "priority_1_settings" {
  description = "Configuration for priority queue 1."
  type = object({
    fifo     = optional(bool, false)
    message_retention_seconds    = optional(number, 345600)
    visibility_timeout_seconds = optional(number, 30)
  })
  default = {}
}

variable "priority_2_settings" {
  description = "Configuration for priority queue 2."
  type = object({
    fifo     = optional(bool, false)
    message_retention_seconds    = optional(number, 345600)
    visibility_timeout_seconds = optional(number, 30)
  })
  default = {}
}


variable "priority_3_settings" {
  description = "Configuration for priority queue 3."
  type = object({
    fifo     = optional(bool, false)
    message_retention_seconds    = optional(number, 345600)
    visibility_timeout_seconds = optional(number, 30)
  })
  default = {}
}
