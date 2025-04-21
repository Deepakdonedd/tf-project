terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "null_resource" "setup_tools_machine" {
  triggers = {
    always_run = timestamp()
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./aws-key1.pem")
    host        = aws_instance.tools_machine.public_ip
  }

  # Copy AWS private keys to a temporary location first
  provisioner "file" {
    source      = "/home/deepakpathak/TF-AWS/aws-ec2/Ansible_files/aws-key1.pem"
    destination = "/tmp/aws-key1.pem"
  }

  provisioner "file" {
    source      = "/home/deepakpathak/TF-AWS/aws-ec2/Ansible_files/MyVM_key.pem"
    destination = "/tmp/MyVM_key.pem"
  }

  # Copy the Ansible_files directory
  provisioner "file" {
    source      = "/home/deepakpathak/TF-AWS/aws-ec2/Ansible_files"
    destination = "/home/ubuntu/Ansible_files"
  }

  provisioner "remote-exec" {
    inline = [
      # Move SSH keys to .ssh with correct permissions
      "sudo mv /tmp/aws-key1.pem /home/ubuntu/.ssh/aws-key1.pem",
      "sudo mv /tmp/MyVM_key.pem /home/ubuntu/.ssh/MyVM_key.pem",
      "sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/aws-key1.pem /home/ubuntu/.ssh/MyVM_key.pem",
      "sudo chmod 600 /home/ubuntu/.ssh/aws-key1.pem /home/ubuntu/.ssh/MyVM_key.pem",

      # Install Ansible if not installed
      "if ! command -v ansible &> /dev/null; then sudo apt update -y && sudo apt install ansible -y; fi",

      # Ensure /etc/ansible exists and move hosts file
      "sudo mkdir -p /etc/ansible",
      "sudo mv /home/ubuntu/Ansible_files/hosts /etc/ansible/",
      "sudo chown ubuntu:ubuntu /etc/ansible/hosts",

      # Test Ansible connectivity
      "ansible all -m ping",

      # Run Ansible playbook
      "ansible-playbook -i /etc/ansible/hosts /home/ubuntu/Ansible_files/install_nginx.yml",
      
      #install jenkins
      "sudo apt update -y",
      "sudo apt install -y openjdk-17-jdk",
      "curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null",
      "echo 'deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/' | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null",
      "sudo apt update -y",
      "sudo apt install jenkins -y",
      "sudo systemctl enable jenkins",
      "sudo systemctl start jenkins"
    
    ]  
  }
}