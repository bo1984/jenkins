terraform {
  backend "s3" {
    bucket = "lechange-aws-bucket"
    key    = "Terraform-State/Jenkins/terraform.tfstate"
    region = "us-west-2"
  }
}

data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux/recommended/image_id"
}

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

resource "aws_launch_configuration" "jenkins-configuration" {
  name_prefix          = "${var.environment}-jenkins-configuration"
  image_id             = "${data.aws_ssm_parameter.ecs_optimized_ami.value}"
  instance_type        = "${var.jenkins_instance_type}"
  key_name             = "${aws_key_pair.key_pair.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.jenkins-profile.id}"
  security_groups      = ["${aws_security_group.jenkins-securitygroup.id}"]
  user_data            = "${data.template_file.jenkins_user_data.rendered}"
  lifecycle  { 
    create_before_destroy = true 
    }
}

resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.ecs_cluster}"
}
