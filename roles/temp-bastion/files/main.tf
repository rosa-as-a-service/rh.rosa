resource "template_file" "user_data" {
  template = "${file("user_data.sh")}"
}

resource "aws_instance" "bastion" {
  ami               = data.aws_ami.bastion_ami
  instance_type     = "t3.micro"
  subnet_id         = var.subnet_id
  user_data         = "${template_file.user_data.rendered}"
}