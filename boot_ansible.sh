#!/bin/bash

# ----------------------------------------
# Exit immediately if a command exits with a non-zero status
# ----------------------------------------
set -e

# ----------------------------------------
# Step 1: Install Ansible
# ----------------------------------------
echo "📥 Step 1: Installing Ansible..."
curl -v https://raw.githubusercontent.com/AlexandrNeverov/zero-node-stack-full/refs/heads/main/boot/setup_zero_ansible.sh | bash -
echo "✅ Step 1 - Ansible installed."

# ----------------------------------------
# Step 2: Clone Ansible repo
# ----------------------------------------
PROJECT_ROOT="/home/ubuntu/projects"
ANS_REPO_URL="https://github.com/AlexandrNeverov/ansible_docker_setup.git"
ANS_DIR="$PROJECT_ROOT/ansible/ansible_docker_setup"

echo "📦 Cloning Ansible repository..."
mkdir -p "$PROJECT_ROOT/ansible"
cd "$PROJECT_ROOT/ansible"

if [ -d "$ANS_DIR" ]; then
    echo "⚠️ Repository already exists at $ANS_DIR, skipping clone."
else
    git clone "$ANS_REPO_URL"
    echo "✅ Repository cloned to $ANS_DIR"
fi

# ----------------------------------------
# Step 3: Retrieve public IP from Terraform
# ----------------------------------------
echo "🌐 Retrieving public IP from Terraform..."
cd "$PROJECT_ROOT/terraform/terraform_docker_setup"
terraform refresh > /dev/null

EC2_IP=$(terraform output -raw instance_public_ip 2>/dev/null || true)

if [ -z "$EC2_IP" ]; then
    echo "❌ Failed to get public IP from Terraform. Check outputs.tf and ensure instance_public_ip is defined."
    exit 1
else
    echo "🧩 Found public IP: $EC2_IP"
fi

# ----------------------------------------
# Step 4: Generate Ansible inventory file
# ----------------------------------------
KEY_PATH="/home/ubuntu/.ssh/zero-node-key"
TARGET_INVENTORY="$ANS_DIR/inventory/hosts.ini"

echo "🛠 Creating Ansible inventory at $TARGET_INVENTORY..."
mkdir -p "$(dirname "$TARGET_INVENTORY")"
cat <<EOF > "$TARGET_INVENTORY"
[docker]
$EC2_IP ansible_user=ubuntu ansible_ssh_private_key_file=$KEY_PATH
EOF

echo "✅ Inventory created: $TARGET_INVENTORY"

# ----------------------------------------
# Step 5: Run Ansible playbook
# ----------------------------------------
echo "🚀 Running Ansible playbook: $ANS_DIR/playbooks/site.yml"
cd "$ANS_DIR"
ansible-playbook -i inventory/hosts.ini playbooks/site.yml

# ----------------------------------------
# Step 6: Show Docker UI endpoint
# ----------------------------------------
echo "✅ All setup scripts executed successfully! Use 'ssh -i /home/ubuntu/.ssh/zero-node-key ubuntu@<public-ip> to connect'"
echo "🌐 Docker UI is available at: http://$EC2_IP:9000"