[
    {
        "name": "${container_name}",
        "image": "${image_id}",
        "cpu": 0,
        "environment" : [
            {
                "value": "${graphql_server_param}",
                "name": "GRAPHQL_SERVER"
            },
            {
                "value": "${graphql_path_param}",
                "name": "GRAPHQL_PATH"
            },
            {
                "value": "${export_bucket_param}",
                "name": "EXPORT_BUCKET"
            }
        ],
        "networkMode": "awsvpc",
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${log_group_name}",
                "awslogs-region": "${aws_region}",
                "awslogs-stream-prefix": "ecs"
            }
        }
    }
]
