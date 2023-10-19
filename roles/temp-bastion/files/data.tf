data "aws_ami" "bastion_ami" {
  filter {
    name = name
    values = ["RHEL-9.2.0_HVM*Hourly2-GP2"]
  }
  most_recent = true
}