#!/bin/bash
# Script to load existing Podman images into Minikube (Podman runtime)

set -e

echo "=== Load Podman Images into Minikube ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Podman is available
if ! command -v podman &> /dev/null; then
    echo -e "${RED}❌ Podman not found!${NC}"
    echo ""
    echo "Please install Podman:"
    echo "  macOS: brew install podman"
    exit 1
fi

# Check if Podman machine is running
if ! podman info &> /dev/null; then
    echo -e "${YELLOW}⚠ Podman machine may not be running${NC}"
    echo ""
    echo "Attempting to start Podman machine..."
    podman machine start 2>/dev/null || {
        echo -e "${RED}❌ Failed to start Podman machine${NC}"
        echo ""
        echo "Please run:"
        echo "  podman machine init  (if not initialized)"
        echo "  podman machine start"
        exit 1
    }
fi

# Check if Minikube is available
if ! command -v minikube &> /dev/null; then
    echo -e "${RED}❌ Minikube not found!${NC}"
    echo ""
    echo "Please install Minikube:"
    echo "  macOS: brew install minikube"
    exit 1
fi

# Check if Minikube is running
if ! minikube status &> /dev/null; then
    echo -e "${YELLOW}⚠ Minikube may not be running${NC}"
    echo ""
    echo "Attempting to start Minikube..."
    minikube start --driver=podman 2>/dev/null || {
        echo -e "${RED}❌ Failed to start Minikube${NC}"
        echo ""
        echo "Please ensure Minikube is configured with Podman:"
        echo "  minikube start --driver=podman"
        exit 1
    }
fi

echo -e "${GREEN}✓ Podman is available and running${NC}"
echo -e "${GREEN}✓ Minikube is available and running${NC}"
echo ""

# Get list of Podman images
echo "Fetching Podman images..."
IMAGES=$(podman images --format "{{.Repository}}:{{.Tag}}" | grep -v "^<none>" || true)

if [ -z "$IMAGES" ]; then
    echo -e "${YELLOW}⚠ No Podman images found${NC}"
    echo ""
    echo "Available images will be listed below. If empty, you may need to build images first."
    podman images
    exit 0
fi

# Convert to array
mapfile -t IMAGE_ARRAY <<< "$IMAGES"

if [ ${#IMAGE_ARRAY[@]} -eq 0 ]; then
    echo -e "${YELLOW}⚠ No valid Podman images found${NC}"
    exit 0
fi

echo ""
echo "Found ${#IMAGE_ARRAY[@]} image(s):"
echo ""
for i in "${!IMAGE_ARRAY[@]}"; do
    echo "  $((i+1)). ${IMAGE_ARRAY[$i]}"
done
echo ""

# Ask user which images to load
if [ "$1" == "--all" ]; then
    SELECTED_IMAGES=("${IMAGE_ARRAY[@]}")
    echo "Loading all images..."
else
    echo "Select images to load into Minikube:"
    echo "  - Enter image numbers separated by spaces (e.g., 1 2 3)"
    echo "  - Enter 'all' to load all images"
    echo "  - Press Enter to cancel"
    echo ""
    read -p "Your selection: " selection
    
    if [ -z "$selection" ]; then
        echo "Cancelled."
        exit 0
    fi
    
    if [ "$selection" == "all" ]; then
        SELECTED_IMAGES=("${IMAGE_ARRAY[@]}")
    else
        # Parse selection
        SELECTED_IMAGES=()
        for num in $selection; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le ${#IMAGE_ARRAY[@]} ]; then
                SELECTED_IMAGES+=("${IMAGE_ARRAY[$((num-1))]}")
            else
                echo -e "${YELLOW}⚠ Invalid selection: $num (skipping)${NC}"
            fi
        done
    fi
fi

if [ ${#SELECTED_IMAGES[@]} -eq 0 ]; then
    echo -e "${YELLOW}⚠ No images selected${NC}"
    exit 0
fi

echo ""
echo "Loading ${#SELECTED_IMAGES[@]} image(s) into Minikube..."
echo ""

# Load each image
SUCCESS_COUNT=0
FAIL_COUNT=0

for image in "${SELECTED_IMAGES[@]}"; do
    echo -n "Loading ${image}... "
    
    # Method 1: Use minikube image load (preferred method)
    if minikube image load "$image" 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
        ((SUCCESS_COUNT++))
    else
        # Method 2: Alternative - save and load via tar
        echo -n "(trying alternative method...) "
        TEMP_TAR=$(mktemp /tmp/podman-image-XXXXXX.tar)
        
        if podman save "$image" -o "$TEMP_TAR" 2>/dev/null && \
           minikube image load "$TEMP_TAR" 2>/dev/null; then
            rm -f "$TEMP_TAR"
            echo -e "${GREEN}✓${NC}"
            ((SUCCESS_COUNT++))
        else
            rm -f "$TEMP_TAR"
            echo -e "${RED}✗${NC}"
            echo -e "  ${YELLOW}Note: Image might already be available in Minikube${NC}"
            ((FAIL_COUNT++))
        fi
    fi
done

echo ""
echo "=== Summary ==="
echo -e "${GREEN}✓ Successfully loaded: $SUCCESS_COUNT${NC}"
if [ $FAIL_COUNT -gt 0 ]; then
    echo -e "${YELLOW}⚠ Failed to load: $FAIL_COUNT${NC}"
fi
echo ""

# Verify images in Minikube
echo "Verifying images in Minikube..."
echo ""
minikube image ls 2>/dev/null || {
    echo -e "${YELLOW}⚠ Could not list Minikube images directly${NC}"
    echo "You can verify images are available by running:"
    echo "  minikube ssh -- podman images"
}

echo ""
echo -e "${GREEN}✓ Done!${NC}"
echo ""
echo "To use these images in Kubernetes deployments, reference them by name:"
for image in "${SELECTED_IMAGES[@]}"; do
    echo "  - $image"
done
echo ""
echo "Note: If using imagePullPolicy, set it to 'Never' or 'IfNotPresent'"
echo "      since these images are loaded locally."
