[
    {
        "name": "tdr-application",
        "image": "${app_image}",
        "cpu": 0,
        "secrets": [
            {
                "valueFrom": "ACCESS_KEY_ID",
                "name": "ACCESS_KEY_ID"
            },
            {
                "valueFrom": "SECRET_ACCESS_KEY",
                "name": "SECRET_ACCESS_KEY"
            },
            {
                "valueFrom": "PLAY_SECRET_KEY",
                "name": "PLAY_SECRET_KEY"
            },
            {
                "valueFrom": "AUTHENTICATOR_SIGNER_KEY",
                "name": "AUTHENTICATOR_SIGNER_KEY"
            },
            {
                "valueFrom": "AUTHENTICATOR_CRYPTER_KEY",
                "name": "AUTHENTICATOR_CRYPTER_KEY"
            },
            {
                "valueFrom": "CSRF_SIGNER_KEY",
                "name": "CSRF_SIGNER_KEY"
            },
            {
                "valueFrom": "SOCIAL_STATE_SIGNER_KEY",
                "name": "SOCIAL_STATE_SIGNER_KEY"
            },
            {
                "valueFrom": "COGNITO_CLIENT_ID",
                "name": "COGNITO_CLIENT_ID"
            },
            {
                "valueFrom": "COGNITO_CLIENT_SECRET",
                "name": "COGNITO_CLIENT_SECRET"
            },
            {
                "valueFrom": "COGNITO_UPLOAD_CLIENT_ID",
                "name": "COGNITO_UPLOAD_CLIENT_ID"
            },
            {
                "valueFrom": "USER_DB_ENDPOINT",
                "name": "USER_DB_ENDPOINT"
            },
            {
                "valueFrom": "USER_DB_USERS_TABLE",
                "name": "USER_DB_USERS_TABLE"
            },
            {
                "valueFrom": "USER_DB_TOKENS_TABLE",
                "name": "USER_DB_TOKENS_TABLE"
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