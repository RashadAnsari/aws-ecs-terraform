resource "aws_iam_role" "ecs_host_role" {
  name               = "ecs-host-role"
  assume_role_policy = file("policies/ecs-role.json")
}

resource "aws_iam_role_policy" "ecs_instance_role_policy" {
  name   = "ecs-instance-role-policy"
  policy = file("policies/ecs-instance-role-policy.json")
  role   = aws_iam_role.ecs_host_role.id
}

resource "aws_iam_role" "ecs_service_role" {
  name               = "ecs-service-role"
  assume_role_policy = file("policies/ecs-role.json")
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name   = "ecs-service-role-policy"
  policy = file("policies/ecs-service-role-policy.json")
  role   = aws_iam_role.ecs_service_role.id
}

resource "aws_iam_instance_profile" "ecs" {
  name = "ecs-instance-profile"
  path = "/"
  role = aws_iam_role.ecs_host_role.name
}