#!/bin/bash
# Build script using alternative Dockerfile (Ubuntu base)
# Use this if nginx:alpine pull fails due to network issues

set -e

echo "=== Building with Alternative Dockerfile (Ubuntu base) ==="
echo ""

# Check if Podman is available
if ! command -v podman &> /dev/null; then
    echo "❌ Podman not found!"
    exit 1
fi

# Check if Podman machine is running
if ! podman info &> /dev/null; then
    echo "⚠ Starting Podman machine..."
    podman machine start 2>/dev/null || {
        echo "❌ Failed to start Podman machine"
        exit 1
    }
fi

echo "✓ Podman is available"
echo ""

# Check if alternative Dockerfile exists
if [ ! -f "Dockerfile.alternative" ]; then
    echo "❌ Dockerfile.alternative not found!"
    exit 1
fi

echo "Building image with Ubuntu base (may take longer but more reliable)..."
podman build -f Dockerfile.alternative -t resume-app:latest .

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Build successful!"
    echo ""
    echo "To test locally:"
    echo "  podman run -d -p 8080:80 --name resume-app resume-app:latest"
    echo "  Then open: http://localhost:8080"
else
    echo ""
    echo "❌ Build failed!"
    exit 1
fi

