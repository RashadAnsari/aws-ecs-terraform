resource "aws_key_pair" "main" {
  key_name   = "${var.app_name}-key-pair-${var.app_env}"
  public_key = file(var.ssh_public_file)
}
