
resource "aws_ecs_cluster" "n8n_cluster" {
  name = "n8n-deploy-cluster-ecs"
}

resource "aws_lb" "n8n_alb" {
  name               = "n8n-alb-task"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-00fc9a4a0bab615ff"]
  subnets = [
    "subnet-03717330c5353e44d",
    "subnet-0485d7f3414eb5277",
    "subnet-09b307391bb7a25f1",
    "subnet-0715d416cf63cc9c8",
    "subnet-0a2fa8fe3cf159e15",
    "subnet-0eb40e410749ac073"
  ]

}

resource "aws_lb_target_group" "n8n_tg" {
  name     = "n8n-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-07f043fc0578d979f"
  target_type = "ip"
  ip_address_type = "ipv4"

  health_check {
    path                = "/healthz"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}



resource "aws_lb_listener" "n8n_listener_http_alb" {
  load_balancer_arn = aws_lb.n8n_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "n8n_listener_https_alb" {
  load_balancer_arn = aws_lb.n8n_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:211125482456:certificate/ee4dc070-f4bf-4816-945b-45ea521a141b"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.n8n_tg.arn
  }
}

resource "aws_ecs_service" "n8n_service_deploy" {
  name            = "n8n-service"
  cluster         = aws_ecs_cluster.n8n_cluster.id
  task_definition = aws_ecs_task_definition.n8n_task_ecs.arn
  desired_count   = 1

  launch_type = "FARGATE"

  network_configuration {
    subnets = [
      "subnet-04a674f0c70cca070",
      "subnet-0aefd46b412f1e5a1",
      "subnet-03717330c5353e44d",
      "subnet-0485d7f3414eb5277",
      "subnet-060534689fac11b28",
      "subnet-09b307391bb7a25f1",
      "subnet-042d8e9a13640540e",
      "subnet-0715d416cf63cc9c8",
      "subnet-0a2fa8fe3cf159e15",
      "subnet-0eb40e410749ac073",
      "subnet-038cf15cbfe413dd7"
    ]
    security_groups  = ["sg-0685b31823b439f6f"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.n8n_tg.arn
    container_name   = "n8n-container"
    container_port   = 5678
  }
}



