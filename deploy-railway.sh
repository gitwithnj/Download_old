#!/bin/bash
# Deploy to Railway - Easiest free hosting option

set -e

echo "=== Deploying to Railway ==="
echo ""

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "Railway CLI not found. Installing..."
    echo ""
    echo "Installing Railway CLI..."
    npm install -g @railway/cli
    
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install Railway CLI"
        echo ""
        echo "Please install manually:"
        echo "  npm install -g @railway/cli"
        echo "Or visit: https://railway.app/docs/develop/cli"
        exit 1
    fi
fi

echo "✓ Railway CLI found"
echo ""

# Check if logged in
if ! railway whoami &> /dev/null; then
    echo "Not logged in. Please login..."
    railway login
fi

echo "✓ Logged in to Railway"
echo ""

# Initialize project if needed
if [ ! -f "railway.json" ] && [ ! -f ".railway" ]; then
    echo "Initializing Railway project..."
    railway init
fi

echo "Deploying to Railway..."
echo ""

# Deploy
railway up

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Deployment successful!"
    echo ""
    echo "Getting your app URL..."
    railway domain
    
    echo ""
    echo "Your resume app is now live!"
    echo ""
    echo "To view logs:"
    echo "  railway logs"
    echo ""
    echo "To open in browser:"
    echo "  railway open"
else
    echo ""
    echo "❌ Deployment failed"
    exit 1
fi

