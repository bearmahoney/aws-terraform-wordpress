resource "aws_sns_topic" "healthy_hosts_alarm" {
  name            = "healthy-hosts-alarm"
  delivery_policy = jsonencode({
    "http" : {
      "defaultHealthyRetryPolicy" : {
        "minDelayTarget" : 20,
        "maxDelayTarget" : 20,
        "numRetries" : 3,
        "numMaxDelayRetries" : 0,
        "numNoDelayRetries" : 0,
        "numMinDelayRetries" : 0,
        "backoffFunction" : "linear"
      },
      "disableSubscriptionOverrides" : false,
      "defaultThrottlePolicy" : {
        "maxReceivesPerSecond" : 1
      }
    }
  })
}

resource "aws_sns_topic_subscription" "healthy_hosts_alarm_email_sub" {
  count     = 1
  topic_arn = aws_sns_topic.healthy_hosts_alarm.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

