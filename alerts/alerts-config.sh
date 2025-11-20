#!/bin/bash

# Configuration script for Slack and Email alerts
# Run this first to set up your credentials

echo "================================="
echo "  DevSecOps Alert Configuration"
echo "================================="
echo ""

# Create alerts directory
mkdir -p ~/Documents/DevSecOps/Project/devsecops-project/alerts

CONFIG_FILE=~/Documents/DevSecOps/Project/devsecops-project/alerts/alert-config.env

echo "This script will help you configure Slack and Email alerts."
echo ""

# Slack Configuration
echo "--- Slack Configuration ---"
echo ""
echo "To get a Slack Webhook URL:"
echo "1. Go to https://api.slack.com/apps"
echo "2. Create a new app"
echo "3. Enable 'Incoming Webhooks'"
echo "4. Create a webhook for your channel"
echo "5. Copy the Webhook URL"
echo ""
read -p "Enter your Slack Webhook URL (or press Enter to skip): " SLACK_URL

# Email Configuration
echo ""
echo "--- Email Configuration ---"
echo ""
echo "For Gmail, you need an 'App Password':"
echo "1. Go to https://myaccount.google.com/security"
echo "2. Enable 2-Step Verification"
echo "3. Generate an App Password"
echo "4. Use that password (not your regular Gmail password)"
echo ""
read -p "Enter sender email address: " SENDER_EMAIL
read -sp "Enter email app password: " SENDER_PASSWORD
echo ""
read -p "Enter recipient email address: " RECIPIENT_EMAIL

# Save configuration
cat > "$CONFIG_FILE" << EOF
# DevSecOps Alert Configuration
# Generated on $(date)

# Slack Configuration
export SLACK_WEBHOOK_URL="$SLACK_URL"

# Email Configuration
export SMTP_SERVER="smtp.gmail.com"
export SMTP_PORT="587"
export SENDER_EMAIL="$SENDER_EMAIL"
export SENDER_PASSWORD="$SENDER_PASSWORD"
export RECIPIENT_EMAIL="$RECIPIENT_EMAIL"
EOF

chmod 600 "$CONFIG_FILE"

echo ""
echo "✓ Configuration saved to: $CONFIG_FILE"
echo ""
echo "To use these settings, run:"
echo "  source $CONFIG_FILE"
echo ""
echo "Or add to your .bashrc:"
echo "  echo 'source $CONFIG_FILE' >> ~/.bashrc"
echo ""