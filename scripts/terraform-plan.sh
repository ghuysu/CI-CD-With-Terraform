#!/usr/bin/env bash

set -euo pipefail

ENVIRONMENT="${1:-}"

if [[ -z "$ENVIRONMENT" ]]; then
  echo "Usage: $0 <environment>"
  echo "Example: $0 staging"
  exit 1
fi

ENV_DIR="environments/${ENVIRONMENT}"
PLAN_FILE="tfplan-${ENVIRONMENT}"

echo "========================================"
echo "Terraform CI Pipeline"
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

if [[ ! -f "${ENV_DIR}/${ENVIRONMENT}.tfvars" ]]; then
  echo "ERROR: Variables file not found:"
  echo "       ${ENV_DIR}/${ENVIRONMENT}.tfvars"
  exit 1
fi

# ============================================================
# 2. Check required tools
# ============================================================

echo ""
echo "==> Checking required tools..."

command -v terraform >/dev/null 2>&1 || {
  echo "ERROR: terraform is not installed."
  exit 1
}

command -v tflint >/dev/null 2>&1 || {
  echo "ERROR: tflint is not installed."
  exit 1
}

command -v tfsec >/dev/null 2>&1 || {
  echo "ERROR: tfsec is not installed."
  exit 1
}

echo "Terraform: $(terraform version -json | grep -o '"terraform_version":"[^"]*"' | cut -d'"' -f4)"
echo "TFLint:    $(tflint --version | head -n 1)"
echo "tfsec:     $(tfsec --version | head -n 1)"

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
# 4. Terraform Format Check
# ============================================================

echo ""
echo "========================================"
echo "STEP 2: Terraform Format Check"
echo "========================================"

terraform fmt \
  -check \
  -recursive \
  -diff \
  -no-color

echo "Terraform format check passed."

# ============================================================
# 5. Terraform Validate
# ============================================================

echo ""
echo "========================================"
echo "STEP 3: Terraform Validate"
echo "========================================"

terraform validate \
  -no-color

echo "Terraform validation passed."

# ============================================================
# 6. TFLint
# ============================================================

echo ""
echo "========================================"
echo "STEP 4: TFLint"
echo "========================================"

if [[ -f "../../.tflint.hcl" ]]; then

  tflint \
    --config="../../.tflint.hcl"

else

  echo "No .tflint.hcl found."
  echo "Running TFLint with default configuration."

  tflint

fi

echo "TFLint passed."

# ============================================================
# 7. tfsec
# ============================================================

echo ""
echo "========================================"
echo "STEP 5: tfsec Security Scan"
echo "========================================"

tfsec \
  . \
  --no-color

echo "tfsec security scan passed."

# ============================================================
# 8. Terraform Plan
# ============================================================

echo ""
echo "========================================"
echo "STEP 6: Terraform Plan"
echo "========================================"

terraform plan \
  -input=false \
  -no-color \
  -var-file="${ENVIRONMENT}.tfvars" \
  -out="../../${PLAN_FILE}"

echo ""
echo "========================================"
echo "Terraform Plan Completed Successfully"
echo "========================================"

echo ""
echo "Environment:"
echo "  ${ENVIRONMENT}"

echo ""
echo "Plan artifact:"
echo "  ${PLAN_FILE}"

echo ""
echo "The plan can be reviewed before apply."