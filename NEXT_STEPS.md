# Next Steps After Successful Build

## ✅ Build Successful!

Your resume app image has been built successfully using Podman with the Ubuntu base image.

## Test Locally

```bash
# Run the container
podman run -d -p 8080:80 --name resume-app resume-app:latest

# Check if it's running
podman ps

# Test in browser
open http://localhost:8080
# Or visit: http://localhost:8080

# View logs
podman logs resume-app

# Stop container
podman stop resume-app
podman rm resume-app
```

## Push to Docker Hub

```bash
# Login to Docker Hub
podman login docker.io

# Tag your image
podman tag resume-app:latest YOUR_USERNAME/resume-app:latest

# Push to Docker Hub
podman push YOUR_USERNAME/resume-app:latest
```

## Push to AWS ECR

```bash
# Set variables
AWS_REGION="us-west-2"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPO="resume-app"

# Create ECR repository (if not exists)
aws ecr create-repository --repository-name ${ECR_REPO} --region ${AWS_REGION} || true

# Login to ECR
aws ecr get-login-password --region ${AWS_REGION} | \
  podman login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# Tag for ECR
podman tag resume-app:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:latest

# Push to ECR
podman push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:latest
```

## Deploy to AWS EKS

```bash
# Update deployment.yaml with your ECR image URI
# Replace YOUR_AWS_ACCOUNT with your actual AWS account ID

# Deploy
kubectl apply -f deployment.yaml

# Check status
kubectl get pods
kubectl get service resume-app-service

# Get LoadBalancer URL
kubectl get service resume-app-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

## Deploy to AWS ECS

```bash
# Update ecs-task-definition.json with your ECR image URI
# Then register task definition
aws ecs register-task-definition --cli-input-json file://ecs-task-definition.json --region us-west-2

# Create service (adjust subnet and security group IDs)
aws ecs create-service \
  --cluster resume-app-cluster \
  --service-name resume-app-service \
  --task-definition resume-app \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxx],securityGroups=[sg-xxx],assignPublicIp=ENABLED}" \
  --region us-west-2
```

## Quick Deploy Script

Use the automated script:

```bash
./QUICK_DEPLOY.sh
```

Select option:
- 2: Push to Docker Hub
- 3: Push to AWS ECR
- 4: Push to both
- 6: Deploy to EKS

## Image Information

```bash
# View image details
podman images resume-app

# Inspect image
podman inspect resume-app:latest

# Check image size
podman images resume-app --format "{{.Size}}"
```

## Cleanup

```bash
# Remove container
podman rm resume-app

# Remove image
podman rmi resume-app:latest

# Or use Makefile
make clean
```

## Troubleshooting

If the container doesn't start:
```bash
# Check logs
podman logs resume-app

# Check if port is in use
lsof -i :8080

# Run interactively to debug
podman run -it --rm -p 8080:80 resume-app:latest
```

## Success! 🎉

Your resume app is now containerized and ready to deploy!

