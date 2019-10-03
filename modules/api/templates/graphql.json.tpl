[
  {
    "name": "sangria-graphql",
    "image": "${app_image}",
    "cpu": 0,
    "environment": [
      {
        "value": "${export_task_id}",
        "name": "EXPORT_TASK_ID"
      },
      {
        "value": "${export_cluster_arn}",
        "name": "EXPORT_CLUSTER_ARN"
      },
      {
        "value": "${export_subnet_id}",
        "name": "EXPORT_SUBNET_ID"
      },
      {
        "value": "${export_security_group_id}",
        "name": "EXPORT_SECURITY_GROUP_ID"
      },
      {
        "value": "${export_container_id}",
        "name": "EXPORT_CONTAINER_ID"
      }
    ],
    "secrets": [
      {
        "valueFrom": "${url_path}",
        "name": "DB_URL"
      },
      {
        "valueFrom": "${username_path}",
        "name": "DB_USERNAME"
      },
      {
        "valueFrom": "${password_path}",
        "name": "DB_PASSWORD"
      }
    ],
    "networkMode": "awsvpc",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/tdr-graphql-${app_environment}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "portMappings": [
      {
        "containerPort": ${app_port},
      "hostPort": ${app_port}
    }
    ]
  }
]
