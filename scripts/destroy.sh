#!/usr/bin/env bash

# Notice we do NOT use 'set -e' here. We want the script to continue 
# cleaning up resources even if one of the steps throws an error.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "🧨 Starting Full Teardown to Save Costs..."

# --- STEP 1: PRE-FLIGHT CLEANUP ---
echo "1️⃣  Refreshing IP to ensure cluster access..."
./bin/refresh-ip.sh
cd envs/dev && terraform apply -auto-approve && cd "$REPO_ROOT"

echo "1.5️⃣  Bypassing ArgoCD prevent_destroy block..."
sed -i 's/prevent_destroy = true/prevent_destroy = false/g' envs/dev-argocd/argocd.tf

# --- STEP 2: DESTROY CLUSTER TOOLS ---
echo "2️⃣  Destroying Cluster Tools (dev-argocd)..."
cd envs/dev-argocd

# Force-unlock the state if we left a lock from a previous interrupted run
# (We ignore errors here in case there is no lock)
terraform force-unlock -force "$(terraform state pull | jq -r '.lock_id // empty')" 2>/dev/null || true

echo "   Cleaning up stuck Kubernetes namespaces (Webhook deadlocks)..."
kubectl delete namespace argocd kyverno cert-manager ingress-nginx external-secrets monitoring --force --grace-period=0 2>/dev/null || true

# Remove the helm releases from state so Terraform doesn't hang on them
terraform state rm helm_release.argocd 2>/dev/null || true
terraform state rm helm_release.kyverno 2>/dev/null || true
terraform state rm helm_release.cert_manager 2>/dev/null || true

terraform destroy -auto-approve
cd "$REPO_ROOT"

# --- STEP 3: DESTROY CORE INFRASTRUCTURE ---
echo "3️⃣  Destroying Core Infrastructure (dev)..."
cd envs/dev

echo "   Force deleting Cloud SQL (avoids Postgres dependency errors)..."
gcloud sql instances delete dev-retail-db --quiet 2>/dev/null || true
terraform state rm module.cloudsql 2>/dev/null || true

echo "   Force removing VPC Peering & Cloud SQL IP ghosts..."
gcloud services vpc-peerings update \
  --network=retail-platform-dev-vpc \
  --ranges=dev-cloudsql-ip \
  --service=servicenetworking.googleapis.com \
  --force 2>/dev/null || true
gcloud compute addresses delete dev-cloudsql-ip --global --quiet 2>/dev/null || true

echo "   Destroying remaining Terraform resources..."
terraform destroy -auto-approve

# --- STEP 4: FINAL VERIFICATION ---
echo "4️⃣  Verifying all resources are gone..."
if [ -z "$(gcloud container clusters list --format='value(name)')" ] && \
   [ -z "$(gcloud sql instances list --format='value(name)')" ] && \
   [ -z "$(gcloud compute instances list --format='value(name)')" ]; then
    echo "✅ SUCCESS: All billable resources destroyed!"
else
    echo "⚠️  WARNING: Some resources may still be lingering. Please check the GCP Console."
fi
