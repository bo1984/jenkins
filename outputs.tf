#########
# ECS AMI
#########
output "ecs_optimized_ami" {
  value = "${data.aws_ssm_parameter.ecs_optimized_ami.value}"
}
output "ecs_cluster" {
  description = "ECS Cluster"
  value = "${aws_ecs_cluster.ecs-cluster.id}"
}
#########
# EFS
#########
output "efs_id" {
    value = "${aws_efs_file_system.jenkins_efs.id}"
}
output "efs_name" {
    value = "${aws_efs_file_system.jenkins_efs.dns_name}"
}
#########
# ALB
#########
output "alb_dns" {
    value = "${aws_alb.jenkins-alb.dns_name}"
}
#########
# Security Groups
#########
output "jenkins_alb_security_group" {
    value = "${aws_security_group.jenkins-alb-securitygroup.id}"
}
output "jenkins_security_group" {
    value = "${aws_security_group.jenkins-securitygroup.id}"
}
output "efs_security_group" {
    value = "${aws_security_group.efs-securitygroup.id}"
}
#########
# IAM
#########
output "jenkins_profile" {
    description = "IAM ECS Instance Profile for Jenkins"
    value = "${aws_iam_instance_profile.jenkins-profile.arn}"
}
output "jenkins_role" {
    description = "IAM ECS Service Role for Jenkins"
    value = "${aws_iam_role.jenkins-ec2-role.arn}"
}
#########
# KMS
#########
output "ebs_kms_arn" {
    description = "EBS KMS ARN"
    value = "${aws_kms_key.ebs_kms.arn}"
}
output "ebs_kms_id" {
    description = "EBS KMS ID"
    value = "${aws_kms_key.ebs_kms.key_id}"
}
output "s3_kms_arn" {
    description = "S3 KMS ARN"
    value = "${aws_kms_key.s3_key.arn}"
}
output "s3_kms_id" {
    description = "S3 KMS ID"
    value = "${aws_kms_key.s3_key.key_id}"
}
output "backup_kms_arn" {
    description = "Backup KMS ARN"
    value = "${aws_kms_key.backup_key.arn}"
}
output "backup_kms_id" {
    description = "Backup KMS ID"
    value = "${aws_kms_key.backup_key.key_id}"
}

#########
# S3
#########
output "pipeline_bucket_id" {
    description = "Pipeline Bucket ID"
    value = "${aws_s3_bucket.pipeline_bucket.id}"
}
output "pipeline_bucket_arn" {
    description = "Pipeline Bucket ARN"
    value = "${aws_s3_bucket.pipeline_bucket.arn}"
}
output "pipeline_bucket_name" {
    description = "Pipeline Bucket Name"
    value = "${aws_s3_bucket.pipeline_bucket.bucket_domain_name}"
}