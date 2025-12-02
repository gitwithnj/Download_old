# ZSH Compatibility Guide

## Current Status

All scripts are written for bash (`#!/bin/bash`) but should work in zsh with minor adjustments.

## Common Issues and Fixes

### 1. Script Execution

**Issue:** Scripts may not execute if permissions are wrong

**Fix:**
```bash
chmod +x script-name.sh
./script-name.sh
```

### 2. PATH Issues

**Issue:** Commands not found even if installed

**Fix:**
```bash
# Check if command exists
which command-name

# Add to PATH if needed
export PATH="/path/to/bin:$PATH"

# Make permanent (add to ~/.zshrc)
echo 'export PATH="/path/to/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### 3. Google Cloud SDK PATH

After installing gcloud, add to `~/.zshrc`:

```bash
# For Homebrew installation
export PATH="/opt/homebrew/share/google-cloud-sdk/bin:$PATH"

# For manual installation
export PATH="$HOME/google-cloud-sdk/bin:$PATH"

# Then reload
source ~/.zshrc
```

### 4. Podman PATH

```bash
# Check Podman location
which podman

# Usually at: /opt/homebrew/bin/podman (Apple Silicon)
# Or: /usr/local/bin/podman (Intel)
```

### 5. Script Compatibility

Most bash scripts work in zsh, but if you encounter issues:

**Option 1: Run with bash explicitly**
```bash
bash script-name.sh
```

**Option 2: Use zsh to run**
```bash
zsh script-name.sh
```

**Option 3: Make scripts zsh-compatible**
- Change shebang to `#!/bin/zsh`
- Or use `#!/usr/bin/env bash` for better compatibility

## Testing Scripts in ZSH

```bash
# Test if script runs
bash -n script-name.sh  # Syntax check
zsh -n script-name.sh    # Zsh syntax check

# Run with debugging
bash -x script-name.sh
zsh -x script-name.sh
```

## Quick Fixes for Common Commands

### gcloud not found
```bash
# Check if installed
ls -la ~/google-cloud-sdk/bin/gcloud
ls -la /opt/homebrew/share/google-cloud-sdk/bin/gcloud

# Add to PATH
export PATH="$HOME/google-cloud-sdk/bin:$PATH"
# or
export PATH="/opt/homebrew/share/google-cloud-sdk/bin:$PATH"
```

### podman not found
```bash
# Check location
which podman
# Usually: /opt/homebrew/bin/podman

# Add to PATH if needed
export PATH="/opt/homebrew/bin:$PATH"
```

### docker not found
```bash
# Check if Docker Desktop is installed
ls /Applications/Docker.app

# Docker CLI usually at:
# /usr/local/bin/docker
# or symlinked from Docker.app
```

## ZSH-Specific Optimizations

### Add to ~/.zshrc for better compatibility:

```bash
# Enable bash compatibility
setopt SH_WORD_SPLIT
setopt NO_NOMATCH

# Add common paths
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/share/google-cloud-sdk/bin:$PATH"
export PATH="$HOME/google-cloud-sdk/bin:$PATH"
```

## Running Scripts

All scripts should work in zsh. If you encounter issues:

1. **Check script permissions:**
   ```bash
   chmod +x script-name.sh
   ```

2. **Run explicitly with bash:**
   ```bash
   bash script-name.sh
   ```

3. **Check for command availability:**
   ```bash
   which command-name
   ```

## Quick Test

Test if your environment is set up correctly:

```bash
# Test commands
which podman
which docker
which gcloud
which aws
which kubectl

# Test script
bash -n QUICK_DEPLOY.sh
```

All scripts are compatible with zsh. If you encounter specific errors, share them and I can help fix them.

