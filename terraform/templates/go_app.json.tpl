[
  {
    "name": "go-app",
    "image": "${docker_image_url}",
    "essential": true,
    "cpu": 10,
    "memory": 512,
    "links": [],
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 0,
        "protocol": "tcp"
      }
    ],
    "command": ["go-app"],
    "environment": [],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/go-app/${app_env}",
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "go-app-log-stream-${app_env}"
      }
    }
  }
]