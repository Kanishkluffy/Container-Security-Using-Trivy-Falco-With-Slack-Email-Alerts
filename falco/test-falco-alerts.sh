#!/bin/bash

# Test Falco alerts by triggering various suspicious activities

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CONTAINER_NAME="devsecops-demo-app"
APP_URL="http://localhost:5000"

echo -e "${BLUE}=================================${NC}"
echo -e "${BLUE}  Falco Alert Test Suite${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""

# Check if container is running
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo -e "${YELLOW}Container $CONTAINER_NAME is not running!${NC}"
    echo "Start it with: docker run -d -p 5000:5000 --name devsecops-demo-app vulnerable-app:latest"
    exit 1
fi

# Check if app is responding
if ! curl -s "$APP_URL/health" > /dev/null 2>&1; then
    echo -e "${RED}Application is not responding at $APP_URL${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Container is running${NC}"
echo -e "${GREEN}✓ Application is responsive${NC}"
echo ""

# Function to trigger test and wait
trigger_test() {
    local test_name=$1
    local command=$2
    
    echo -e "${YELLOW}[TEST] $test_name${NC}"
    eval "$command"
    sleep 2
    echo ""
}

# Test 1: Shell execution (should trigger "Shell Spawned in Container")
echo -e "${BLUE}Starting Falco tests...${NC}"
echo ""

trigger_test "Shell Execution Detection" \
    "curl -s -X POST $APP_URL/execute -H 'Content-Type: application/json' -d '{\"command\":\"whoami\"}' | jq ."

trigger_test "Sensitive File Read" \
    "curl -s -X POST $APP_URL/file -H 'Content-Type: application/json' -d '{\"filename\":\"/etc/passwd\"}' | jq -r .content | head -5"

trigger_test "Network Command Execution" \
    "curl -s -X POST $APP_URL/execute -H 'Content-Type: application/json' -d '{\"command\":\"ps aux\"}' | jq ."

trigger_test "Multiple Shell Commands" \
    "curl -s -X POST $APP_URL/execute -H 'Content-Type: application/json' -d '{\"command\":\"id\"}' | jq ."

echo -e "${GREEN}=================================${NC}"
echo -e "${GREEN}  Tests Complete!${NC}"
echo -e "${GREEN}=================================${NC}"
echo ""
echo -e "${BLUE}View Falco alerts with:${NC}"
echo "  sudo journalctl -fu falco"
echo "  sudo tail -f /var/log/falco/events.txt"
echo ""
echo -e "${BLUE}Expected alerts:${NC}"
echo "  - Shell Spawned in Container"
echo "  - Suspicious Command Execution"
echo "  - Read Sensitive File"
echo "  - Python Subprocess Execution"
echo ""
echo -e "${YELLOW}Check Falco logs now to see the alerts!${NC}"