variable "sqs" {
  type = object({
    name                       = optional(string)
    name_prefix                = optional(string)
    arn                        = string
    fifo_queue                 = optional(bool)
    kms_master_key_id          = optional(string)
    visibility_timeout_seconds = optional(number)
  })
}

variable "lambda" {
  type = object({
    arn     = string
    role    = string
    timeout = optional(number)
  })
}

variable "batch_size" {
  type    = number
  default = 1
}

variable "filter_criteria" {
  type = list(
    object({
      filter = object({
        pattern = any
      })
    })
  )
  default = null
}

variable "disable_inline_policy_attachment" {
  type    = bool
  default = false
}

variable "partial_batch_failures" {
  type    = bool
  default = true
}

variable "maximum_batching_window_in_seconds" {
  type    = number
  default = null
}

variable "ignore_visibility_timeout" {
  type    = bool
  default = false
}

variable "visibility_timeout_tolerance" {
  type    = number
  default = 30
  validation {
    condition     = var.visibility_timeout_tolerance >= 0
    error_message = "Should be a non-negative number."
  }
}
