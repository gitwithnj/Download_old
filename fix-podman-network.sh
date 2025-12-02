#!/bin/bash
# Script to fix Podman network issues

set -e

echo "=== Podman Network Troubleshooting ==="
echo ""

# Check Podman machine status
echo "1. Checking Podman machine status..."
podman machine list

echo ""
echo "2. Attempting to fix network issues..."
echo ""

# Option 1: Restart Podman machine
echo "Option 1: Restarting Podman machine..."
podman machine stop 2>/dev/null || true
sleep 2
podman machine start

echo ""
echo "Waiting for machine to be ready..."
sleep 5

# Test connection
echo ""
echo "3. Testing Docker Hub connection..."
podman pull docker.io/library/hello-world:latest 2>&1 | head -5

echo ""
echo "=== Troubleshooting Steps ==="
echo ""
echo "If the issue persists, try:"
echo ""
echo "1. Restart your Mac (resets network stack)"
echo ""
echo "2. Check DNS settings:"
echo "   podman machine inspect"
echo ""
echo "3. Use Docker Desktop instead:"
echo "   - Install from: https://www.docker.com/products/docker-desktop"
echo "   - Then use 'docker' commands instead of 'podman'"
echo ""
echo "4. Build in AWS CodeBuild (no local Docker needed):"
echo "   - Push code to GitHub"
echo "   - Use AWS CodeBuild to build the image"
echo ""
echo "5. Use pre-built base image workaround:"
echo "   - Download nginx:alpine manually"
echo "   - Or use a different base image"


