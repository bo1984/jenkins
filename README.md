<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
# Jenkins Terraform Stack

## Summary

The Terraform stack will create the Infrastructure that runs on an Amazon EC2 instance. The Jenkins process itself runs on a Docker container and is configured and its runtime is managed through ECS. 

Configuration of the back-end state file is controlled in main.tf

    terraform {
        backend "s3" {
            bucket = "clarity-sharedservices-environment-bucket"
            key    = "Terraform-State/Jenkins/terraform.tfstate"
            region = "us-east-1"
        }
    }



## Pre-Requisites

* This stack requires the [VPC](https://github.com/ClarityServices/aws-shared-services/tree/master/VPC) Terraform module to have spun up first. It retrieves certain outputs from the VPC stack such as the VPC ID, subnets, etc...

        data "terraform_remote_state" "vpc" {
            backend = "s3"
            config {
                bucket = "clarity-sharedservices-environment-bucket"
                key    = "Terraform-State/VPC/terraform.tfstate"
                region = "us-east-1"
            }
        }


## Usage

    #Custom userdata script code
    mkdir /var/jenkins_home
    mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 ${efs_name}:/ /var/jenkins_home
    useradd jenkins -u 1000
    chown jenkins:jenkins /var/jenkins_home
    chmod 777 /var/jenkins_home
    cp /etc/fstab /etc/fstab.bak
    echo ${efs_name}:/ /var/jenkins_home nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0 | sudo tee -a /etc/fstab
    echo "Done"

The EC2 instance (container instance in ECS context) mounts the EFS volume when bootstrapped via the aforementioned bash script. The values are fed in via the main.tf file as such:

    data "template_file" "jenkins_user_data" {
        template = "${file("templates/jenkins_user_data.sh")}"

        vars {
            ecs_cluster       = "${var.ecs_cluster}"
            ecs_logging       = "${var.ecs_logging}"
            env_name          = "${var.environment}"
            cloudwatch_prefix = "${var.cloudwatch_prefix}"
            efs_name          = "${aws_efs_file_system.jenkins_efs.dns_name}"
        }
    }

In the service.tf file, the service itself is mounted via the ECS agent via the following configuration:

    "mountPoints": [
        {
            "readOnly": false,
            "containerPath": "/var/jenkins_home",
            "sourceVolume": "jenkins-efs"
        }
    ],

For data consistency, the Jenkins container is launched onto Amazon EFS where the data will persist in the event that a container should be SIGTERM or SIGKILL. The EFS volume itself is backuped via Amazon Backup.

```Please refer to below link for more documentation on AWS Backup```
https://aws.amazon.com/backup-restore/

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| jenkins\_instance\_type | Instance type used for Jenkins container instance | string | `"t2.small"` | yes |
| path\_to\_public\_key | Path to public key | string | `` | yes |
| ecs\_cluster | Path to public key | string | `"Shared-Services-ECS"` | yes |
| jenkins\_dc | Number of jenkins container instances to run | string | `"1"` | yes |
| jenkins\_task\_count | Number of containers to run for Jenkins | string | `"1"` | yes |
| deployment\_max\_percent | Max percentage of containers to run for deployment | string | `"200"` | yes |
| deployment\_min\_percent | Miniumum percentage of containers to run for deployment| string | `"0"` | yes |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
