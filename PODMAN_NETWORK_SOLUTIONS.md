# Podman Network Issue - Solutions

## Problem
```
Error: dial tcp: lookup registry-1.docker.io: no such host
```

Podman cannot reach Docker Hub registry due to DNS/network issues.

## Quick Solutions

### Solution 1: Use Alternative Dockerfile (Easiest)

The alternative Dockerfile uses Ubuntu base which sometimes has better network connectivity:

```bash
./build-using-alternative.sh
```

Or manually:
```bash
podman build -f Dockerfile.alternative -t resume-app:latest .
```

### Solution 2: Restart Podman Machine

```bash
podman machine stop
podman machine start
```

Then try building again:
```bash
./build-with-podman.sh
```

### Solution 3: Fix DNS in Podman Machine

```bash
# SSH into Podman machine
podman machine ssh

# Inside the machine, update DNS
sudo systemctl restart systemd-resolved
# Or
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

# Exit
exit
```

### Solution 4: Use Fixed Build Script

```bash
./build-with-podman-fixed.sh
```

This script will automatically try the alternative Dockerfile if network fails.

### Solution 5: Build in AWS (No Local Network Needed)

**Option A: AWS CodeBuild**
1. Push code to GitHub
2. Create CodeBuild project
3. Use `aws-codebuild-buildspec.yml`
4. Build happens in AWS cloud

**Option B: EC2 Instance**
1. Launch EC2 instance
2. Install Podman/Docker on EC2
3. Build there (better network)

### Solution 6: Pre-download Base Image

If you have access to another machine with working network:

```bash
# On working machine
docker pull nginx:alpine
docker save nginx:alpine -o nginx-alpine.tar

# Transfer to your Mac
# Then load in Podman
podman load -i nginx-alpine.tar
```

### Solution 7: Use Different Registry

Try using a mirror or different registry:

```bash
# Add registry mirror to Podman config
# Edit: ~/.config/containers/registries.conf
```

## Recommended Approach

**For immediate use:**
```bash
./build-using-alternative.sh
```

**For production:**
- Use AWS CodeBuild or GitHub Actions
- Build in cloud (no local network issues)

## Testing Network

```bash
# Test DNS
podman machine ssh "nslookup registry-1.docker.io"

# Test connectivity
podman machine ssh "ping -c 3 registry-1.docker.io"

# Test pull
podman pull docker.io/library/hello-world:latest
```

## Still Having Issues?

1. **Restart your Mac** - Resets network stack
2. **Check VPN/Proxy** - May block Docker Hub
3. **Check Firewall** - May block connections
4. **Use Cloud Build** - AWS CodeBuild or GitHub Actions (recommended)

