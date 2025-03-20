output "app_machine_public_ip" {
  description = "Public IP of the App Machine"
  value       = aws_instance.app_machine.public_ip
}

output "tools_machine_public_ip" {
  description = "Public IP of the Tools Machine"
  value       = aws_instance.tools_machine.public_ip
}
