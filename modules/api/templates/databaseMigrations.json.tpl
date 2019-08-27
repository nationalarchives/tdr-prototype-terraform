[
    {
        "name": "${container_name}",
        "image": "${image_id}",
        "cpu": 0,
        "secrets": [
            {
                "valueFrom": "${db_url_param}",
                "name": "DB_URL"
            },
            {
                "valueFrom": "${db_username_param}",
                "name": "DB_USERNAME"
            },
            {
                "valueFrom": "${db_password_param}",
                "name": "DB_PASSWORD"
            }
        ],
        "networkMode": "awsvpc",
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "/ecs/tdr-db-migrations-${app_environment}",
                "awslogs-region": "${aws_region}",
                "awslogs-stream-prefix": "ecs"
            }
        }
    }
]
