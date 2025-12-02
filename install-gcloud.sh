#!/bin/bash
# Install Google Cloud SDK on macOS

set -e

echo "=== Installing Google Cloud SDK ==="
echo ""

# Check if already installed
if command -v gcloud &> /dev/null; then
    echo "✓ gcloud is already installed"
    gcloud --version
    echo ""
    read -p "Reinstall? (y/n): " reinstall
    if [ "$reinstall" != "y" ] && [ "$reinstall" != "Y" ]; then
        echo "Skipping installation"
        exit 0
    fi
fi

# Check for Homebrew
if command -v brew &> /dev/null; then
    echo "✓ Homebrew found - Using Homebrew installation"
    echo ""
    echo "Installing Google Cloud SDK..."
    brew install --cask google-cloud-sdk
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✓ Installation complete!"
        echo ""
        echo "Next steps:"
        echo "1. Restart your terminal or run: source ~/.zshrc"
        echo "2. Run: gcloud init"
        echo "3. Login and select/create a project"
        echo "4. Run: ./deploy-cloudrun.sh"
    else
        echo "❌ Installation failed"
        exit 1
    fi
else
    echo "⚠ Homebrew not found"
    echo ""
    echo "Installing via official installer..."
    echo ""
    
    # Download installer
    cd /tmp
    curl -O https://sdk.cloud.google.com
    
    if [ $? -eq 0 ]; then
        echo "Running installer..."
        bash google-cloud-sdk/install.sh --quiet
        
        echo ""
        echo "✓ Installation complete!"
        echo ""
        echo "Add to PATH:"
        echo "  export PATH=\"\$HOME/google-cloud-sdk/bin:\$PATH\""
        echo ""
        echo "Or add to ~/.zshrc:"
        echo "  echo 'export PATH=\"\$HOME/google-cloud-sdk/bin:\$PATH\"' >> ~/.zshrc"
        echo "  source ~/.zshrc"
        echo ""
        echo "Then run:"
        echo "  gcloud init"
    else
        echo "❌ Download failed"
        echo ""
        echo "Please install manually:"
        echo "  https://cloud.google.com/sdk/docs/install"
        exit 1
    fi
fi

echo ""
echo "=== Installation Complete ==="
echo ""
echo "To initialize gcloud:"
echo "  gcloud init"
echo ""
echo "To deploy your app:"
echo "  ./deploy-cloudrun.sh"

