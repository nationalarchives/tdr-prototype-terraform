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
                "Cluster":"arn:aws:ecs:eu-west-2:247222723249:cluster/tdr-prototype-ecs-dev",
                "TaskDefinition":"arn:aws:ecs:eu-west-2:247222723249:task-definition/tdr-checksum-check-dev:8",
                "NetworkConfiguration":{
                  "AwsvpcConfiguration":{
                    "Subnets":[
                      "subnet-04b20acae2eeae8ad",
                      "subnet-02b54a5e5e9d4988a"
                    ],
                    "SecurityGroups":[
                      "sg-063e96e14996b34f4"
                    ],
                    "AssignPublicIp":"DISABLED"
                  }
                },
                "Overrides":{
                  "ContainerOverrides":[
                    {
                      "Name":"checksum-check-container-dev",
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
                "Cluster":"arn:aws:ecs:eu-west-2:247222723249:cluster/tdr-prototype-ecs-dev",
                "TaskDefinition":"arn:aws:ecs:eu-west-2:247222723249:task-definition/tdr-checksum-check-dev:7",
                "NetworkConfiguration":{
                  "AwsvpcConfiguration":{
                    "Subnets":[
                      "subnet-04b20acae2eeae8ad",
                      "subnet-02b54a5e5e9d4988a"
                    ],
                    "SecurityGroups":[
                      "sg-063e96e14996b34f4"
                    ],
                    "AssignPublicIp":"DISABLED"
                  }
                },
                "Overrides":{
                  "ContainerOverrides":[
                    {
                      "Name":"checksum-check-container-dev",
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
                "Cluster":"arn:aws:ecs:eu-west-2:247222723249:cluster/tdr-prototype-ecs-dev",
                "TaskDefinition":"arn:aws:ecs:eu-west-2:247222723249:task-definition/tdr-checksum-check-dev:9",
                "NetworkConfiguration":{
                  "AwsvpcConfiguration":{
                    "Subnets":[
                      "subnet-04b20acae2eeae8ad",
                      "subnet-02b54a5e5e9d4988a"
                    ],
                    "SecurityGroups":[
                      "sg-063e96e14996b34f4"
                    ],
                    "AssignPublicIp":"DISABLED"
                  }
                },
                "Overrides":{
                  "ContainerOverrides":[
                    {
                      "Name":"checksum-check-container-dev",
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