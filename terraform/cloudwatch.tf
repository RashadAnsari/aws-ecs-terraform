resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/ecs/${var.app_name}/${var.app_env}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = "${var.app_name}-log-stream-${var.app_env}"
  log_group_name = aws_cloudwatch_log_group.log_group.name
}
