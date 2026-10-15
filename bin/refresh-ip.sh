#!/usr/bin/env bash
set -euo pipefail

MAIN_TF="envs/dev/main.tf"

if [ ! -f "$MAIN_TF" ]; then
  echo "Error: $MAIN_TF not found. Run this script from the repo root."
  exit 1
fi

MY_IP=$(curl -s ifconfig.me)
CURRENT=$(grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}/32' "$MAIN_TF" | head -1 | cut -d/ -f1)

if [ -z "$CURRENT" ]; then
  echo "Error: Could not find a workstation CIDR in $MAIN_TF"
  exit 1
fi

if [ "$MY_IP" != "$CURRENT" ]; then
  echo "IP changed: $CURRENT -> $MY_IP"
  sed -i "s|${CURRENT}/32|${MY_IP}/32|g" "$MAIN_TF"
  echo "Updated $MAIN_TF"
  echo ""
  echo "Next step:"
  echo "  cd envs/dev && terraform apply"
else
  echo "IP unchanged: $MY_IP"
fi