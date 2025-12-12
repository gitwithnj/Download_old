#!/bin/bash
# Quick script to load localhost/nagadevj-repo:9537e86ca1fc into minikube

IMAGE_NAME="localhost/nagadevj-repo"
IMAGE_ID="9537e86ca1fc"

echo "Loading $IMAGE_NAME (ID: $IMAGE_ID) into Minikube..."

# Check if image exists in podman by ID
FULL_IMAGE=$(podman images --format "{{.ID}} {{.Repository}}:{{.Tag}}" | grep "$IMAGE_ID" | awk '{print $2}')

if [ -n "$FULL_IMAGE" ] && [ "$FULL_IMAGE" != "<none>:<none>" ]; then
    echo "Found image: $FULL_IMAGE"
    minikube image load "$FULL_IMAGE"
elif podman images "$IMAGE_NAME" &>/dev/null; then
    echo "Found image: $IMAGE_NAME"
    minikube image load "$IMAGE_NAME"
else
    echo "Image not found in Podman. Attempting to load anyway..."
    # Try direct load - minikube might find it
    minikube image load "$IMAGE_NAME" 2>&1 || \
    minikube image load "$IMAGE_ID" 2>&1 || {
        echo ""
        echo "Image not found. Please ensure the image exists in Podman first."
        echo ""
        echo "To import from tar:"
        echo "  podman load -i <image-file.tar>"
        echo ""
        echo "To pull from registry:"
        echo "  podman pull $IMAGE_NAME"
        echo ""
        echo "Then run this script again."
        exit 1
    }
fi

echo ""
echo "✓ Image loaded successfully!"
echo ""
echo "Verify with: minikube image ls"
echo "Or: minikube ssh -- podman images"
