#!/bin/bash
# Script to fix Docker Desktop installation conflict

set -e

echo "=== Fixing Docker Desktop Installation ==="
echo ""

# Check if file exists
if [ -f "/usr/local/bin/docker-credential-desktop" ]; then
    echo "Found conflicting binary at /usr/local/bin/docker-credential-desktop"
    echo ""
    read -p "Remove the conflicting binary? (y/n): " confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        echo "Removing conflicting binary..."
        sudo rm -f /usr/local/bin/docker-credential-desktop
        echo "✓ Removed"
    else
        echo "Skipping removal"
    fi
else
    echo "No conflicting binary found at /usr/local/bin/docker-credential-desktop"
fi

echo ""
echo "=== Alternative Solutions ==="
echo ""
echo "Option 1: Remove manually"
echo "  sudo rm -f /usr/local/bin/docker-credential-desktop"
echo "  brew install --cask docker"
echo ""
echo "Option 2: Clean install"
echo "  brew uninstall --cask docker"
echo "  sudo rm -f /usr/local/bin/docker-credential-desktop"
echo "  brew install --cask docker"
echo ""
echo "Option 3: Use Docker Desktop directly"
echo "  Download from: https://www.docker.com/products/docker-desktop"
echo "  Install the .dmg file manually"


