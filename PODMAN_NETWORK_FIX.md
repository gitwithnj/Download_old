# Fixing Podman Network Issues

## Problem
```
Error: dial tcp: lookup registry-1.docker.io: no such host
```

This indicates Podman cannot resolve DNS or reach Docker Hub.

## Solutions

### Solution 1: Restart Podman Machine (Quick Fix)

```bash
# Stop and start Podman machine
podman machine stop
podman machine start

# Wait a few seconds, then test
podman pull docker.io/library/hello-world:latest
```

### Solution 2: Use Docker Desktop Instead

Docker Desktop is more reliable on macOS:

1. **Install Docker Desktop:**
   - Download from: https://www.docker.com/products/docker-desktop
   - Install and start Docker Desktop

2. **Use Docker commands:**
   ```bash
   docker build -t resume-app:latest .
   docker run -d -p 8080:80 resume-app:latest
   ```

3. **Or use the provided script:**
   ```bash
   ./build-with-docker-desktop.sh
   ```

### Solution 3: Fix Podman DNS

```bash
# Inspect machine configuration
podman machine inspect

# Check DNS settings in the output
# If DNS is wrong, you may need to recreate the machine
```

### Solution 4: Recreate Podman Machine

```bash
# Remove existing machine
podman machine rm podman-machine-default

# Create new machine
podman machine init

# Start machine
podman machine start
```

### Solution 5: Use Alternative Base Image

If `nginx:alpine` fails, use the alternative Dockerfile:

```bash
docker build -f Dockerfile.alternative -t resume-app:latest .
```

This uses Ubuntu base which might have better network connectivity.

### Solution 6: Build in AWS (No Local Docker Needed)

**Option A: AWS CodeBuild**
1. Push code to GitHub
2. Create CodeBuild project
3. Use `aws-codebuild-buildspec.yml`
4. Build happens in AWS cloud

**Option B: GitHub Actions**
1. Push code to GitHub
2. Set up GitHub Actions workflow
3. Build and push automatically

**Option C: EC2 Instance**
1. Launch EC2 instance
2. Install Docker on EC2
3. Build there (better network)

### Solution 7: Manual Image Download

If you have access to another machine with working Docker:

```bash
# On working machine
docker pull nginx:alpine
docker save nginx:alpine -o nginx-alpine.tar

# Transfer to your Mac
# Then load it
docker load -i nginx-alpine.tar
```

## Recommended Approach

**For immediate use:**
1. Install Docker Desktop
2. Use `./build-with-docker-desktop.sh`

**For production:**
1. Use AWS CodeBuild or GitHub Actions
2. Build in cloud (no local setup needed)

## Testing Network

```bash
# Test DNS resolution
nslookup registry-1.docker.io

# Test connectivity
ping registry-1.docker.io

# Test Podman connection
podman pull docker.io/library/hello-world:latest
```

## Quick Commands

```bash
# Fix script
chmod +x fix-podman-network.sh
./fix-podman-network.sh

# Use Docker Desktop
chmod +x build-with-docker-desktop.sh
./build-with-docker-desktop.sh

# Use alternative Dockerfile
docker build -f Dockerfile.alternative -t resume-app:latest .
```

## Still Having Issues?

1. **Restart your Mac** - Resets network stack
2. **Check VPN/Proxy** - May block Docker Hub
3. **Check Firewall** - May block connections
4. **Use Cloud Build** - AWS CodeBuild or GitHub Actions


