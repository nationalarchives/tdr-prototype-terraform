resource "aws_sns_topic" "virus_check_result" {
  name = "virus-check-result-${var.environment}"
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
      "Name", "virus-check-result-topic-${var.environment}",
    )
  )
}

resource "aws_sns_topic_subscription" "send_virus_check_result" {
  topic_arn = aws_sns_topic.virus_check_result.arn
  protocol = "lambda"
  #Temp endpoint to set up subscription. Needs to be correct endpoint
  endpoint = "arn:aws:lambda:eu-west-2:247222723249:function:send-result-to-graphql"  
}