resource "aws_sfn_state_machine" "sfn_state_machine" {
  name       = "tdr-step-function-${var.environment}"
  role_arn   = "arn:aws:iam::247222723249:role/service-role/TestS3Role"
  definition = <<EOF
     {
  "StartAt":"Run File Checks",
  "States":{
    "Run File Checks":{
      "Type":"Parallel",
      "End":true,
      "Branches":[
        {
          "StartAt":"Run Virus Checks",
          "States":{
            "Run Virus Checks":{
              "Type":"Task",
              "Resource": "arn:aws:states:::ecs:runTask.sync",
              "Parameters":{
                "LaunchType":"FARGATE",
                "Cluster":"${var.cluster_arn}",
                "TaskDefinition":"${var.virus_check_task_arn}",
                "NetworkConfiguration":{
                  "AwsvpcConfiguration":{
                    "Subnets":[
                      "${var.ecs_private_subnet[0]}",
                      "${var.ecs_private_subnet[1]}"
                    ],
                    "SecurityGroups":[
                      "${aws_security_group.ecs_tasks.id}"
                    ],
                    "AssignPublicIp":"DISABLED"
                  }
                },
                "Overrides":{
                  "ContainerOverrides":[
                    {
                      "Name":"${var.virus_check_container_name}",
                      "Environment":[
                        {
                          "Name":"CONSIGNMENT_ID",
                          "Value.$":"$.consignmentId"
                        }
                      ]
                    }
                  ]
                }
              },
              "End": true
            }
          }
        },
        {
          "StartAt":"Run file format checks",
          "States":{
            "Run file format checks":{
              "Type":"Task",
              "Resource": "arn:aws:states:::ecs:runTask.sync",
              "Parameters":{
                "LaunchType":"FARGATE",
                "Cluster":"${var.cluster_arn}",
                "TaskDefinition":"${var.file_format_check_task_arn}",
                "NetworkConfiguration":{
                  "AwsvpcConfiguration":{
                    "Subnets":[
                      "${var.ecs_private_subnet[0]}",
                      "${var.ecs_private_subnet[1]}"
                    ],
                    "SecurityGroups":[
                      "${aws_security_group.ecs_tasks.id}"
                    ],
                    "AssignPublicIp":"DISABLED"
                  }
                },
                "Overrides":{
                  "ContainerOverrides":[
                    {
                      "Name":"${var.file_format_check_container_name}",
                      "Environment":[
                        {
                          "Name":"CONSIGNMENT_ID",
                          "Value.$":"$.consignmentId"
                        }
                      ]
                    }
                  ]
                }
              },
              "End": true
            }
          }
        },
        {
          "StartAt":"Run checksum checks",
          "States":{
            "Run checksum checks":{
              "Type":"Task",
              "Resource": "arn:aws:states:::ecs:runTask.sync",
              "Parameters":{
                "LaunchType":"FARGATE",
                "Cluster":"${var.cluster_arn}",
                "TaskDefinition":"${var.checksum_check_task_arn}",
                "NetworkConfiguration":{
                  "AwsvpcConfiguration":{
                    "Subnets":[
                      "${var.ecs_private_subnet[0]}",
                      "${var.ecs_private_subnet[1]}"
                    ],
                    "SecurityGroups":[
                      "${aws_security_group.ecs_tasks.id}"
                    ],
                    "AssignPublicIp":"DISABLED"
                  }
                },
                "Overrides":{
                  "ContainerOverrides":[
                    {
                      "Name":"${var.checksum_check_container_name}",
                      "Environment":[
                        {
                          "Name":"CONSIGNMENT_ID",
                          "Value.$":"$.consignmentId"
                        }
                      ]
                    }
                  ]
                }
              },
              "End": true
            }
          }
        }
      ]
    }
  }
}

    EOF

  tags = merge(
  var.common_tags,
  map(
  "Name", "step-function-${var.environment}",
  )
  )
}