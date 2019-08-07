resource "aws_sns_topic" "checksum_check_result" {
  name = "checksum-check-result-${var.environment}"
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false
  }
}
EOF
  tags = merge(
  var.common_tags,
  map(
  "Name", "checksum-check-result-topic-${var.environment}",
  )
  )
}