#!/bin/bash

# Setup Falco with custom rules for DevSecOps project

set -e

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=================================${NC}"
echo -e "${BLUE}  Falco Setup Script${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""

# Check if Falco is installed
if ! command -v falco &> /dev/null; then
    echo -e "${YELLOW}Falco is not installed. Run ./install-falco.sh first${NC}"
    exit 1
fi

# Copy custom rules
echo -e "${BLUE}[1/4] Installing custom Falco rules...${NC}"
sudo cp falco-custom-rules.yaml /etc/falco/rules.d/

# Backup original config
if [ ! -f /etc/falco/falco.yaml.backup ]; then
    echo -e "${BLUE}[2/4] Backing up original Falco config...${NC}"
    sudo cp /etc/falco/falco.yaml /etc/falco/falco.yaml.backup
fi

# Configure Falco for JSON output (easier for alerts)
echo -e "${BLUE}[3/4] Configuring Falco...${NC}"
sudo bash -c 'cat >> /etc/falco/falco.yaml << EOF

# Custom configuration for DevSecOps project
json_output: true
json_include_output_property: true
log_level: info

# File output for alerts
file_output:
  enabled: true
  keep_alive: false
  filename: /var/log/falco/events.txt

# Program output for custom alerting
program_output:
  enabled: false
  keep_alive: false
  program: |
    jq -r ".output" | while read line; do
      echo "[FALCO ALERT] $line"
    done
EOF'

# Create log directory
sudo mkdir -p /var/log/falco
sudo chown root:root /var/log/falco

# Restart Falco
echo -e "${BLUE}[4/4] Restarting Falco service...${NC}"
sudo systemctl restart falco
sleep 3

# Check status
if sudo systemctl is-active --quiet falco; then
    echo ""
    echo -e "${GREEN}✓ Falco is running successfully!${NC}"
    echo ""
    echo -e "${BLUE}Configuration:${NC}"
    echo "  - Custom rules: /etc/falco/rules.d/falco-custom-rules.yaml"
    echo "  - Config file: /etc/falco/falco.yaml"
    echo "  - Log file: /var/log/falco/events.txt"
    echo ""
    echo -e "${BLUE}Useful commands:${NC}"
    echo "  - View logs: sudo journalctl -fu falco"
    echo "  - Check alerts: sudo tail -f /var/log/falco/events.txt"
    echo "  - Test rules: trigger /execute endpoint in the app"
    echo ""
else
    echo -e "${RED}✗ Falco failed to start. Check logs:${NC}"
    echo "  sudo journalctl -xe -u falco"
    exit 1
fi