data "aws_ami" "amzn2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "webserver" {
  ami           = data.aws_ami.amzn2.id
  instance_type = "t2.micro"
  user_data            = file("userdata.sh")
  iam_instance_profile = aws_iam_instance_profile.webserver_profile.id
  subnet_id            = aws_subnet.private1.id

  #subnet_id            = aws_subnet.public1.id
  #associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  key_name               = "us-east-1"

  depends_on = [
    aws_db_instance.wordpress_db,
    acme_certificate.certificate
  ]
}
