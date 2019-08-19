[
    {
        "name": "${container_name}",
        "image": "${virus_check_image}:${app_environment}",
        "cpu": 0,
        "secrets": [
            {
                "valueFrom": "/${app_environment}/ACCESS_KEY_ID",
                "name": "AWS_ACCESS_KEY_ID"
            },
            {
                "valueFrom": "/${app_environment}/SECRET_ACCESS_KEY",
                "name": "AWS_SECRET_ACCESS_KEY"
            },
            {
                "valueFrom": "/${app_environment}/DEFAULT_REGION",
                "name": "AWS_DEFAULT_REGION"
            },
            {
                "valueFrom": "/${app_environment}/S3_UPLOAD_BUCKET",
                "name": "S3_UPLOAD_BUCKET"
            }
        ],        
        "networkMode": "awsvpc",
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "/ecs/tdr-virus-check-${app_environment}",
                "awslogs-region": "${aws_region}",
                "awslogs-stream-prefix": "ecs"
            }
        }
    }
]