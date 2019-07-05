resource "aws_ecs_service" "jenkins" {
  name                               = "jenkins"
  cluster                            = "${var.ecs_cluster}"
  task_definition                    = "${aws_ecs_task_definition.jenkins.arn}"
  desired_count                      = "${var.jenkins_task_count}"
  deployment_maximum_percent         = "${var.deployment_max_percent}"
  deployment_minimum_healthy_percent = "${var.deployment_min_percent}"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.jenkins.arn}"
    container_name   = "jenkins"
    container_port   = 8080
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:service==jenkins"
  }
  
}

resource "aws_ecs_task_definition" "jenkins" {
  family                = "jenkins"
  volume {
    name      = "jenkins-efs"
    host_path = "/var/jenkins_home"
  }
  container_definitions = <<DEFINITION
[
  {
    "cpu": 0,
    "portMappings": [
          {
              "hostPort": 8080,
              "containerPort": 8080,
              "protocol": "tcp"
          }
      ],
    "mountPoints": [
        {
            "readOnly": false,
            "containerPath": "/var/jenkins_home",
            "sourceVolume": "jenkins-efs"
        }
    ],
    "essential": true,
    "image": "554099590145.dkr.ecr.us-east-1.amazonaws.com/jenkins:latest",
    "memory": 512,
    "name": "jenkins"
  }
]
DEFINITION

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:service==jenkins"
  }
}
