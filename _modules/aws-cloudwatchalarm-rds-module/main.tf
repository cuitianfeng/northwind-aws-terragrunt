terraform {
  experiments = [module_variable_optional_attrs]
}

resource "aws_cloudwatch_metric_alarm" "disk_alarm" {
  count            = length(local.values.db_instances)
  alarm_name       = "DiskSpaceAlarm-${element(local.values.db_instances, count.index)}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = local.values.period
  statistic           = "Average"
  threshold           = local.values.threshold
  alarm_description   = "Alarm when free disk space is less than 10%"
  alarm_actions       = [local.values.topic_arn]
  dimensions = {
    DBInstanceIdentifier = element(local.values.db_instances, count.index)
  }
}