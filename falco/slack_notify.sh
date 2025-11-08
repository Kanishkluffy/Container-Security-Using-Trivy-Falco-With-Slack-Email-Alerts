#!/bin/bash
# falco calls this script with the alert text as argument
# Usage: falco_notify.sh "Falco alert text"

WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"
if [ -z "$WEBHOOK_URL" ]; then
  echo "SLACK_WEBHOOK_URL not set; printed alert: $1"
  exit 0
fi

payload="{\"text\": \"$1\"}"
curl -s -X POST -H 'Content-type: application/json' --data "$payload" "$WEBHOOK_URL" > /dev/null
