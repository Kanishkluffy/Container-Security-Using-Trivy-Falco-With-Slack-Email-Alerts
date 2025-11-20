#!/bin/bash

# Install Falco on Ubuntu - Updated for 2024
# Based on official Falco documentation

set -e

echo "========================================="
echo "  Installing Falco on Ubuntu"
echo "========================================="
echo ""

# Step 1: Install dependencies
echo "[1/6] Installing dependencies..."
sudo apt-get update
sudo apt-get install -y dialog curl gpg

# Step 2: Add Falco GPG key
echo "[2/6] Adding Falco GPG key..."
curl -fsSL https://falco.org/repo/falcosecurity-packages.asc | \
  sudo gpg --dearmor -o /usr/share/keyrings/falco-archive-keyring.gpg

# Step 3: Add Falco repository
echo "[3/6] Adding Falco repository..."
sudo bash -c 'cat << EOF > /etc/apt/sources.list.d/falcosecurity.list
deb [signed-by=/usr/share/keyrings/falco-archive-keyring.gpg] https://download.falco.org/packages/deb stable main
EOF'

# Step 4: Update package list
echo "[4/6] Updating package list..."
sudo apt-get update

# Step 5: Install Falco
echo "[5/6] Installing Falco..."
echo ""
echo "IMPORTANT: During installation:"
echo "  - Select 'Modern eBPF' as the driver (recommended)"
echo "  - Choose 'Yes' for automatic ruleset updates (optional)"
echo ""
read -p "Press Enter to continue with installation..."

sudo apt-get install -y falco

# Step 6: Install falcoctl driver
echo "[6/6] Installing Falco driver..."
sudo falcoctl driver install

echo ""
echo "✓ Falco installation complete!"
echo ""
echo "Verify installation:"
echo "  falco --version"
echo ""
echo "Check which service is enabled:"
echo "  sudo systemctl list-units --all | grep falco"
echo ""
echo "Next steps:"
echo "  1. Run: cd ~/Documents/DevSecOps/Project/devsecops-project/falco"
echo "  2. Run: ./setup-falco.sh"
echo ""