#!/bin/bash
# Direct Google Cloud SDK installation (bypasses Homebrew)

set -e

echo "=== Installing Google Cloud SDK (Direct Method) ==="
echo ""

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    DOWNLOAD_URL="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-darwin-arm64.tar.gz"
    ARCH_NAME="arm64"
else
    DOWNLOAD_URL="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-darwin-x86_64.tar.gz"
    ARCH_NAME="x86_64"
fi

echo "Detected architecture: $ARCH_NAME"
echo ""

# Check if already installed
if command -v gcloud &> /dev/null; then
    echo "✓ gcloud is already installed"
    gcloud --version
    exit 0
fi

# Create temp directory
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

echo "Downloading Google Cloud SDK..."
echo "URL: $DOWNLOAD_URL"
echo ""

# Try to download
if curl -L -o gcloud-sdk.tar.gz "$DOWNLOAD_URL" 2>/dev/null; then
    echo "✓ Download complete"
    echo ""
    echo "Extracting..."
    tar -xzf gcloud-sdk.tar.gz
    
    echo "Installing..."
    ./google-cloud-sdk/install.sh --quiet --usage-reporting=false --path-update=true
    
    # Move to home directory
    mv google-cloud-sdk ~/google-cloud-sdk
    
    echo ""
    echo "✓ Installation complete!"
    echo ""
    
    # Add to PATH
    if [ -f ~/.zshrc ]; then
        if ! grep -q "google-cloud-sdk/bin" ~/.zshrc; then
            echo 'export PATH="$HOME/google-cloud-sdk/bin:$PATH"' >> ~/.zshrc
            echo "✓ Added to ~/.zshrc"
        fi
    elif [ -f ~/.bash_profile ]; then
        if ! grep -q "google-cloud-sdk/bin" ~/.bash_profile; then
            echo 'export PATH="$HOME/google-cloud-sdk/bin:$PATH"' >> ~/.bash_profile
            echo "✓ Added to ~/.bash_profile"
        fi
    fi
    
    # Cleanup
    cd ~
    rm -rf "$TMP_DIR"
    
    echo ""
    echo "=== Next Steps ==="
    echo ""
    echo "1. Restart your terminal or run:"
    echo "   source ~/.zshrc"
    echo ""
    echo "2. Initialize gcloud:"
    echo "   gcloud init"
    echo ""
    echo "3. Deploy your app:"
    echo "   ./deploy-cloudrun.sh"
    
else
    echo "❌ Download failed"
    echo ""
    echo "Please install manually:"
    echo ""
    echo "Option 1: Browser Download"
    echo "  1. Visit: https://cloud.google.com/sdk/docs/install"
    echo "  2. Download macOS installer"
    echo "  3. Run the .pkg file"
    echo ""
    echo "Option 2: Manual Download"
    echo "  Download: $DOWNLOAD_URL"
    echo "  Extract: tar -xzf google-cloud-cli-darwin-*.tar.gz"
    echo "  Install: ./google-cloud-sdk/install.sh"
    echo ""
    echo "Option 3: Use Render (No Installation)"
    echo "  See: QUICK_DEPLOY_OPTIONS.md"
    
    rm -rf "$TMP_DIR"
    exit 1
fi

