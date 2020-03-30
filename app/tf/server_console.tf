# app server
resource "aws_instance" "console" {
  ami                       = var.ami_id_console
  instance_type             = var.app_instance_type
  subnet_id                 = aws_subnet.main.id
  vpc_security_group_ids    = [aws_security_group.main.id]
  availability_zone         = var.aws_availability_zone
  key_name                  = aws_key_pair.main.id
  depends_on                = [aws_subnet.main, aws_security_group.main, aws_key_pair.main]

  tags = {
    Name                    = "${var.lab_prefix}_console"
  }

  lifecycle {
    ignore_changes = [tags, user_data]
  }
}
resource "aws_eip" "console" {
  instance                  = aws_instance.console.id
  vpc                       = true
  depends_on                = [aws_instance.console]

  tags = {
    Name                    = "${var.lab_prefix}_console_eip"
  }
}
resource "aws_route53_record" "console" {
  zone_id                   = var.aws_r53_zone_id
  name                      = "console.${var.lab_prefix}"
  type                      = "A"
  ttl                       = "300"
  records                   = [aws_eip.console.public_ip]
}
