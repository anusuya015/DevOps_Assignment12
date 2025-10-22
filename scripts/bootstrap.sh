#!/bin/bash

# ---------------- Terraform ----------------
cd ../terraform
terraform init
terraform apply -auto-approve

# Save the private key locally
cp terraform-key.pem ../ansible/

# ---------------- Ansible ----------------
cd ../ansible
ansible-playbook -i inventory.ini playbooks/deploy_stack.yml

