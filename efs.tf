resource "aws_efs_file_system" "jenkins_efs" {
  creation_token = "Jenkins-EFS"
  encrypted      = true
  kms_key_id     = "${aws_kms_key.ebs_kms.arn}"
  tags = {
    Name         = "Jenkins-EFS"
  }
}

resource "aws_efs_mount_target" "jenkins_target_subnet_1" {
  file_system_id  = "${aws_efs_file_system.jenkins_efs.id}"
  subnet_id       = "${var.public_subnets}"
  security_groups = ["${aws_security_group.efs-securitygroup.id}"]
}

resource "aws_efs_mount_target" "jenkins_target_subnet_2" {
  file_system_id  = "${aws_efs_file_system.jenkins_efs.id}"
  subnet_id       = "${var.public_subnets}"
  security_groups = ["${aws_security_group.efs-securitygroup.id}"]
}
resource "aws_efs_mount_target" "jenkins_target_subnet_3" {
  file_system_id  = "${aws_efs_file_system.jenkins_efs.id}"
  subnet_id       = "${var.public_subnets}"
  security_groups = ["${aws_security_group.efs-securitygroup.id}"]
}
resource "aws_efs_mount_target" "jenkins_target_subnet_4" {
  file_system_id  = "${aws_efs_file_system.jenkins_efs.id}"
  subnet_id       = "${var.public_subnets}"
  security_groups = ["${aws_security_group.efs-securitygroup.id}"]
}
