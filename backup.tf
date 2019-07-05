data "aws_caller_identity" "current" {}

output "account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}
resource "aws_backup_vault" "backup_vault" {
  name        = "$Backup-Vault"
  kms_key_arn = "${aws_kms_key.backup_key.arn}"
}
resource "aws_backup_plan" "backup_vault_plan" {
  name = "Jenkins Backup Plan"

  rule {
    rule_name         = "Jenkins-Backup_rule"
    target_vault_name = "${aws_backup_vault.backup_vault.name}"
    schedule          = "cron(0 4 * * ? *)"
  }
  tags = {
    Name   = "Backup-Vault-Plan"
  }
}
resource "aws_backup_selection" "efs_backup" {
  depends_on   = ["aws_backup_vault.backup_vault", "aws_backup_plan.backup_vault_plan"]
  plan_id      = "${aws_backup_plan.backup_vault_plan.id}"

  name         = "jenkins-efs-backups"
  iam_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/service-role/AWSBackupDefaultServiceRole"

  resources = [
    "${aws_efs_file_system.jenkins_efs.arn}"
  ]
}