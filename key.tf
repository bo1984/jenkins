resource "aws_key_pair" "key_pair" {
  key_name = "${var.environment}-ecs_key_pair"
  public_key = "${file("${var.path_to_public_key}")}"
  lifecycle {
    ignore_changes = ["public_key"]
  }
}