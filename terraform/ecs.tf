resource "aws_ecr_repository" "app" {
  name = "${var.app_name}-${var.app_env}"
}

resource "aws_ecs_cluster" "app" {
  name = "${var.app_name}-cluster-${var.app_env}"
}

resource "aws_launch_configuration" "ecs" {
  name                        = aws_ecs_cluster.app.name
  image_id                    = var.aws_ami
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.ecs.id]
  iam_instance_profile        = aws_iam_instance_profile.ecs.name
  key_name                    = aws_key_pair.main.key_name
  associate_public_ip_address = true
}

resource "aws_ecs_task_definition" "app" {
  family = "${var.app_name}-${var.app_env}"
  container_definitions = templatefile("templates/go_app.json.tpl", {
    region           = var.region
    docker_image_url = var.docker_image_url
    app_env          = var.app_env
  })
}

resource "aws_ecs_service" "app" {
  name            = "${var.app_name}-service-${var.app_env}"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.app.arn
  iam_role        = aws_iam_role.ecs_service_role.arn
  desired_count   = var.app_count

  depends_on = [aws_alb_listener.ecs_alb_http_listener, aws_iam_role_policy.ecs_service_role_policy]

  load_balancer {
    target_group_arn = aws_alb_target_group.tg.arn
    container_name   = var.app_name
    container_port   = var.app_port
  }
}
