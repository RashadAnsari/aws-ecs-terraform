# resource "aws_autoscaling_group" "ecs_cluster" {
#   name                 = "${var.app_name}_auto_scaling_group_${var.app_env}"
#   min_size             = var.autoscale_min
#   max_size             = var.autoscale_max
#   desired_capacity     = var.autoscale_desired
#   health_check_type    = "EC2"
#   launch_configuration = aws_launch_configuration.ecs.name
#   vpc_zone_identifier  = aws_subnet.private.*.id
# }
