resource "aws_lambda_event_source_mapping" "this" {
  enabled          = var.enabled
  event_source_arn = var.sqs.arn
  function_name    = var.lambda.arn

  batch_size                         = var.batch_size
  maximum_batching_window_in_seconds = var.maximum_batching_window_in_seconds
  function_response_types            = var.partial_batch_failures ? ["ReportBatchItemFailures"] : null

  dynamic "filter_criteria" {
    for_each = var.filter_criteria != null ? [var.filter_criteria] : []
    content {
      dynamic "filter" {
        for_each = filter_criteria.value
        content {
          pattern = filter.value
        }
      }
    }
  }

  lifecycle {
    precondition {
      #  https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html#events-sqs-eventsource
      condition     = local.skip_visibility_timeout_check || var.sqs.visibility_timeout_seconds >= (var.lambda.timeout + local.effective_batching_window_in_seconds + var.visibility_timeout_tolerance)
      error_message = "Invalid visibility timeout; should be at least >= lambda.timeout + maximum_batching_window_in_seconds + ${var.visibility_timeout_tolerance}."
    }
  }
}
locals {
  skip_visibility_timeout_check        = var.ignore_visibility_timeout || var.sqs.visibility_timeout_seconds == null
  effective_batching_window_in_seconds = var.maximum_batching_window_in_seconds == null ? 0 : var.maximum_batching_window_in_seconds
}
