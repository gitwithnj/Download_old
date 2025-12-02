# Installing Google Cloud SDK (gcloud CLI)

## macOS Installation

### Option 1: Using Homebrew (Easiest)

```bash
# Install gcloud CLI
brew install --cask google-cloud-sdk

# Initialize
gcloud init
```

### Option 2: Using Install Script

```bash
# Download and run installer
curl https://sdk.cloud.google.com | bash

# Restart shell or source
exec -l $SHELL

# Initialize
gcloud init
```

### Option 3: Manual Installation

```bash
# Download SDK
cd ~
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-darwin-x86_64.tar.gz

# Extract
tar -xzf google-cloud-cli-darwin-x86_64.tar.gz

# Run installer
./google-cloud-sdk/install.sh

# Add to PATH (add to ~/.zshrc or ~/.bash_profile)
echo 'export PATH="$HOME/google-cloud-sdk/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Initialize
gcloud init
```

## After Installation

### 1. Initialize gcloud

```bash
gcloud init
```

This will:
- Ask you to login
- Select or create a project
- Set default region/zone

### 2. Set Project

```bash
# List projects
gcloud projects list

# Set project
gcloud config set project YOUR_PROJECT_ID
```

### 3. Enable Required APIs

```bash
# Enable Cloud Run API
gcloud services enable run.googleapis.com

# Enable Cloud Build API
gcloud services enable cloudbuild.googleapis.com

# Enable Container Registry API
gcloud services enable containerregistry.googleapis.com
```

### 4. Authenticate

```bash
# Login
gcloud auth login

# Set application default credentials
gcloud auth application-default login
```

## Verify Installation

```bash
# Check version
gcloud --version

# Check current config
gcloud config list

# Check if authenticated
gcloud auth list
```

## Quick Setup Script

Run this after installation:

```bash
# Set your project ID
export PROJECT_ID="your-project-id"

# Set project
gcloud config set project $PROJECT_ID

# Enable APIs
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable containerregistry.googleapis.com

# Set default region
gcloud config set run/region us-central1

# Verify
gcloud config list
```

## Free Tier Setup

### Create Free Project

1. Go to: https://console.cloud.google.com/
2. Create new project (or use free tier)
3. Get $300 free credit for 90 days
4. Always free tier includes:
   - Cloud Run: 2 million requests/month
   - Cloud Build: 120 build-minutes/day
   - Container Registry: 0.5 GB storage

## Deploy to Cloud Run

Once gcloud is installed:

```bash
# Use the deployment script
./deploy-cloudrun.sh

# Or manually:
gcloud builds submit --tag gcr.io/YOUR_PROJECT/resume-app
gcloud run deploy resume-app \
  --image gcr.io/YOUR_PROJECT/resume-app \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

## Troubleshooting

### Command not found
```bash
# Add to PATH
export PATH="$HOME/google-cloud-sdk/bin:$PATH"

# Or add to ~/.zshrc
echo 'export PATH="$HOME/google-cloud-sdk/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Authentication issues
```bash
# Re-authenticate
gcloud auth login
gcloud auth application-default login
```

### Project not set
```bash
# List projects
gcloud projects list

# Set project
gcloud config set project YOUR_PROJECT_ID
```

## Next Steps

After installation:
1. Run `gcloud init`
2. Login and select project
3. Run `./deploy-cloudrun.sh`
4. Your app will be deployed!

