#####
# EBS Key
#####
resource "aws_kms_key" "ebs_kms" {
  description             = "KMS Key for EBS"
  enable_key_rotation = true

}

resource "aws_kms_alias" "ebs_kms_alias" {
  name          = "alias/ebs-kms"
  target_key_id = "${aws_kms_key.ebs_kms.key_id}"
}

####
# Backup Key
####
resource "aws_kms_key" "backup_key" {
  description             = "KMS key 1"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "backup_kms_alias" {
  name          = "alias/backup-kms"
  target_key_id = "${aws_kms_key.backup_key.key_id}"
}