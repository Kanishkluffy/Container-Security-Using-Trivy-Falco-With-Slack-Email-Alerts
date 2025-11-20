#!/bin/bash

# Slack Alert Script for DevSecOps Project
# Sends Trivy and Falco alerts to Slack

set -e

# Configuration - REPLACE WITH YOUR SLACK WEBHOOK URL
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-Your_Slack_Webhook_URL_Here}"

# Colors for Slack messages
COLOR_CRITICAL="#FF0000"  # Red
COLOR_HIGH="#FF6600"      # Orange
COLOR_WARNING="#FFCC00"   # Yellow
COLOR_INFO="#00CC00"      # Green

# Function to send message to Slack
send_slack_message() {
    local title="$1"
    local message="$2"
    local color="$3"
    local priority="${4:-INFO}"
    
    local payload=$(cat <<EOF
{
    "username": "DevSecOps Security Bot",
    "icon_emoji": ":shield:",
    "attachments": [
        {
            "color": "$color",
            "title": "$title",
            "text": "$message",
            "fields": [
                {
                    "title": "Priority",
                    "value": "$priority",
                    "short": true
                },
                {
                    "title": "Timestamp",
                    "value": "$(date '+%Y-%m-%d %H:%M:%S')",
                    "short": true
                },
                {
                    "title": "Host",
                    "value": "$(hostname)",
                    "short": true
                },
                {
                    "title": "Project",
                    "value": "DevSecOps Container Security",
                    "short": true
                }
            ],
            "footer": "Trivy + Falco Security Monitoring",
            "footer_icon": "https://avatars.githubusercontent.com/u/15859888?s=48&v=4"
        }
    ]
}
EOF
)
    
    curl -X POST "$SLACK_WEBHOOK_URL" \
        -H 'Content-Type: application/json' \
        -d "$payload" \
        --silent --output /dev/null
    
    echo "✓ Alert sent to Slack"
}

# Function to send Trivy scan results
send_trivy_alert() {
    local image_name="$1"
    local critical_count="$2"
    local high_count="$3"
    
    local severity="INFO"
    local color="$COLOR_INFO"
    
    if [ "$critical_count" -gt 0 ]; then
        severity="CRITICAL"
        color="$COLOR_CRITICAL"
    elif [ "$high_count" -gt 5 ]; then
        severity="HIGH"
        color="$COLOR_HIGH"
    fi
    
    local message="*Trivy Vulnerability Scan Results*\n\n"
    message+="Image: \`$image_name\`\n"
    message+="🔴 Critical: $critical_count\n"
    message+="🟠 High: $high_count\n\n"
    
    if [ "$critical_count" -gt 0 ] || [ "$high_count" -gt 5 ]; then
        message+="⚠️ *Action Required:* Review and patch vulnerabilities immediately!"
    else
        message+="✅ Security scan passed with acceptable risk level."
    fi
    
    send_slack_message "🔍 Container Security Scan Alert" "$message" "$color" "$severity"
}

# Function to send Falco runtime alert
send_falco_alert() {
    local alert_type="$1"
    local details="$2"
    local container_name="$3"
    
    local message="*Falco Runtime Security Alert*\n\n"
    message+="🚨 Alert Type: \`$alert_type\`\n"
    message+="📦 Container: \`$container_name\`\n"
    message+="📋 Details: $details\n\n"
    message+="⚠️ *Immediate Investigation Required!*"
    
    send_slack_message "🚨 Runtime Security Threat Detected" "$message" "$COLOR_CRITICAL" "CRITICAL"
}

# Main execution
case "${1:-help}" in
    trivy)
        IMAGE_NAME="${2:-vulnerable-app:latest}"
        CRITICAL="${3:-0}"
        HIGH="${4:-0}"
        send_trivy_alert "$IMAGE_NAME" "$CRITICAL" "$HIGH"
        ;;
    
    falco)
        ALERT_TYPE="${2:-Unknown Alert}"
        DETAILS="${3:-No details provided}"
        CONTAINER="${4:-unknown}"
        send_falco_alert "$ALERT_TYPE" "$DETAILS" "$CONTAINER"
        ;;
    
    test)
        send_slack_message "🧪 Test Alert" "This is a test message from DevSecOps Security Bot" "$COLOR_INFO" "INFO"
        ;;
    
    *)
        echo "DevSecOps Slack Alert Script"
        echo ""
        echo "Usage:"
        echo "  $0 trivy <image_name> <critical_count> <high_count>"
        echo "  $0 falco <alert_type> <details> <container_name>"
        echo "  $0 test"
        echo ""
        echo "Example:"
        echo "  $0 trivy vulnerable-app:latest 5 10"
        echo "  $0 falco 'Shell Execution' 'bash spawned in container' 'devsecops-demo'"
        echo "  $0 test"
        echo ""
        echo "Configuration:"
        echo "  Set SLACK_WEBHOOK_URL environment variable or edit this script"
        exit 1
        ;;
esac