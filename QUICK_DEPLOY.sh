#!/bin/bash
# Quick deployment script for Resume App
# This script helps deploy to AWS ECR, Docker Hub, and EKS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Resume App Deployment Script ===${NC}\n"

# Check prerequisites
echo "Checking prerequisites..."

# Check AWS CLI (optional for Docker Hub)
if command -v aws &> /dev/null; then
    echo -e "${GREEN}✓ AWS CLI found${NC}"
    AWS_AVAILABLE=true
else
    echo -e "${YELLOW}⚠ AWS CLI not found (required for ECR, optional for Docker Hub)${NC}"
    AWS_AVAILABLE=false
fi

# Check kubectl (for EKS)
if command -v kubectl &> /dev/null; then
    echo -e "${GREEN}✓ kubectl found${NC}"
    KUBECTL_AVAILABLE=true
else
    echo -e "${YELLOW}⚠ kubectl not found (optional for EKS)${NC}"
    KUBECTL_AVAILABLE=false
fi

# Check container runtime (prefer Podman)
if command -v podman &> /dev/null; then
    CONTAINER_CMD="podman"
    echo -e "${GREEN}✓ Podman found${NC}"
elif command -v docker &> /dev/null; then
    CONTAINER_CMD="docker"
    echo -e "${GREEN}✓ Docker found (using as fallback)${NC}"
else
    echo -e "${RED}✗ No container runtime found (Podman/Docker)${NC}"
    exit 1
fi

# Get AWS account info (if AWS CLI available)
if [ "$AWS_AVAILABLE" = true ]; then
    echo -e "\n${GREEN}Getting AWS account information...${NC}"
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo "")
    AWS_REGION=${AWS_REGION:-us-west-2}
    
    if [ -z "$AWS_ACCOUNT_ID" ]; then
        echo -e "${YELLOW}⚠ Unable to get AWS account ID. AWS features will be disabled.${NC}"
        AWS_AVAILABLE=false
    else
        echo -e "${GREEN}✓ AWS Account ID: ${AWS_ACCOUNT_ID}${NC}"
        echo -e "${GREEN}✓ AWS Region: ${AWS_REGION}${NC}"
    fi
fi

# Image details
IMAGE_NAME="resume-app"
IMAGE_TAG="latest"
ECR_REPO="resume-app"
if [ "$AWS_AVAILABLE" = true ]; then
    ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"
fi

echo -e "\n${GREEN}=== Build Configuration ===${NC}"
echo "Image Name: ${IMAGE_NAME}"
echo "Image Tag: ${IMAGE_TAG}"
if [ "$AWS_AVAILABLE" = true ]; then
    echo "ECR Repository: ${ECR_REPO}"
    echo "ECR URI: ${ECR_URI}:${IMAGE_TAG}"
fi

# Function to build image
build_image() {
    echo -e "\n${GREEN}=== Building Image ===${NC}"
    ${CONTAINER_CMD} build -t ${IMAGE_NAME}:${IMAGE_TAG} .
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Image built successfully${NC}"
        return 0
    else
        echo -e "${RED}✗ Image build failed${NC}"
        return 1
    fi
}

# Function to create ECR repository
create_ecr_repo() {
    echo -e "\n${GREEN}=== Creating ECR Repository ===${NC}"
    aws ecr describe-repositories --repository-names ${ECR_REPO} --region ${AWS_REGION} &>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${YELLOW}⚠ Repository already exists${NC}"
    else
        aws ecr create-repository --repository-name ${ECR_REPO} --region ${AWS_REGION}
        echo -e "${GREEN}✓ Repository created${NC}"
    fi
}

# Function to login to ECR
ecr_login() {
    echo -e "\n${GREEN}=== Logging into ECR ===${NC}"
    aws ecr get-login-password --region ${AWS_REGION} | \
        ${CONTAINER_CMD} login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Logged into ECR${NC}"
        return 0
    else
        echo -e "${RED}✗ ECR login failed${NC}"
        return 1
    fi
}

# Function to tag and push
push_image() {
    echo -e "\n${GREEN}=== Tagging and Pushing Image ===${NC}"
    ${CONTAINER_CMD} tag ${IMAGE_NAME}:${IMAGE_TAG} ${ECR_URI}:${IMAGE_TAG}
    ${CONTAINER_CMD} push ${ECR_URI}:${IMAGE_TAG}
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Image pushed successfully${NC}"
        return 0
    else
        echo -e "${RED}✗ Image push failed${NC}"
        return 1
    fi
}

# Function to login to Docker Hub
dockerhub_login() {
    echo -e "\n${GREEN}=== Logging into Docker Hub ===${NC}"
    if [ -z "$DOCKERHUB_USERNAME" ]; then
        read -p "Enter Docker Hub username: " DOCKERHUB_USERNAME
    fi
    
    echo -n "Enter Docker Hub password (or token): "
    read -s DOCKERHUB_PASSWORD
    echo ""
    
    echo "$DOCKERHUB_PASSWORD" | ${CONTAINER_CMD} login --username "$DOCKERHUB_USERNAME" --password-stdin
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Logged into Docker Hub${NC}"
        return 0
    else
        echo -e "${RED}✗ Docker Hub login failed${NC}"
        return 1
    fi
}

