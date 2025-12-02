#!/bin/bash
# Script to build Podman image for resume

set -e

IMAGE_NAME="resume-app"
IMAGE_TAG="latest"
REGISTRY="your-aws-account.dkr.ecr.us-west-2.amazonaws.com"

echo "Building Podman image..."
podman build -t ${IMAGE_NAME}:${IMAGE_TAG} .

echo "Image built successfully!"
echo ""
echo "To tag for AWS ECR:"
echo "  podman tag ${IMAGE_NAME}:${IMAGE_TAG} ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
echo ""
echo "To push to ECR:"
echo "  aws ecr get-login-password --region us-west-2 | podman login --username AWS --password-stdin ${REGISTRY}"
echo "  podman push ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"


