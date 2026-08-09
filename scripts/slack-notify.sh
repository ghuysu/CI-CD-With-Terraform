#!/usr/bin/env bash

set -euo pipefail

ENVIRONMENT="${1:-}"
STATUS="${2:-}"
MESSAGE="${3:-}"

if [[ -z "$ENVIRONMENT" || -z "$STATUS" || -z "$MESSAGE" ]]; then
  echo "Usage:"
  echo "$0 <environment> <status> <message>"
  echo ""
  echo "Example:"
  echo "$0 production success 'Terraform apply completed successfully'"
  exit 1
fi

# ============================================================
# 1. Validate Slack Webhook
# ============================================================

if [[ -z "${SLACK_WEBHOOK_URL:-}" ]]; then
  echo "ERROR: SLACK_WEBHOOK_URL is not set."
  exit 1
fi

# ============================================================
# 2. Select status icon
# ============================================================

case "$STATUS" in

  success)
    EMOJI=":white_check_mark:"
    ;;

  failure)
    EMOJI=":x:"
    ;;

  warning)
    EMOJI=":warning:"
    ;;

  info)
    EMOJI=":information_source:"
    ;;

  *)
    EMOJI=":grey_question:"
    ;;

esac

# ============================================================
# 3. GitHub Actions metadata
# ============================================================

REPOSITORY="${GITHUB_REPOSITORY:-unknown}"
BRANCH="${GITHUB_REF_NAME:-unknown}"
COMMIT="${GITHUB_SHA:-unknown}"
RUN_URL=""

if [[ -n "${GITHUB_SERVER_URL:-}" && -n "${GITHUB_RUN_ID:-}" ]]; then
  RUN_URL="${GITHUB_SERVER_URL}/${REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"
fi

# Short commit SHA

SHORT_COMMIT="${COMMIT:0:7}"

# ============================================================
# 4. Build Slack message
# ============================================================

if [[ -n "$RUN_URL" ]]; then

  PAYLOAD=$(cat <<EOF
{
  "text": "${EMOJI} *Terraform ${STATUS}*

*Environment:* ${ENVIRONMENT}
*Message:* ${MESSAGE}
*Repository:* ${REPOSITORY}
*Branch:* ${BRANCH}
*Commit:* ${SHORT_COMMIT}
*Workflow:* ${RUN_URL}"
}
EOF
)

else

  PAYLOAD=$(cat <<EOF
{
  "text": "${EMOJI} *Terraform ${STATUS}*

*Environment:* ${ENVIRONMENT}
*Message:* ${MESSAGE}
*Repository:* ${REPOSITORY}
*Branch:* ${BRANCH}
*Commit:* ${SHORT_COMMIT}"
}
EOF
)

fi

# ============================================================
# 5. Send notification
# ============================================================

echo "Sending Slack notification..."

curl \
  --fail \
  --silent \
  --show-error \
  --request POST \
  --header "Content-Type: application/json" \
  --data "$PAYLOAD" \
  "$SLACK_WEBHOOK_URL"

echo ""
echo "Slack notification sent successfully."