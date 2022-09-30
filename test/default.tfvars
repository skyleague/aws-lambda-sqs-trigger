sqs = {
  arn                        = "some-sqs"
  fifo_queue                 = false
  kms_master_key_id          = "some-kms"
  visibility_timeout_seconds = 60
}
lambda = {
  arn     = "some-lambda"
  role    = "some-role"
  timeout = 30
}
