.PHONY: build push deploy test clean

# Variables
IMAGE_NAME = resume-app
IMAGE_TAG = latest
AWS_REGION = us-west-2
AWS_ACCOUNT_ID = $(shell aws sts get-caller-identity --query Account --output text 2>/dev/null)
ECR_REPO = resume-app
ECR_URI = $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(ECR_REPO)

# Build image
build:
	@echo "Building $(IMAGE_NAME):$(IMAGE_TAG)..."
	podman build -t $(IMAGE_NAME):$(IMAGE_TAG) .
	@echo "Build complete!"

# Test locally
test:
	@echo "Testing image locally..."
	podman run -d -p 8080:80 --name $(IMAGE_NAME)-test $(IMAGE_NAME):$(IMAGE_TAG)
	@sleep 2
	@curl -s http://localhost:8080 > /dev/null && echo "✓ Container is running!" || echo "✗ Container failed to start"
	@podman stop $(IMAGE_NAME)-test && podman rm $(IMAGE_NAME)-test

# Login to ECR
ecr-login:
	@echo "Logging into ECR..."
	@aws ecr get-login-password --region $(AWS_REGION) | \
		podman login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com

# Create ECR repository
create-repo:
	@echo "Creating ECR repository..."
	@aws ecr create-repository --repository-name $(ECR_REPO) --region $(AWS_REGION) || \
		echo "Repository already exists"

# Tag for ECR
tag:
	@echo "Tagging image for ECR..."
	podman tag $(IMAGE_NAME):$(IMAGE_TAG) $(ECR_URI):$(IMAGE_TAG)

# Push to ECR
push: ecr-login tag
	@echo "Pushing $(ECR_URI):$(IMAGE_TAG) to ECR..."
	podman push $(ECR_URI):$(IMAGE_TAG)
	@echo "Push complete!"

# Full deployment workflow
deploy: build test create-repo push
	@echo "Deployment complete!"
	@echo "Image URI: $(ECR_URI):$(IMAGE_TAG)"

# Clean up local images
clean:
	@echo "Cleaning up local images..."
	podman rmi $(IMAGE_NAME):$(IMAGE_TAG) 2>/dev/null || true
	@echo "Cleanup complete!"

# Show image info
info:
	@echo "Image Name: $(IMAGE_NAME)"
	@echo "Image Tag: $(IMAGE_TAG)"
	@echo "ECR URI: $(ECR_URI):$(IMAGE_TAG)"
	@echo "AWS Account: $(AWS_ACCOUNT_ID)"
	@echo "AWS Region: $(AWS_REGION)"


