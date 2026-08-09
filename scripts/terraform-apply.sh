#!/usr/bin/env bash

set -euo pipefail

ENVIRONMENT="${1:-}"

if [[ -z "$ENVIRONMENT" ]]; then
  echo "Usage: $0 <environment>"
  echo "Example: $0 production"
  exit 1
fi

ENV_DIR="environments/${ENVIRONMENT}"
PLAN_FILE="tfplan-${ENVIRONMENT}"

echo "========================================"
echo "Terraform Apply"
echo "Environment: ${ENVIRONMENT}"
echo "Directory:   ${ENV_DIR}"
echo "Plan file:   ${PLAN_FILE}"
echo "========================================"

# ============================================================
# 1. Validate environment
# ============================================================

if [[ ! -d "$ENV_DIR" ]]; then
  echo "ERROR: Environment directory not found:"
  echo "       ${ENV_DIR}"
  exit 1
fi

# ============================================================
# 2. Validate plan artifact
# ============================================================

if [[ ! -f "$PLAN_FILE" ]]; then
  echo "ERROR: Terraform plan file not found:"
  echo "       ${PLAN_FILE}"
  echo ""
  echo "The apply job must download the plan artifact"
  echo "created by the plan job."
  exit 1
fi

# ============================================================
# 3. Check Terraform
# ============================================================

command -v terraform >/dev/null 2>&1 || {
  echo "ERROR: terraform is not installed."
  exit 1
}

# ============================================================
# 4. Terraform Init
# ============================================================

echo ""
echo "========================================"
echo "STEP 1: Terraform Init"
echo "========================================"

cd "$ENV_DIR"

terraform init \
  -input=false \
  -no-color

# ============================================================
# 5. Show plan
# ============================================================

echo ""
echo "========================================"
echo "STEP 2: Terraform Plan Review"
echo "========================================"

terraform show \
  -no-color \
  "../../${PLAN_FILE}"

# ============================================================
# 6. Apply exact saved plan
# ============================================================

echo ""
echo "========================================"
echo "STEP 3: Terraform Apply"
echo "========================================"

terraform apply \
  -input=false \
  -no-color \
  "../../${PLAN_FILE}"

echo ""
echo "========================================"
echo "Terraform Apply Completed Successfully"
echo "========================================"

echo ""
echo "Environment:"
echo "  ${ENVIRONMENT}"

echo ""
echo "Applied plan:"
echo "  ${PLAN_FILE}"