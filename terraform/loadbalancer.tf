resource "aws_lb" "main" {
  name               = "alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public.*.id
}

resource "aws_alb_target_group" "default_target_group" {
  name     = "alb-default-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/health"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 6
    interval            = 30
    matcher             = "200-399"
  }
}

# resource "aws_lb_listener" "redirect" {
#   load_balancer_arn = aws_lb.main.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type = "redirect"

#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }

resource "aws_alb_listener" "ecs_alb_http_listener" {
  load_balancer_arn = aws_lb.main.id
  port              = "80"
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = ""
  depends_on = [aws_alb_target_group.default_target_group]

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.default_target_group.arn
  }
}
