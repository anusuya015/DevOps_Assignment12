output "manager_public_ip" {
  description = "Public IP address of Swarm Manager (with EIP)"
  value       = aws_eip.manager_eip.public_ip
}

output "manager_private_ip" {
  description = "Private IP address of Swarm Manager"
  value       = aws_instance.swarm_manager.private_ip
}

output "worker_a_public_ip" {
  description = "Public IP address of Worker A (with EIP)"
  value       = aws_eip.worker_a_eip.public_ip
}

output "worker_a_private_ip" {
  description = "Private IP address of Worker A"
  value       = aws_instance.swarm_worker_a.private_ip
}

output "worker_b_public_ip" {
  description = "Public IP address of Worker B (with EIP)"
  value       = aws_eip.worker_b_eip.public_ip
}

output "worker_b_private_ip" {
  description = "Private IP address of Worker B"
  value       = aws_instance.swarm_worker_b.private_ip
}

output "private_key_path" {
  description = "Path to the generated SSH private key"
  value       = local_file.private_key.filename
}

output "security_group_id" {
  description = "ID of the created security group"
  value       = aws_security_group.devops_sg.id
}

output "manager_instance_id" {
  description = "EC2 Instance ID of Manager"
  value       = aws_instance.swarm_manager.id
}

output "worker_a_instance_id" {
  description = "EC2 Instance ID of Worker A"
  value       = aws_instance.swarm_worker_a.id
}

output "worker_b_instance_id" {
  description = "EC2 Instance ID of Worker B"
  value       = aws_instance.swarm_worker_b.id
}

output "ubuntu_ami_id" {
  description = "Ubuntu AMI ID used for instances"
  value       = data.aws_ami.ubuntu.id
}

# Connection information
output "ssh_command_manager" {
  description = "SSH command to connect to Manager"
  value       = "ssh -i ${local_file.private_key.filename} ubuntu@${aws_eip.manager_eip.public_ip}"
}

output "ssh_command_worker_a" {
  description = "SSH command to connect to Worker A"
  value       = "ssh -i ${local_file.private_key.filename} ubuntu@${aws_eip.worker_a_eip.public_ip}"
}

output "ssh_command_worker_b" {
  description = "SSH command to connect to Worker B"
  value       = "ssh -i ${local_file.private_key.filename} ubuntu@${aws_eip.worker_b_eip.public_ip}"
}

output "application_url" {
  description = "URL to access the deployed application"
  value       = "http://${aws_eip.manager_eip.public_ip}"
}

# Summary output
output "deployment_summary" {
  description = "Complete deployment information"
  value = {
    manager_ip    = aws_eip.manager_eip.public_ip
    worker_a_ip   = aws_eip.worker_a_eip.public_ip
    worker_b_ip   = aws_eip.worker_b_eip.public_ip
    app_url       = "http://${aws_eip.manager_eip.public_ip}"
    ssh_key_path  = local_file.private_key.filename
  }
}
