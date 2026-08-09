#!/usr/bin/env bash

set -euo pipefail

ENVIRONMENT="${1:-}"

if [[ -z "$ENVIRONMENT" ]]; then
  echo "Usage: $0 <environment>"
  echo "Example: $0 production"
  exit 1
fi

ENV_DIR="environments/${ENVIRONMENT}"

echo "========================================"
echo "Terraform Drift Detection"
echo "Environment: ${ENVIRONMENT}"
echo "Directory:   ${ENV_DIR}"
echo "========================================"

# ============================================================
# 1. Validate environment
# ============================================================

if [[ ! -d "$ENV_DIR" ]]; then
  echo "ERROR: Environment directory not found:"
  echo "       ${ENV_DIR}"
  exit 1
fi

if [[ ! -f "${ENV_DIR}/${ENVIRONMENT}.tfvars" ]]; then
  echo "ERROR: Variables file not found:"
  echo "       ${ENV_DIR}/${ENVIRONMENT}.tfvars"
  exit 1
fi

# ============================================================
# 2. Check Terraform
# ============================================================

command -v terraform >/dev/null 2>&1 || {
  echo "ERROR: terraform is not installed."
  exit 1
}

# ============================================================
# 3. Terraform Init
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
# 4. Terraform Validate
# ============================================================

echo ""
echo "========================================"
echo "STEP 2: Terraform Validate"
echo "========================================"

terraform validate \
  -no-color

# ============================================================
# 5. Drift Detection
# ============================================================

echo ""
echo "========================================"
echo "STEP 3: Terraform Drift Detection"
echo "========================================"

set +e

terraform plan \
  -input=false \
  -no-color \
  -var-file="${ENVIRONMENT}.tfvars" \
  -detailed-exitcode

EXIT_CODE=$?

set -e

# ============================================================
# 6. Handle Terraform exit code
# ============================================================

case "$EXIT_CODE" in

  0)
    echo ""
    echo "========================================"
    echo "NO DRIFT DETECTED"
    echo "========================================"

    exit 0
    ;;

  1)
    echo ""
    echo "========================================"
    echo "TERRAFORM PLAN FAILED"
    echo "========================================"

    exit 1
    ;;

  2)
    echo ""
    echo "========================================"
    echo "DRIFT DETECTED"
    echo "========================================"

    echo ""
    echo "Infrastructure differs from Terraform configuration."
    echo ""
    echo "Do NOT automatically apply changes."
    echo "Investigate the drift before making any changes."

    exit 2
    ;;

  *)
    echo ""
    echo "ERROR: Unexpected Terraform exit code: ${EXIT_CODE}"

    exit "$EXIT_CODE"
    ;;

esac