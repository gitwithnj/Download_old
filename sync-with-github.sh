#!/bin/bash
# Sync resume with GitHub repository for Render deployment

set -e

echo "=== Syncing with GitHub for Render Deployment ==="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "Initializing Git repository..."
    git init
    echo "✓ Git initialized"
fi

# Check current branch
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")

echo "Current branch: $CURRENT_BRANCH"
echo ""

# Hardcoded GitHub repository
GITHUB_REPO="https://github.com/gitwithnj/Download.git"

# Check if remote exists
if git remote -v | grep -q "gitwithnj/Download"; then
    echo -e "${GREEN}✓ GitHub remote already configured${NC}"
    REMOTE_URL=$(git remote get-url origin)
    echo "Remote: $REMOTE_URL"
else
    echo "Setting up GitHub remote..."
    echo "Repository: $GITHUB_REPO"
    echo ""
    
    if git remote | grep -q "origin"; then
        git remote set-url origin "$GITHUB_REPO"
    else
        git remote add origin "$GITHUB_REPO"
    fi
    
    echo -e "${GREEN}✓ Remote configured: $GITHUB_REPO${NC}"
fi

echo ""
echo "=== Preparing for Deployment ==="
echo ""

# Add all files
echo "Adding files to Git..."
git add .

# Check if there are changes
if git diff --cached --quiet; then
    echo "No changes to commit"
else
    echo "Changes detected. Committing..."
    git commit -m "Resume app - Ready for Render deployment" || echo "Commit skipped (may already be committed)"
fi

echo ""
echo "=== Deployment Options ==="
echo ""
echo "Option 1: Push to GitHub (for Render auto-deploy)"
echo "  git push -u origin $CURRENT_BRANCH"
echo ""
echo "Option 2: Manual Render deployment"
echo "  - Go to https://dashboard.render.com"
echo "  - Connect GitHub repository"
echo "  - Deploy"
echo ""

read -p "Push to GitHub now? (y/n): " push_choice

if [ "$push_choice" = "y" ] || [ "$push_choice" = "Y" ]; then
    echo ""
    echo "Pushing to GitHub..."
    git push -u origin $CURRENT_BRANCH
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✓ Successfully pushed to GitHub!${NC}"
        echo ""
        echo "Next steps:"
        echo "1. Go to Render dashboard: https://dashboard.render.com"
        echo "2. Connect your GitHub repository"
        echo "3. Render will auto-deploy"
    else
        echo ""
        echo "❌ Push failed. Please check your GitHub credentials and permissions."
    fi
else
    echo ""
    echo "Skipping push. You can push manually later with:"
    echo "  git push -u origin $CURRENT_BRANCH"
fi

echo ""
echo "=== Render Deployment Checklist ==="
echo ""
echo "Before deploying to Render:"
echo "  [✓] Files are ready (Dockerfile, index.html, nginx.conf)"
echo "  [✓] Git repository initialized"
echo "  [ ] Code pushed to GitHub"
echo "  [ ] Render account created"
echo "  [ ] GitHub connected to Render"
echo ""
echo "After connecting GitHub to Render:"
echo "  [ ] Service created in Render"
echo "  [ ] Auto-deploy enabled"
echo "  [ ] Deployment successful"
echo "  [ ] Live URL working"
echo ""

