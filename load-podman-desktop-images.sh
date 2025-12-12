#!/bin/bash
# Script to load Podman Desktop images into Minikube
# This script accesses images from inside the Podman machine (where Podman Desktop stores them)

set -e

echo "=== Load Podman Desktop Images into Minikube ==="
echo ""
echo "Note: This script accesses images from inside the Podman machine"
echo "      (where Podman Desktop stores them)"
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

# Get list of images from inside Podman machine
echo "Fetching images from Podman machine..."
IMAGES=$(podman machine ssh -- podman images --format "{{.Repository}}:{{.Tag}}" 2>/dev/null | \
    grep -v "^<none>" | grep -v "^REPOSITORY" | grep -v "^$" || true)

if [ -z "$IMAGES" ]; then
    echo -e "${YELLOW}⚠ No images found in Podman machine${NC}"
    echo ""
    echo "Available images:"
    podman machine ssh -- podman images
    exit 0
fi

# Convert to array (zsh/bash compatible)
IMAGE_ARRAY=()
if [ -n "$ZSH_VERSION" ]; then
    IMAGE_ARRAY=(${(f)IMAGES})
else
    if command -v mapfile &> /dev/null; then
        mapfile -t IMAGE_ARRAY <<< "$IMAGES"
    else
        while IFS= read -r line; do
            [ -n "$line" ] && IMAGE_ARRAY+=("$line")
        done <<< "$IMAGES"
    fi
fi

if [ ${#IMAGE_ARRAY[@]} -eq 0 ]; then
    echo -e "${YELLOW}⚠ No valid images found${NC}"
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

SUCCESS_COUNT=0
FAIL_COUNT=0

for image in "${SELECTED_IMAGES[@]}"; do
    echo -n "Loading ${image}... "
    
    # Save from Podman machine and load into Minikube
    TEMP_TAR="/tmp/podman-image-$$-$(echo "$image" | tr '/:' '_').tar"
    
    if podman machine ssh -- podman save "$image" -o "$TEMP_TAR" 2>/dev/null && \
       podman machine ssh -- cat "$TEMP_TAR" | minikube image load - 2>/dev/null; then
        podman machine ssh -- rm -f "$TEMP_TAR" 2>/dev/null || true
        echo -e "${GREEN}✓${NC}"
        ((SUCCESS_COUNT++))
    else
        podman machine ssh -- rm -f "$TEMP_TAR" 2>/dev/null || true
        echo -e "${RED}✗${NC}"
        ((FAIL_COUNT++))
    fi
done

echo ""
echo "=== Summary ==="
echo -e "${GREEN}✓ Successfully loaded: $SUCCESS_COUNT${NC}"
if [ $FAIL_COUNT -gt 0 ]; then
    echo -e "${YELLOW}⚠ Failed to load: $FAIL_COUNT${NC}"
fi
echo ""

echo "Verify with: minikube image ls"
echo "Or: minikube ssh -- podman images"
echo ""
echo -e "${GREEN}✓ Done!${NC}"
