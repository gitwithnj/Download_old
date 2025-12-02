# Resume App - Podman/Docker Deployment Guide for AWS

This guide explains how to build and deploy the resume application as a containerized application on AWS.

## Prerequisites

- Podman or Docker installed
- AWS CLI configured
- AWS ECR repository created
- kubectl configured (for EKS deployment)
- AWS ECS CLI (for ECS deployment)

## Option 1: Deploy to AWS EKS (Kubernetes)

### Step 1: Build Image

```bash
# Make build script executable
chmod +x podman-build.sh

# Build the image
podman build -t resume-app:latest .
```

### Step 2: Push to AWS ECR

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

# Tag image
podman tag resume-app:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:latest

# Push image
podman push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:latest
```

### Step 3: Update deployment.yaml

Edit `deployment.yaml` and replace `YOUR_AWS_ACCOUNT` with your actual AWS account ID.

### Step 4: Deploy to EKS

```bash
# Apply deployment
kubectl apply -f deployment.yaml

# Check status
kubectl get pods
kubectl get services

# Get LoadBalancer URL
kubectl get service resume-app-service
```

## Option 2: Deploy to AWS ECS (Fargate)

### Step 1: Build and Push Image (same as EKS)

Follow Step 1 and Step 2 from EKS deployment.

### Step 2: Create ECS Cluster

```bash
aws ecs create-cluster --cluster-name resume-app-cluster --region us-west-2
```

### Step 3: Create CloudWatch Log Group

```bash
aws logs create-log-group --log-group-name /ecs/resume-app --region us-west-2
```

### Step 4: Register Task Definition

```bash
# Update ecs-task-definition.json with your AWS account ID
# Then register:
aws ecs register-task-definition --cli-input-json file://ecs-task-definition.json --region us-west-2
```

### Step 5: Create ECS Service

```bash
aws ecs create-service \
  --cluster resume-app-cluster \
  --service-name resume-app-service \
  --task-definition resume-app \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxx,subnet-yyy],securityGroups=[sg-xxx],assignPublicIp=ENABLED}" \
  --load-balancers "targetGroupArn=arn:aws:elasticloadbalancing:us-west-2:ACCOUNT:targetgroup/xxx/xxx,containerName=resume-app,containerPort=80" \
  --region us-west-2
```

## Option 3: Deploy to EC2 with Podman

### Step 1: Launch EC2 Instance

- Use Amazon Linux 2023 or Ubuntu
- Security group: Allow HTTP (80) and HTTPS (443)

### Step 2: Install Podman on EC2

```bash
# Amazon Linux 2023
sudo yum install -y podman

# Ubuntu
sudo apt-get update
sudo apt-get install -y podman
```

### Step 3: Transfer Files

```bash
# From your local machine
scp -r Dockerfile nginx.conf resume.html ec2-user@your-ec2-ip:/home/ec2-user/resume-app/
```

### Step 4: Build and Run on EC2

```bash
# SSH into EC2
ssh ec2-user@your-ec2-ip

# Build image
cd resume-app
podman build -t resume-app:latest .

# Run container
podman run -d \
  --name resume-app \
  -p 80:80 \
  --restart=always \
  resume-app:latest
```

## Option 4: Deploy to AWS App Runner

### Step 1: Build and Push to ECR

Follow Step 1 and Step 2 from EKS deployment.

### Step 2: Create App Runner Service

```bash
aws apprunner create-service \
  --service-name resume-app \
  --source-configuration "{
    \"ImageRepository\": {
      \"ImageIdentifier\": \"${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/resume-app:latest\",
      \"ImageConfiguration\": {
        \"Port\": \"80\"
      },
      \"ImageRepositoryType\": \"ECR\"
    },
    \"AutoDeploymentsEnabled\": true
  }" \
  --instance-configuration "{
    \"Cpu\": \"0.25 vCPU\",
    \"Memory\": \"0.5 GB\"
  }" \
  --region ${AWS_REGION}
```

## Testing Locally

### Build and Run with Podman

```bash
# Build
podman build -t resume-app:latest .

# Run
podman run -d -p 8080:80 --name resume-app resume-app:latest

# Test
curl http://localhost:8080
# Or open http://localhost:8080 in browser
```

### Build and Run with Docker

```bash
# Build
docker build -t resume-app:latest .

# Run
docker run -d -p 8080:80 --name resume-app resume-app:latest

# Test
curl http://localhost:8080
```

## Image Optimization

The current image uses `nginx:alpine` which is already lightweight (~23MB). For further optimization:

1. Use multi-stage builds
2. Minimize layers
3. Use distroless images (if needed)

## Monitoring and Logs

### EKS
```bash
kubectl logs -f deployment/resume-app
```

### ECS
```bash
aws logs tail /ecs/resume-app --follow --region us-west-2
```

### EC2
```bash
podman logs resume-app
```

## Scaling

### EKS
```bash
kubectl scale deployment resume-app --replicas=5
```

### ECS
```bash
aws ecs update-service \
  --cluster resume-app-cluster \
  --service resume-app-service \
  --desired-count 5 \
  --region us-west-2
```

## Cost Optimization

- Use Fargate Spot for ECS (up to 70% savings)
- Use EC2 Spot instances
- Right-size container resources
- Use CloudFront CDN for static content

## Security Best Practices

1. Scan images for vulnerabilities:
   ```bash
   podman scan resume-app:latest
   ```

2. Use IAM roles (not access keys)
3. Enable VPC endpoints for ECR
4. Use security groups with least privilege
5. Enable AWS WAF for public-facing services

## Troubleshooting

### Image won't build
- Check Dockerfile syntax
- Verify all files are present
- Check .dockerignore

### Container won't start
- Check logs: `podman logs resume-app`
- Verify nginx.conf syntax
- Check port conflicts

### Can't push to ECR
- Verify AWS credentials
- Check ECR repository exists
- Verify IAM permissions

## Next Steps

1. Set up CI/CD pipeline (GitHub Actions, GitLab CI)
2. Add custom domain with Route 53
3. Enable HTTPS with ACM certificate
4. Set up CloudFront CDN
5. Add monitoring with CloudWatch
6. Implement auto-scaling


