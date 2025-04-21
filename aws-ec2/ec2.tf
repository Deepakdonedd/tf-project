#ec2 instance
resource "aws_instance" "app_machine" {
  ami           = "ami-00bb6a80f01f03502"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_1.id
  security_groups = [aws_security_group.my_sg.id]
  key_name = var.existing_key_pair

  tags = {
    Name = "AppMachine"
  }
  lifecycle {
    ignore_changes = [
      security_groups,  # Ignore security group changes
      vpc_security_group_ids,  # Ignore security group updates
      user_data  # Ignore changes in user_data if unnecessary
    ]
  }
}

resource "aws_instance" "tools_machine" {
  ami           = "ami-00bb6a80f01f03502"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_2.id
  security_groups = [aws_security_group.my_sg.id]
  key_name = var.existing_key_pair

  tags = {
    Name = "ToolsMachine"
  }
  lifecycle {
    ignore_changes = [
      security_groups,  # Ignore security group changes
      vpc_security_group_ids,  # Ignore security group updates
      user_data  # Ignore changes in user_data if unnecessary
    ]
  }
}


