data "aws_ami" "amzn2" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.webserver["ami_name"]]
  }

  filter {
    name   = "virtualization-type"
    values = [var.webserver["virt_type"]]
  }

  owners = ["amazon"]
}

resource "aws_instance" "webserver" {
  ami                    = data.aws_ami.amzn2.id
  instance_type          = var.webserver["instance_type"]
  user_data              = file("userdata.sh")
  iam_instance_profile   = aws_iam_instance_profile.webserver_profile.id
  subnet_id              = aws_subnet.private1.id
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]

  depends_on = [
    aws_db_instance.wordpress_db,
    acme_certificate.certificate
  ]
}
