resource "aws_cloudwatch_metric_alarm" "nlb_healthyhosts" {
  alarm_name          = "healthy-hosts-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/NetworkELB"
  period              = "60"
  statistic           = "Average"
  threshold           = var.webserver_count
  alarm_description   = "Number of healthy nodes in Target Group"
  actions_enabled     = "true"
  alarm_actions       = [aws_sns_topic.healthy_hosts_alarm.arn]
  ok_actions          = [aws_sns_topic.healthy_hosts_alarm.arn]
  dimensions = {
    TargetGroup  = aws_lb_target_group.front_end_443.arn_suffix
    LoadBalancer = aws_lb.front_end.arn_suffix
  }
}
