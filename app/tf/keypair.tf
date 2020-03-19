data "local_file" "pub_key" {
  filename          = "/data/id_rsa.pub"
}

resource "aws_key_pair" "main" {
  key_name_prefix   = var.lab_prefix
  public_key        = data.local_file.pub_key.content
}
