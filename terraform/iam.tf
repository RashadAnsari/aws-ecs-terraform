resource "aws_iam_role" "ecs_host_role" {
  name               = "${var.app_name}-ecs-host-role-${var.app_env}"
  assume_role_policy = file("policies/ecs-role.json")
}

resource "aws_iam_role_policy" "ecs_instance_role_policy" {
  name   = "${var.app_name}-ecs-instance-role-policy-${var.app_env}"
  policy = file("policies/ecs-instance-role-policy.json")
  role   = aws_iam_role.ecs_host_role.id
}

resource "aws_iam_role" "ecs_service_role" {
  name               = "${var.app_name}-ecs-service-role-${var.app_env}"
  assume_role_policy = file("policies/ecs-role.json")
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name   = "${var.app_name}-ecs-service-role-policy-${var.app_env}"
  policy = file("policies/ecs-service-role-policy.json")
  role   = aws_iam_role.ecs_service_role.id
}

resource "aws_iam_instance_profile" "ecs" {
  name = "${var.app_name}-ecs-instance-profile-${var.app_env}"
  path = "/"
  role = aws_iam_role.ecs_host_role.name
}
