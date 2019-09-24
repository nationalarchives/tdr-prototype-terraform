[
    {
        "name": "tdr-application",
        "image": "${app_image}:${app_environment}",
        "cpu": 0,
        "secrets": [
            {
                "valueFrom": "/${app_environment}/ACCESS_KEY_ID",
                "name": "ACCESS_KEY_ID"
            },
            {
                "valueFrom": "/${app_environment}/SECRET_ACCESS_KEY",
                "name": "SECRET_ACCESS_KEY"
            },
            {
                "valueFrom": "/${app_environment}/PLAY_SECRET_KEY",
                "name": "PLAY_SECRET_KEY"
            },
            {
                "valueFrom": "/${app_environment}/TDR_GRAPHQL_URI",
                "name": "TDR_GRAPHQL_URI"
            },
            {
                "valueFrom": "/${app_environment}/USER_DB_ENDPOINT",
                "name": "USER_DB_ENDPOINT"
            }
        ],
        "environment" : [
            {
                "value": "${app_environment}",
                "name": "ENVIRONMENT"
            }
        ],
        "networkMode": "awsvpc",
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "/ecs/tdr-application-${app_environment}",
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