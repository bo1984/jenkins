resource "aws_autoscaling_group" "jenkins-asg" {
  name                 = "${var.environment}-jenkins-asg"
  vpc_zone_identifier  = ["${var.public_subnets}"]
  launch_configuration = "${aws_launch_configuration.jenkins-configuration.name}"
  desired_capacity     = "${var.jenkins_dc}"
  min_size             = 0
  max_size             = 1
  target_group_arns = ["${aws_alb_target_group.jenkins.arn}"]
  tag = [
    {
      key = "Name"
      value = "jenkins-instance"
      propagate_at_launch = true
    }
  ]
}