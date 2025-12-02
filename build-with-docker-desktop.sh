#!/bin/bash
# Build script using Podman

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

# Build image
echo "Building image..."
podman build -t resume-app:latest .

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


