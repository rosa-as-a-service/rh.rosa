resource "aws_instance" "bastion" {
  ami               = data.aws_ami.bastion_ami.id
  instance_type     = "t3.micro"
  subnet_id         = var.subnet_id
  key_name          = "nreilly-key"
  security_groups   = [ "sg-0960bc098b1ef2f9b" ]
  user_data_base64  = base64encode(templatefile("${path.module}/user_data.sh", {
    admin_user      = var.admin_user
    admin_password  = var.admin_password
    domain          = var.domain
  }))
  tags = {
    "Name" = "bastion"
  }
}
