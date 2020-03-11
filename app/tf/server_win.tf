# app server
resource "aws_instance" "win" {
  count                     = var.win_node_count
  ami                       = var.ami_id_win
  instance_type             = var.app_instance_type
  subnet_id                 = aws_subnet.main.id
  vpc_security_group_ids    = [aws_security_group.main.id]
  availability_zone         = var.aws_availability_zone
  depends_on                = [aws_subnet.main]

  user_data                 = <<-EOT
  <powershell>
  $admin = [adsi]("WinNT://./administrator, user")
  $admin.PSBase.Invoke("SetPassword", "${var.admin_password}")
  Invoke-Expression ((New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1'))
  </powershell>
  EOT

  tags = {
    Name                    = "${var.lab_prefix}_win_${count.index}"
  }
}
resource "aws_eip" "win" {
  count                     = var.win_node_count
  instance                  = element(aws_instance.win.*.id, count.index)
  vpc                       = true
  depends_on                = [aws_instance.win]

  tags = {
    Name                    = "${var.lab_prefix}_win_eip_${count.index}"
  }
}
resource "aws_route53_record" "win" {
  count                     = var.win_node_count
  zone_id                   = var.aws_r53_zone_id
  name                      = "user${count.index}.${var.lab_prefix}"
  type                      = "A"
  ttl                       = "300"
  records                   = [element(aws_eip.win.*.public_ip, count.index)]
}
