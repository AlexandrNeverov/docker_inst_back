#!/bin/bash

# ----------------------------------
# Exit immediately if a command fails
# ----------------------------------
set -e

# ----------------------------------
# Variables and paths
# ----------------------------------
PROJECT_ROOT="/home/ubuntu/projects"
ANS_REPO_URL="https://github.com/AlexandrNeverov/ansible_docker_setup.git"
ANS_DIR="$PROJECT_ROOT/ansible/ansible_docker_setup"
TARGET_INVENTORY="$ANS_DIR/inventory/hosts.ini"
KEY_PATH="/home/ubuntu/.ssh/zero-node-key"
PLAYBOOK_PATH="$ANS_DIR/playbooks/site.yml"

# ----------------------------------
# Clone Ansible repository (if not already cloned)
# ----------------------------------
echo "📦 Cloning Ansible repository..."
mkdir -p "$PROJECT_ROOT/ansible"
cd "$PROJECT_ROOT/ansible"

if [ -d "$ANS_DIR" ]; then
  echo "⚠️ Repository already exists at $ANS_DIR, skipping clone."
else
  git clone "$ANS_REPO_URL"
  echo "✅ Repository cloned to $ANS_DIR"
fi

# ----------------------------------
# Get EC2 public IP from Terraform output
# ----------------------------------
echo "🌐 Retrieving public IP from Terraform..."
EC2_IP=$(terraform output -raw public_ip)
echo "🧩 Found public IP: $EC2_IP"

# ----------------------------------
# Generate Ansible inventory
# ----------------------------------
echo "🛠 Creating Ansible inventory at $TARGET_INVENTORY..."

mkdir -p "$(dirname "$TARGET_INVENTORY")"

cat <<EOF > "$TARGET_INVENTORY"
[docker]
$EC2_IP ansible_user=ubuntu ansible_ssh_private_key_file=$KEY_PATH
EOF

echo "✅ Inventory created: $TARGET_INVENTORY"

# ----------------------------------
# Run Ansible playbook
# ----------------------------------
echo "🚀 Running Ansible playbook: $PLAYBOOK_PATH"

cd "$ANS_DIR"
ansible-playbook -i inventory/hosts.ini playbooks/site.yml

# ----------------------------------
# Done — Show Docker UI access info
# ----------------------------------
echo "✅ Playbook executed successfully."
echo "🌐 Docker UI is available at: http://$EC2_IP:9000"