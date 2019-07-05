#######
# Internal jenkins ALB Resources
#######
resource "aws_alb" "jenkins-alb" {
  name               = "Jenkins-ALB"
  internal           = true
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.jenkins-alb-securitygroup.id}"]
  subnets            = ["${data.terraform_remote_state.vpc.private_subnets}"]

  tags = {
    Name   = "Jenkins-ALB"
  }
}



# Define a listener
resource "aws_alb_listener" "jenkins-listener" {
  load_balancer_arn = "${aws_alb.jenkins-alb.arn}"
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.jenkins.arn}"
    type             = "forward"
  }
  
}

# Target Groups Section
resource "aws_alb_target_group" "jenkins" {
  name     = "Jenkins-TargetGroup"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.vpc.vpc_id}"
  health_check =  [{
    path     = "/robots.txt"
    protocol = "HTTP"
    matcher  = "200"
  }]
}