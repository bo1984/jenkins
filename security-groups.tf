resource "aws_security_group" "jenkins-alb-securitygroup" {
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  name        = "Jenkins-ALB-sg"
  description = "allow HTTP to Jenkins ALB"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "jenkins-alb-sg"
  }
}

resource "aws_security_group" "jenkins-securitygroup" {
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  name        = "Jenkins-SG"
  description = "Jenkins Security Group"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 8080
    to_port         = 8080
    security_groups = ["${aws_security_group.jenkins-alb-securitygroup.id}"]
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    description     = "Allow SSH access"
    from_port       = 22
    to_port         = 22
#    security_groups = ["${aws_security_group.jenkins-alb-securitygroup.id}"]
    protocol        = "tcp"
    cidr_blocks     = ["10.0.0.0/8"]
  }

  tags {
    Name        = "jenkins-alb-sg"
    Owner       = "${var.owner}"
    Environment = "${var.environment}"
    Client      = "${var.Client}"
    Application = "${var.Application}"
    Project     = "${var.Project}"
    Created_by  = "${var.Created_by}"
    Terraform   = "true"
  }
}

resource "aws_security_group" "efs-securitygroup" {
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  name        = "${var.environment}-efs-sg"
  description = "allow HTTP to Jenkins ALB"
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.jenkins-securitygroup.id}"]
  }

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "6"
    security_groups = ["${aws_security_group.jenkins-securitygroup.id}"]
  }

  tags {
    Name        = "efs-sg"
    Owner       = "${var.owner}"
    Environment = "${var.environment}"
    Client      = "${var.Client}"
    Application = "${var.Application}"
    Project     = "${var.Project}"
    Created_by  = "${var.Created_by}"
    Terraform   = "true"
  }
}
