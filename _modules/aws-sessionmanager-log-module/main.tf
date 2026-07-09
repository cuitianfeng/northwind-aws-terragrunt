
terraform {
  experiments = [module_variable_optional_attrs]
}


resource "aws_cloudwatch_log_group" "session_manager_log_group" {
  name = "/aws/systems-manager/session-logs"  # 日志组名称，你可以自定义

  retention_in_days = 30  # 日志保留时间，根据需要进行调整
}

resource "aws_ssm_document" "session_manager_prefs" {
  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Document to hold regional settings for Session Manager"
    sessionType   = "Standard_Stream"
    inputs = {
      cloudWatchLogGroupName      = aws_cloudwatch_log_group.session_manager_log_group.name
      cloudWatchStreamingEnabled  = true
    
      shellProfile = {
        linux   = ""
        windows = ""
      }
    }
  })
}



