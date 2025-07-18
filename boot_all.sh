#!/bin/bash
set -e

echo "🔧 Step 1: Installing zero-node tools..."
curl -fsSL https://raw.githubusercontent.com/AlexandrNeverov/zero-node-stack-full/refs/heads/main/boot/setup_zero_node_tools.sh | bash -

echo "🔐 Step 2: Installing Vault HCL setup..."
curl -fsSL https://raw.githubusercontent.com/AlexandrNeverov/zero-node-stack-full/refs/heads/main/boot/hcl_vault.sh | bash -

echo "📦 Step 3: Installing Terraform setup..."
curl -fsSL https://raw.githubusercontent.com/AlexandrNeverov/zero-node-stack-full/refs/heads/main/boot/setup_zero_terraform.sh | bash -

echo "🐳 Step 4: Installing Docker provisioning script..."
curl -fsSL https://raw.githubusercontent.com/AlexandrNeverov/DevOps-Showcase-Automated-Docker-Infrastructure-with-Terraform-and-Ansible-AWS-EC2-/refs/heads/main/boot/docker.sh | bash -

echo "✅ All setup scripts executed successfully!"