resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.instance_profile_name

  associate_public_ip_address = var.associate_public_ip_address

  user_data = var.user_data != null ? base64encode(var.user_data) : null

  monitoring = var.enable_detailed_monitoring

  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project}-${var.environment}-${var.name}"
    }
  )
}