# Resume App - Container Deployment

This directory contains everything needed to containerize and deploy your resume to AWS.

## Quick Start

### Option 1: Automated Script (Recommended)

```bash
./QUICK_DEPLOY.sh
```

This interactive script will guide you through:
- Building the image
- Pushing to AWS ECR
- Deploying to EKS

### Option 2: Manual Steps

#### 1. Build Image

**Using Podman (Recommended):**
```bash
podman build -t resume-app:latest .
```

**Or using Docker (fallback):**
```bash
docker build -t resume-app:latest .
```

#### 2. Test Locally

```bash
podman run -d -p 8080:80 --name resume-app resume-app:latest
# Open http://localhost:8080
```

#### 3. Push to AWS ECR

```bash
# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION="us-west-2"

# Create ECR repository
aws ecr create-repository --repository-name resume-app --region ${AWS_REGION}

# Login to ECR
aws ecr get-login-password --region ${AWS_REGION} | \
  podman login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# Tag and push
podman tag resume-app:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/resume-app:latest
podman push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/resume-app:latest
```

#### 4. Deploy to EKS

```bash
# Update deployment.yaml with your AWS account ID
sed -i '' "s/YOUR_AWS_ACCOUNT/${AWS_ACCOUNT_ID}/g" deployment.yaml

# Deploy
kubectl apply -f deployment.yaml

# Check status
kubectl get pods
kubectl get service resume-app-service
```

## Files Overview

- **Dockerfile** - Container image definition
- **nginx.conf** - Nginx web server configuration
- **deployment.yaml** - Kubernetes/EKS deployment manifest
- **ecs-task-definition.json** - ECS Fargate task definition
- **QUICK_DEPLOY.sh** - Automated deployment script
- **Makefile** - Build automation commands
- **DEPLOYMENT_GUIDE.md** - Detailed deployment guide
- **TROUBLESHOOTING.md** - Common issues and solutions

## Deployment Options

1. **AWS EKS (Kubernetes)** - Use `deployment.yaml`
2. **AWS ECS (Fargate)** - Use `ecs-task-definition.json`
3. **EC2** - Run container directly on EC2 instance
4. **AWS App Runner** - Serverless container deployment
5. **AWS CodeBuild** - Build in AWS using `aws-codebuild-buildspec.yml`

## Image Details

- **Base**: nginx:alpine (~23MB)
- **Size**: ~25-30MB
- **Port**: 80
- **Health Check**: HTTP GET on port 80

## Next Steps

1. Build and test locally
2. Push to ECR
3. Deploy to your preferred AWS service
4. Set up custom domain (optional)
5. Enable HTTPS with ACM certificate (optional)
6. Set up CloudFront CDN (optional)

## Support

See `TROUBLESHOOTING.md` for common issues and solutions.


