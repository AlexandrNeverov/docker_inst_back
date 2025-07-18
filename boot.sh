#!/bin/bash

# -------------------------------
# Exit immediately on error
# -------------------------------
set -e

# -------------------------------
# Paths
# -------------------------------
PROJECT_ROOT="/home/ubuntu/projects"
TF_REPO_URL="https://github.com/AlexandrNeverov/terraform_docker_setup.git"
TF_DIR="$PROJECT_ROOT/terraform/terraform_docker_setup"
BACKEND_FILE="$TF_DIR/backend.tf"
BUCKET_FILE="$PROJECT_ROOT/s3_bucket.txt"
PLAN_FILE="tfplan"

# -------------------------------
# Clone Terraform project
# -------------------------------
echo "📦 Cloning Terraform repo..."
cd "$PROJECT_ROOT/terraform"
git clone "$TF_REPO_URL"
echo "✅ Repo cloned to $TF_DIR"

# -------------------------------
# Replace bucket name in backend.tf
# -------------------------------
if [ ! -f "$BUCKET_FILE" ]; then
  echo "❌ Bucket file not found: $BUCKET_FILE"
  exit 1
fi

BUCKET_NAME=$(cat "$BUCKET_FILE" | tr -d ' \t\n')

if [ -z "$BUCKET_NAME" ]; then
  echo "❌ Bucket name is empty in file: $BUCKET_FILE"
  exit 1
fi

echo "🔧 Updating bucket name in backend.tf..."
cp "$BACKEND_FILE" "${BACKEND_FILE}.bak"
sed -i "s/^ *bucket *= *.*/  bucket = \"$BUCKET_NAME\"/" "$BACKEND_FILE"
echo "✅ Bucket name \"$BUCKET_NAME\" updated in $BACKEND_FILE"

# -------------------------------
# Run Terraform commands
# -------------------------------
echo "🚀 Running: terraform init..."
cd "$TF_DIR"
terraform init
echo "✅ terraform init completed."

echo "🛠️  Running: terraform plan..."
terraform plan -out="$PLAN_FILE"
echo "✅ terraform plan saved to $PLAN_FILE"

echo "⚙️  Running: terraform apply..."
terraform apply -auto-approve "$PLAN_FILE"
echo "✅ terraform apply completed successfully."