# Function to push to Docker Hub
push_to_dockerhub() {
    echo -e "\n${GREEN}=== Pushing to Docker Hub ===${NC}"
    if [ -z "$DOCKERHUB_USERNAME" ]; then
        read -p "Enter Docker Hub username: " DOCKERHUB_USERNAME
    fi
    
    DOCKERHUB_IMAGE="${DOCKERHUB_USERNAME}/${IMAGE_NAME}"
    ${CONTAINER_CMD} tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKERHUB_IMAGE}:${IMAGE_TAG}
    ${CONTAINER_CMD} push ${DOCKERHUB_IMAGE}:${IMAGE_TAG}
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Image pushed to Docker Hub successfully${NC}"
        echo -e "${GREEN}Image URI: docker.io/${DOCKERHUB_IMAGE}:${IMAGE_TAG}${NC}"
        echo -e "${GREEN}Pull command: ${CONTAINER_CMD} pull ${DOCKERHUB_IMAGE}:${IMAGE_TAG}${NC}"
        return 0
    else
        echo -e "${RED}✗ Docker Hub push failed${NC}"
        return 1
    fi
}

# Function to update deployment.yaml
update_deployment() {
    if [ "$AWS_AVAILABLE" = false ]; then
        echo -e "${YELLOW}⚠ Skipping deployment.yaml update (AWS not available)${NC}"
        return 0
    fi
    
    echo -e "\n${GREEN}=== Updating deployment.yaml ===${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i.bak "s|YOUR_AWS_ACCOUNT|${AWS_ACCOUNT_ID}|g" deployment.yaml
        sed -i.bak "s|us-west-2|${AWS_REGION}|g" deployment.yaml
    else
        # Linux
        sed -i "s|YOUR_AWS_ACCOUNT|${AWS_ACCOUNT_ID}|g" deployment.yaml
        sed -i "s|us-west-2|${AWS_REGION}|g" deployment.yaml
    fi
    echo -e "${GREEN}✓ deployment.yaml updated${NC}"
    echo -e "${YELLOW}Backup saved as deployment.yaml.bak${NC}"
}

# Main menu
echo -e "\n${GREEN}=== Deployment Options ===${NC}"
echo "1. Build image only (local testing)"
echo "2. Build and push to Docker Hub"
echo "3. Build and push to AWS ECR"
echo "4. Build and push to both Docker Hub and ECR"
echo "5. Full AWS deployment (Build + Push ECR + Update manifests)"
echo "6. Deploy to EKS (requires kubectl and AWS)"
echo "7. Exit"

read -p "Select option (1-7): " choice

case $choice in
    1)
        build_image
        echo -e "\n${GREEN}To test locally, run:${NC}"
        echo "${CONTAINER_CMD} run -d -p 8080:80 --name ${IMAGE_NAME} ${IMAGE_NAME}:${IMAGE_TAG}"
        echo "Then open: http://localhost:8080"
        ;;
    2)
        build_image && dockerhub_login && push_to_dockerhub
        ;;
    3)
        if [ "$AWS_AVAILABLE" = false ]; then
            echo -e "${RED}✗ AWS not available. Please configure AWS credentials.${NC}"
            exit 1
        fi
        build_image && create_ecr_repo && ecr_login && push_image
        echo -e "\n${GREEN}Image URI: ${ECR_URI}:${IMAGE_TAG}${NC}"
        ;;
    4)
        build_image
        if [ "$AWS_AVAILABLE" = true ]; then
            create_ecr_repo && ecr_login && push_image
            echo -e "\n${GREEN}ECR Image URI: ${ECR_URI}:${IMAGE_TAG}${NC}"
        fi
        dockerhub_login && push_to_dockerhub
        echo -e "\n${GREEN}✓ Image pushed to both registries${NC}"
        ;;
    5)
        if [ "$AWS_AVAILABLE" = false ]; then
            echo -e "${RED}✗ AWS not available. Please configure AWS credentials.${NC}"
            exit 1
        fi
        build_image && create_ecr_repo && ecr_login && push_image && update_deployment
        echo -e "\n${GREEN}Deployment ready!${NC}"
        echo -e "Image URI: ${ECR_URI}:${IMAGE_TAG}"
        echo -e "\nTo deploy to EKS, run:"
        echo "kubectl apply -f deployment.yaml"
        ;;
    6)
        if [ "$AWS_AVAILABLE" = false ]; then
            echo -e "${RED}✗ AWS not available. Please configure AWS credentials.${NC}"
            exit 1
        fi
        if [ "$KUBECTL_AVAILABLE" = false ]; then
            echo -e "${RED}✗ kubectl not available${NC}"
            exit 1
        fi
        build_image && create_ecr_repo && ecr_login && push_image && update_deployment
        echo -e "\n${GREEN}Deploying to EKS...${NC}"
        kubectl apply -f deployment.yaml
        echo -e "\n${GREEN}Checking deployment status...${NC}"
        kubectl get pods -l app=resume-app
        kubectl get service resume-app-service
        ;;
    7)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option${NC}"
        exit 1
        ;;
esac

echo -e "\n${GREEN}=== Done! ===${NC}"

