#!/bin/bash
# Final deployment script for Render using gitwithnj/Download repository
# This script automates the Git setup and prepares for Render deployment

set -e

# Hardcoded GitHub repository
GITHUB_REPO="https://github.com/gitwithnj/Download.git"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo "=== Final Render Deployment ==="
echo "Repository: $GITHUB_REPO"
echo ""

# Step 1: Verify files
echo "Step 1: Verifying required files..."
echo ""

REQUIRED_FILES=("Dockerfile.alternative" "index.html" "nginx.conf")
ALL_PRESENT=true

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $file"
    else
        echo -e "${RED}✗${NC} $file (MISSING)"
        ALL_PRESENT=false
    fi
done

if [ "$ALL_PRESENT" = false ]; then
    echo ""
    echo -e "${RED}❌ Missing required files. Please ensure all files are present.${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ All required files present${NC}"
echo ""

# Step 2: Check render.yaml
if [ -f "render.yaml" ]; then
    echo -e "${GREEN}✓ render.yaml found${NC}"
else
    echo -e "${YELLOW}⚠ Creating render.yaml...${NC}"
    cat > render.yaml << 'EOF'
services:
  - type: web
    name: resume-app
    env: docker
    dockerfilePath: ./Dockerfile.alternative
    dockerContext: .
    plan: free
    healthCheckPath: /
    envVars:
      - key: PORT
        value: 80
EOF
    echo -e "${GREEN}✓ render.yaml created${NC}"
fi

echo ""

# Step 3: Setup Git repository
echo "Step 2: Setting up Git repository..."
echo ""

# Initialize Git if needed
if [ ! -d ".git" ]; then
    echo "Initializing Git repository..."
    git init
    echo -e "${GREEN}✓ Git initialized${NC}"
fi

# Set up remote
if git remote -v | grep -q "gitwithnj/Download"; then
    echo -e "${GREEN}✓ GitHub remote already configured${NC}"
    REMOTE_URL=$(git remote get-url origin)
    echo "Remote: $REMOTE_URL"
else
    echo "Configuring GitHub remote..."
    if git remote | grep -q "origin"; then
        git remote set-url origin "$GITHUB_REPO"
    else
        git remote add origin "$GITHUB_REPO"
    fi
    echo -e "${GREEN}✓ Remote configured: $GITHUB_REPO${NC}"
fi

# Check current branch
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
echo "Current branch: $CURRENT_BRANCH"
echo ""

# Add and commit files
echo "Step 3: Preparing files for commit..."
echo ""

git add .

# Check if there are changes
if git diff --cached --quiet && git diff --quiet; then
    echo -e "${GREEN}✓ All changes already committed${NC}"
    COMMITTED=true
else
    echo "Committing changes..."
    git commit -m "Resume app - Ready for Render deployment" || echo "Commit skipped (may already be committed)"
    COMMITTED=true
fi

echo ""

# Step 4: Push to GitHub
echo "Step 4: Push to GitHub..."
echo ""

read -p "Push to GitHub now? (y/n): " push_choice

if [ "$push_choice" = "y" ] || [ "$push_choice" = "Y" ]; then
    echo ""
    echo "Pushing to GitHub..."
    git push -u origin $CURRENT_BRANCH || {
        echo ""
        echo -e "${YELLOW}⚠ Push failed. This might be normal if:${NC}"
        echo "  - You don't have write access to the repository"
        echo "  - You need to authenticate with GitHub"
        echo "  - The branch name doesn't match (main vs master)"
        echo ""
        echo "You can push manually later with:"
        echo "  git push -u origin $CURRENT_BRANCH"
        echo ""
    }
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✓ Successfully pushed to GitHub!${NC}"
    fi
else
    echo ""
    echo "Skipping push. You can push manually later with:"
    echo "  git push -u origin $CURRENT_BRANCH"
fi

echo ""

# Step 5: Render deployment instructions
echo "=== Render Deployment Instructions ==="
echo ""
echo "Now that your code is ready, deploy to Render:"
echo ""
echo "1. Go to Render Dashboard:"
echo "   https://dashboard.render.com"
echo ""
echo "2. Sign up / Login (free account)"
echo ""
echo "3. Click 'New' → 'Web Service'"
echo ""
echo "4. Connect GitHub:"
echo "   - Click 'Connect GitHub'"
echo "   - Authorize Render to access your GitHub"
echo "   - Select repository: ${GREEN}gitwithnj/Download${NC}"
echo ""
echo "5. Configure Service:"
echo "   - Name: resume-app (or your preferred name)"
echo "   - Environment: ${GREEN}Docker${NC}"
echo "   - Region: Choose closest to you"
echo "   - Branch: ${GREEN}$CURRENT_BRANCH${NC}"
echo "   - Root Directory: . (leave as is)"
echo "   - Dockerfile Path: ${GREEN}./Dockerfile.alternative${NC}"
echo "   - Docker Context: . (leave as is)"
echo ""
echo "6. Advanced Settings (optional):"
echo "   - Plan: Free"
echo "   - Auto-Deploy: Yes (recommended)"
echo "   - Health Check Path: /"
echo ""
echo "7. Click 'Create Web Service'"
echo ""
echo "8. Wait for deployment (2-3 minutes)"
echo "   - Render will build your Docker image"
echo "   - Deploy the container"
echo "   - Provide a live URL"
echo ""
echo "9. Your app will be live at:"
echo "   https://resume-app.onrender.com"
echo "   (or your custom service name)"
echo ""

# Step 6: Deployment checklist
echo "=== Deployment Checklist ==="
echo ""
echo "Before deploying:"
echo "  [✓] Files are ready (Dockerfile.alternative, index.html, nginx.conf)"
echo "  [✓] render.yaml configured"
echo "  [✓] Git repository initialized"
echo "  [✓] GitHub remote configured: $GITHUB_REPO"
if [ "$COMMITTED" = true ]; then
    echo -e "  [${GREEN}✓${NC}] Changes committed"
else
    echo -e "  [${YELLOW}⚠${NC}] Changes need to be committed"
fi
echo "  [ ] Code pushed to GitHub"
echo "  [ ] Render account created"
echo "  [ ] GitHub connected to Render"
echo ""
echo "After deployment:"
echo "  [ ] Service created in Render"
echo "  [ ] Auto-deploy enabled"
echo "  [ ] Deployment successful"
echo "  [ ] Live URL working"
echo "  [ ] Test resume display"
echo "  [ ] Test print functionality"
echo ""

echo -e "${GREEN}=== Ready for Render Deployment! ===${NC}"
echo ""
echo "Follow the instructions above to complete deployment on Render."

