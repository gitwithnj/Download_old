# Troubleshooting Guide

## Podman Network Issues

### Issue: Cannot connect to Docker Hub registry

**Symptoms:**
```
Error: dial tcp: lookup registry-1.docker.io: no such host
```

**Solutions:**

1. **Restart Podman Machine:**
   ```bash
   podman machine stop
   podman machine start
   ```

2. **Check DNS Settings:**
   ```bash
   podman machine inspect
   # Check DNS configuration
   ```

3. **Use Docker Desktop Instead:**
   - Install Docker Desktop for Mac
   - Use `docker` commands instead of `podman`

4. **Use AWS CodeBuild:**
   - Build directly in AWS using CodeBuild
   - No local setup required

## Alternative: Use Docker Desktop

If Podman has network issues, use Docker Desktop:

```bash
# Install Docker Desktop from: https://www.docker.com/products/docker-desktop

# Then use docker commands:
docker build -t resume-app:latest .
docker run -d -p 8080:80 --name resume-app resume-app:latest
```

## Alternative: Build in AWS CodeBuild

1. Push code to GitHub/GitLab
2. Create CodeBuild project
3. Use provided `aws-codebuild-buildspec.yml`
4. Build happens in AWS (no local setup needed)

## Alternative: Use GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Build and Deploy

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-west-2
      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1
      - name: Build, tag, and push image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: resume-app
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
```

## Quick Test Without Building

You can test the resume.html directly:

```bash
# Using Python (if installed)
python3 -m http.server 8080

# Or using Node.js
npx http-server -p 8080

# Then open: http://localhost:8080/resume.html
```

## Verify Files

Make sure all required files exist:

```bash
ls -la Dockerfile nginx.conf resume.html
```

All three files should be present.

## Check File Permissions

```bash
chmod +x QUICK_DEPLOY.sh
chmod +x podman-build.sh
```

## AWS Credentials

Verify AWS credentials:

```bash
aws sts get-caller-identity
```

Should return your AWS account ID.

## ECR Repository

Create ECR repository manually if needed:

```bash
aws ecr create-repository \
  --repository-name resume-app \
  --region us-west-2 \
  --image-scanning-configuration scanOnPush=true
```


