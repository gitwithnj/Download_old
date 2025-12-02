#!/bin/bash
# Build script using Podman with network fix attempts

set -e

echo "=== Building with Podman ==="
echo ""

# Check if Podman is available
if ! command -v podman &> /dev/null; then
    echo "❌ Podman not found!"
    echo ""
    echo "Please install Podman:"
    echo "  macOS: brew install podman"
    echo "  Then run: podman machine init && podman machine start"
    exit 1
fi

# Check if Podman machine is running
if ! podman info &> /dev/null; then
    echo "⚠ Podman machine may not be running"
    echo ""
    echo "Attempting to start Podman machine..."
    podman machine start 2>/dev/null || {
        echo "❌ Failed to start Podman machine"
        echo ""
        echo "Please run:"
        echo "  podman machine init  (if not initialized)"
        echo "  podman machine start"
        exit 1
    }
fi

echo "✓ Podman is available and running"
echo ""

# Try to fix DNS/network issues
echo "Attempting to fix network connectivity..."
podman machine ssh "sudo systemctl restart systemd-resolved" 2>/dev/null || true
sleep 2

# Test connectivity
echo "Testing Docker Hub connectivity..."
if podman pull docker.io/library/hello-world:latest 2>&1 | grep -q "Error"; then
    echo "⚠ Network issue detected. Trying alternative solutions..."
    echo ""
    echo "Option 1: Use alternative Dockerfile (Ubuntu base)"
    read -p "Use alternative Dockerfile? (y/n): " use_alt
    
    if [ "$use_alt" = "y" ] || [ "$use_alt" = "Y" ]; then
        echo "Building with alternative Dockerfile..."
        podman build -f Dockerfile.alternative -t resume-app:latest .
    else
        echo ""
        echo "Network connectivity issue. Please try:"
        echo "1. Restart Podman machine: podman machine stop && podman machine start"
        echo "2. Restart your Mac"
        echo "3. Use alternative Dockerfile: podman build -f Dockerfile.alternative -t resume-app:latest ."
        echo "4. Build in AWS CodeBuild (no local setup needed)"
        exit 1
    fi
else
    echo "✓ Network connectivity OK"
    echo ""
    echo "Building image..."
    podman build -t resume-app:latest .
fi

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Build successful!"
    echo ""
    echo "To test locally:"
    echo "  podman run -d -p 8080:80 --name resume-app resume-app:latest"
    echo "  Then open: http://localhost:8080"
    echo ""
    echo "To push to Docker Hub:"
    echo "  podman login docker.io"
    echo "  podman tag resume-app:latest yourusername/resume-app:latest"
    echo "  podman push yourusername/resume-app:latest"
else
    echo ""
    echo "❌ Build failed!"
    exit 1
fi

