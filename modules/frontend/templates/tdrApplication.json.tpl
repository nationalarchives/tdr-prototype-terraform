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
                "valueFrom": "/${app_environment}/AUTHENTICATOR_SIGNER_KEY",
                "name": "AUTHENTICATOR_SIGNER_KEY"
            },
            {
                "valueFrom": "/${app_environment}/AUTHENTICATOR_CRYPTER_KEY",
                "name": "AUTHENTICATOR_CRYPTER_KEY"
            },
            {
                "valueFrom": "/${app_environment}/CSRF_SIGNER_KEY",
                "name": "CSRF_SIGNER_KEY"
            },
            {
                "valueFrom": "/${app_environment}/SOCIAL_STATE_SIGNER_KEY",
                "name": "SOCIAL_STATE_SIGNER_KEY"
            },
            {
                "valueFrom": "/${app_environment}/COGNITO_CLIENT_ID",
                "name": "COGNITO_CLIENT_ID"
            },
            {
                "valueFrom": "/${app_environment}/COGNITO_CLIENT_SECRET",
                "name": "COGNITO_CLIENT_SECRET"
            },
            {
                "valueFrom": "/${app_environment}/COGNITO_UPLOAD_CLIENT_ID",
                "name": "COGNITO_UPLOAD_CLIENT_ID"
            },
            {
                "valueFrom": "/${app_environment}/USER_DB_ENDPOINT",
                "name": "USER_DB_ENDPOINT"
            },
            {
                "valueFrom": "/${app_environment}/USER_DB_USERS_TABLE",
                "name": "USER_DB_USERS_TABLE"
            },
            {
                "valueFrom": "/${app_environment}/USER_DB_TOKENS_TABLE",
                "name": "USER_DB_TOKENS_TABLE"
            },
            {
                "valueFrom": "/${app_environment}/TDR_BASE_PATH",
                "name": "TDR_BASE_PATH"
            },
            {
                "valueFrom": "/${app_environment}/TDR_AUTH_PATH",
                "name": "TDR_AUTH_PATH"
            },
            {
                "valueFrom": "/${app_environment}/TDR_GRAPHQL_URI",
                "name": "TDR_GRAPHQL_URI"
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
