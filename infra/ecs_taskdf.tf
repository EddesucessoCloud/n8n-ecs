resource "aws_ecs_task_definition" "n8n_task_ecs" {
  family                   = "n8n-deploy-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"      
  memory                   = "3072"      
  execution_role_arn       = "arn:aws:iam::211125482456:role/ecsTaskExecutionRole"


  container_definitions = jsonencode([
    {
      name      = "n8n-container"
      image     = "n8nio/n8n:latest"
      essential = true
      portMappings = [
        {
          containerPort = 5678
          protocol      = "tcp"
          appProtocol   = "http"
          name = "n8n-port"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/n8n-deploy-task"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }

    }
  ])

  volume {
    name = "n8n_efs_volume"

    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.n8n_efs.id
      transit_encryption      = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.n8n_efs_ap.id
        iam             = "DISABLED"
      }
    }
  }
}
