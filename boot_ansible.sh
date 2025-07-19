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
# Step 1: Install Ansible (if not installed)
# ----------------------------------
echo "🔧 Installing Ansible (if needed)..."
curl -v https://raw.githubusercontent.com/AlexandrNeverov/zero-node-stack-full/refs/heads/main/boot/setup_zero_ansible.sh | bash -

# ----------------------------------
# Step 2: Clone Ansible repository (if not already cloned)
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
# Step 3: Get EC2 public IP from Terraform output
# ----------------------------------
echo "🌐 Retrieving public IP from Terraform..."
EC2_IP=$(terraform output -raw public_ip || echo "")
if [ -z "$EC2_IP" ]; then
  echo "❌ ERROR: No public IP found in Terraform output. Please run 'terraform apply' and try again."
  exit 1
fi
echo "🧩 Found public IP: $EC2_IP"

# ----------------------------------
# Step 4: Generate Ansible inventory
# ----------------------------------
echo "🛠 Creating Ansible inventory at $TARGET_INVENTORY..."

mkdir -p "$(dirname "$TARGET_INVENTORY")"

cat <<EOF > "$TARGET_INVENTORY"
[docker]
$EC2_IP ansible_user=ubuntu ansible_ssh_private_key_file=$KEY_PATH
EOF

echo "✅ Inventory created: $TARGET_INVENTORY"

# ----------------------------------
# Step 5: Run Ansible playbook
# ----------------------------------
echo "🚀 Running Ansible playbook: $PLAYBOOK_PATH"

cd "$ANS_DIR"
ansible-playbook -i inventory/hosts.ini playbooks/site.yml

# ----------------------------------
# Step 6: Done — Show Docker UI access info
# ----------------------------------
echo "✅ Playbook executed successfully."
echo "🌐 Docker UI is available at: http://$EC2_IP:9000"