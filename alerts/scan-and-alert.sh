#!/bin/bash

# Integrated Security Scanner with Alerts
# Runs Trivy scan and sends alerts to Slack/Email

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

IMAGE_NAME="${1:-vulnerable-app:latest}"
PROJECT_DIR="$HOME/Documents/DevSecOps/Project/devsecops-project"

# Load alert configuration
if [ -f "$PROJECT_DIR/alerts/alert-config.env" ]; then
    source "$PROJECT_DIR/alerts/alert-config.env"
fi

echo -e "${BLUE}=================================${NC}"
echo -e "${BLUE}  DevSecOps Security Scanner${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""
echo -e "${YELLOW}Scanning: $IMAGE_NAME${NC}"
echo ""

# Run Trivy scan
echo -e "${BLUE}[1/3] Running Trivy vulnerability scan...${NC}"
trivy image --format json --output /tmp/trivy-result.json "$IMAGE_NAME" 2>/dev/null

# Parse results
CRITICAL=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity=="CRITICAL")] | length' /tmp/trivy-result.json 2>/dev/null || echo "0")
HIGH=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity=="HIGH")] | length' /tmp/trivy-result.json 2>/dev/null || echo "0")
MEDIUM=$(jq '[.Results[]?.Vulnerabilities[]? | select(.Severity=="MEDIUM")] | length' /tmp/trivy-result.json 2>/dev/null || echo "0")

echo ""
echo -e "${BLUE}Scan Results:${NC}"
echo -e "${RED}  CRITICAL: $CRITICAL${NC}"
echo -e "${YELLOW}  HIGH:     $HIGH${NC}"
echo -e "${BLUE}  MEDIUM:   $MEDIUM${NC}"
echo ""

# Send Slack alert
if [ ! -z "$SLACK_WEBHOOK_URL" ] && [ "$SLACK_WEBHOOK_URL" != "YOUR_SLACK_WEBHOOK_URL_HERE" ]; then
    echo -e "${BLUE}[2/3] Sending Slack alert...${NC}"
    cd "$PROJECT_DIR/alerts"
    ./slack-alert.sh trivy "$IMAGE_NAME" "$CRITICAL" "$HIGH"
else
    echo -e "${YELLOW}[2/3] Slack not configured, skipping...${NC}"
fi

# Send Email alert
if [ ! -z "$SENDER_EMAIL" ] && [ "$SENDER_EMAIL" != "your-email@gmail.com" ]; then
    echo -e "${BLUE}[3/3] Sending Email alert...${NC}"
    cd "$PROJECT_DIR/alerts"
    python3 email-alert.py trivy "$IMAGE_NAME" "$CRITICAL" "$HIGH" "$MEDIUM"
else
    echo -e "${YELLOW}[3/3] Email not configured, skipping...${NC}"
fi

echo ""
echo -e "${GREEN}=================================${NC}"
echo -e "${GREEN}  Scan Complete!${NC}"
echo -e "${GREEN}=================================${NC}"
echo ""

# Exit with appropriate code
if [ "$CRITICAL" -gt 0 ]; then
    echo -e "${RED}❌ CRITICAL vulnerabilities found!${NC}"
    exit 1
elif [ "$HIGH" -gt 5 ]; then
    echo -e "${YELLOW}⚠️  Multiple HIGH vulnerabilities found!${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Security check passed${NC}"
    exit 0
fi