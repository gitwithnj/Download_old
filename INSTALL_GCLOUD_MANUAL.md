# Manual Google Cloud SDK Installation (macOS)

## Network Issue Detected

If Homebrew installation fails due to network issues, use these alternatives:

## Option 1: Direct Download (Recommended)

### Step 1: Download SDK

**For Apple Silicon (M1/M2/M3):**
```bash
cd ~/Downloads
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-darwin-arm64.tar.gz
```

**For Intel Mac:**
```bash
cd ~/Downloads
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-darwin-x86_64.tar.gz
```

### Step 2: Extract and Install

```bash
# Extract
tar -xzf google-cloud-cli-darwin-*.tar.gz

# Run installer
./google-cloud-sdk/install.sh

# Follow prompts (press Enter for defaults)
```

### Step 3: Add to PATH

```bash
# Add to ~/.zshrc (for zsh)
echo 'export PATH="$HOME/google-cloud-sdk/bin:$PATH"' >> ~/.zshrc

# Or add to ~/.bash_profile (for bash)
echo 'export PATH="$HOME/google-cloud-sdk/bin:$PATH"' >> ~/.bash_profile

# Reload shell
source ~/.zshrc
# or
source ~/.bash_profile
```

### Step 4: Initialize

```bash
gcloud init
```

---

## Option 2: Interactive Installer

```bash
# Download and run interactive installer
curl https://sdk.cloud.google.com | bash

# Restart terminal or source
exec -l $SHELL

# Initialize
gcloud init
```

---

## Option 3: Use Browser Download

1. **Visit:** https://cloud.google.com/sdk/docs/install
2. **Download:** macOS installer (.pkg file)
3. **Run:** Double-click the .pkg file
4. **Follow:** Installation wizard
5. **Initialize:** Open terminal and run `gcloud init`

---

## After Installation

### 1. Verify Installation

```bash
gcloud --version
```

### 2. Initialize gcloud

```bash
gcloud init
```

This will:
- Open browser for authentication
- Ask you to select/create a project
- Set default region

### 3. Set Project (if needed)

```bash
# List projects
gcloud projects list

# Set project
gcloud config set project YOUR_PROJECT_ID
```

### 4. Enable Required APIs

```bash
# Enable Cloud Run
gcloud services enable run.googleapis.com

# Enable Cloud Build
gcloud services enable cloudbuild.googleapis.com
```

### 5. Deploy Your App

```bash
./deploy-cloudrun.sh
```

---

## Quick Setup After Installation

```bash
# 1. Login
gcloud auth login

# 2. Set project (replace with your project ID)
gcloud config set project YOUR_PROJECT_ID

# 3. Enable APIs
gcloud services enable run.googleapis.com cloudbuild.googleapis.com

# 4. Set default region
gcloud config set run/region us-central1

# 5. Verify
gcloud config list
```

---

## Troubleshooting

### Command not found after installation

```bash
# Check if in PATH
echo $PATH | grep google-cloud-sdk

# If not, add manually
export PATH="$HOME/google-cloud-sdk/bin:$PATH"

# Make permanent (add to ~/.zshrc)
echo 'export PATH="$HOME/google-cloud-sdk/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Network issues during download

- Try downloading from browser: https://cloud.google.com/sdk/docs/install
- Use a VPN if behind firewall
- Try again later

### Authentication issues

```bash
# Re-authenticate
gcloud auth login
gcloud auth application-default login
```

---

## Alternative: Use Render (No Installation Needed)

If installation continues to fail, use **Render** instead:
- No CLI installation needed
- Web interface only
- Free tier available
- See: `QUICK_DEPLOY_OPTIONS.md`

---

## Next Steps

Once installed:
1. Run `gcloud init`
2. Create/select a project
3. Run `./deploy-cloudrun.sh`
4. Your app will be live!

