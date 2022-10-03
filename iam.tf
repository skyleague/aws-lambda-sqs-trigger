data "aws_iam_policy_document" "subscribe" {
  count = var.disable_inline_policy_attachment ? 0 : 1
  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ChangeMessageVisibility",
    ]
    resources = [var.sqs.arn]
  }

  # https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-key-management.html
  dynamic "statement" {
    for_each = var.sqs.kms_master_key_id != null && var.sqs.kms_master_key_id != "alias/aws/sqs" ? [var.sqs.kms_master_key_id] : []
    content {
      effect = "Allow"
      actions = [
        "kms:Decrypt",
      ]
      resources = [var.sqs.kms_master_key_id]
    }
  }
}

data "aws_arn" "role" {
  count = var.disable_inline_policy_attachment ? 0 : 1
  arn   = var.lambda.role
}
locals {
  role_parts = split("/", try(data.aws_arn.role[0].resource, ""))
  role_name  = element(local.role_parts, length(local.role_parts) - 1)
}

resource "aws_iam_role_policy" "subscribe" {
  count = var.disable_inline_policy_attachment ? 0 : 1

  role        = local.role_name
  name_prefix = "${coalesce(var.sqs.name_prefix, var.sqs.name)}-subscribe"
  policy      = data.aws_iam_policy_document.subscribe[count.index].json
}
