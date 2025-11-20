#!/bin/bash

# Run Falco manually for DevSecOps project
# Use this if systemd service doesn't work

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=================================${NC}"
echo -e "${BLUE}  Starting Falco${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""

# Check if Falco is installed
if ! command -v falco &> /dev/null; then
    echo -e "${YELLOW}Falco not installed. Run: ./install-falco.sh${NC}"
    exit 1
fi

# Check if custom rules exist
if [ ! -f /etc/falco/rules.d/falco-custom-rules.yaml ]; then
    echo -e "${YELLOW}Custom rules not installed. Run: sudo ./setup-falco.sh${NC}"
    exit 1
fi

# Create log directory
sudo mkdir -p /var/log/falco

echo -e "${GREEN}✓ Starting Falco...${NC}"
echo -e "${BLUE}Monitoring container: devsecops-demo-app${NC}"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
echo ""

# Run Falco
sudo falco \
    -c /etc/falco/falco.yaml \
    -r /etc/falco/rules.d/falco-custom-rules.yaml \
    -o json_output=true \
    -o file_output.enabled=true \
    -o file_output.filename=/var/log/falco/events.txt
