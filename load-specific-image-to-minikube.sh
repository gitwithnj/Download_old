#!/bin/bash
# Script to load a specific image into Minikube

set -e

IMAGE_NAME="${1:-localhost/nagadevj-repo}"
IMAGE_ID="${2:-9537e86ca1fc}"

echo "=== Loading Image into Minikube ==="
echo "Image: $IMAGE_NAME"
echo "ID: $IMAGE_ID"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if Podman is available
if ! command -v podman &> /dev/null; then
    echo -e "${RED}❌ Podman not found!${NC}"
    exit 1
fi

# Check if Minikube is available
if ! command -v minikube &> /dev/null; then
    echo -e "${RED}❌ Minikube not found!${NC}"
    exit 1
fi

# Check if Minikube is running
if ! minikube status &> /dev/null; then
    echo -e "${YELLOW}⚠ Starting Minikube...${NC}"
    minikube start --driver=podman 2>/dev/null || {
        echo -e "${RED}❌ Failed to start Minikube${NC}"
        exit 1
    }
fi

echo -e "${GREEN}✓ Minikube is running${NC}"
echo ""

# Try to find the image in Podman
echo "Searching for image in Podman..."
FOUND_IMAGE=""

# Try by full name
if podman images "$IMAGE_NAME" --format "{{.Repository}}:{{.Tag}}" 2>/dev/null | grep -q .; then
    FOUND_IMAGE=$(podman images "$IMAGE_NAME" --format "{{.Repository}}:{{.Tag}}" | head -1)
    echo -e "${GREEN}✓ Found image: $FOUND_IMAGE${NC}"
# Try by ID (partial match)
elif podman images --format "{{.ID}} {{.Repository}}:{{.Tag}}" | grep -q "$IMAGE_ID"; then
    FOUND_IMAGE=$(podman images --format "{{.Repository}}:{{.Tag}}" | grep -B1 "$IMAGE_ID" | head -1 | awk '{print $1}')
    echo -e "${GREEN}✓ Found image by ID: $FOUND_IMAGE${NC}"
# Try by ID only
elif podman images --format "{{.ID}}" | grep -q "$IMAGE_ID"; then
    FULL_ID=$(podman images --format "{{.ID}}" | grep "$IMAGE_ID" | head -1)
    FOUND_IMAGE=$(podman images --format "{{.Repository}}:{{.Tag}}" | sed -n "$(podman images --format "{{.ID}}" | grep -n "$IMAGE_ID" | head -1 | cut -d: -f1)p")
    if [ -z "$FOUND_IMAGE" ] || [ "$FOUND_IMAGE" == "<none>:<none>" ]; then
        FOUND_IMAGE="$IMAGE_NAME:latest"
    fi
    echo -e "${GREEN}✓ Found image by ID: $FULL_ID${NC}"
    echo -e "${YELLOW}⚠ Using name: $FOUND_IMAGE${NC}"
else
    echo -e "${YELLOW}⚠ Image not found in Podman${NC}"
    echo ""
    echo "Available Podman images:"
    podman images
    echo ""
    echo "Options:"
    echo "1. If you have a tar file, import it first:"
    echo "   podman load -i <image-file.tar>"
    echo "2. If image is in a registry, pull it first:"
    echo "   podman pull $IMAGE_NAME"
    echo "3. If you need to build it, build first:"
    echo "   podman build -t $IMAGE_NAME ."
    echo ""
    read -p "Do you want to try loading anyway? (y/n): " continue_load
    if [ "$continue_load" != "y" ] && [ "$continue_load" != "Y" ]; then
        exit 1
    fi
    FOUND_IMAGE="$IMAGE_NAME:latest"
fi

echo ""
echo "Loading image into Minikube..."

# Method 1: Direct load by name
if [ -n "$FOUND_IMAGE" ] && [ "$FOUND_IMAGE" != "$IMAGE_NAME:latest" ]; then
    echo -n "Loading $FOUND_IMAGE... "
    if minikube image load "$FOUND_IMAGE" 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
        echo ""
        echo -e "${GREEN}✓ Successfully loaded!${NC}"
        echo ""
        echo "Image is now available in Minikube as: $FOUND_IMAGE"
        exit 0
    fi
fi

# Method 2: Try loading by the provided name
echo -n "Trying to load $IMAGE_NAME... "
if minikube image load "$IMAGE_NAME" 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
    echo ""
    echo -e "${GREEN}✓ Successfully loaded!${NC}"
    exit 0
else
    echo -e "${RED}✗${NC}"
fi

# Method 3: Save to tar and load
echo -n "Trying alternative method (save/load)... "
TEMP_TAR=$(mktemp /tmp/podman-image-XXXXXX.tar)

if podman save "$IMAGE_NAME" -o "$TEMP_TAR" 2>/dev/null || \
   podman save "$IMAGE_ID" -o "$TEMP_TAR" 2>/dev/null; then
    if minikube image load "$TEMP_TAR" 2>/dev/null; then
        rm -f "$TEMP_TAR"
        echo -e "${GREEN}✓${NC}"
        echo ""
        echo -e "${GREEN}✓ Successfully loaded via tar!${NC}"
        exit 0
    else
        rm -f "$TEMP_TAR"
        echo -e "${RED}✗${NC}"
    fi
else
    rm -f "$TEMP_TAR"
    echo -e "${RED}✗${NC}"
fi

# Method 4: If using podman driver, images might already be shared
echo ""
echo -e "${YELLOW}⚠ Direct load methods failed${NC}"
echo ""
echo "Since Minikube is using Podman driver, images might already be accessible."
echo "You can verify by running:"
echo "  minikube ssh -- podman images"
echo ""
echo "Or try using the image directly in Kubernetes with:"
echo "  image: $IMAGE_NAME"
echo "  imagePullPolicy: Never"
echo ""

# Verify in minikube
echo "Checking images in Minikube..."
minikube image ls 2>/dev/null || minikube ssh -- podman images 2>/dev/null || true
