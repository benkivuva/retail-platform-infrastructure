#!/usr/bin/env bash
set -euo pipefail

# Get the absolute path to the repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "🚀 Starting Retail Platform Provisioning..."

# 1. Refresh IP (in case it rotated since last time)
echo "🌐 Checking your public IP..."
./bin/refresh-ip.sh

# 2. Provision Core Infrastructure (VPC, GKE, Cloud SQL, IAM)
echo "🏗️  Provisioning Core Infrastructure (envs/dev)..."
cd envs/dev
terraform init -upgrade
# Apply the IP change first to avoid GKE timeouts
terraform apply -auto-approve
cd "$REPO_ROOT"

# 3. Bootstrap Cluster Tools (ArgoCD, Prometheus, Kyverno, ESO)
echo "🛠️  Bootstrapping Kubernetes Cluster Tools (envs/dev-argocd)..."
cd envs/dev-argocd
terraform init -upgrade
terraform apply -auto-approve
cd "$REPO_ROOT"

echo "✅ Infrastructure setup complete!"
echo "⚠️  REMINDER: Push to your GitOps/App repos to trigger GitHub Actions and ArgoCD syncing."
echo "⚠️  REMINDER: Re-create the GitHub OAuth App if your Backstage URL changed."
