#!/bin/bash
# Final deployment script for Render
# This script prepares everything and guides you through final deployment

set -e

echo "=== Final Render Deployment ==="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

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

# Step 3: Check Git status
echo "Step 2: Checking Git repository..."
echo ""

if [ -d ".git" ]; then
    echo -e "${GREEN}✓ Git repository initialized${NC}"
    
    # Check if files are committed
    if git diff --quiet && git diff --cached --quiet; then
        echo -e "${GREEN}✓ All changes committed${NC}"
        COMMITTED=true
    else
        echo -e "${YELLOW}⚠ Uncommitted changes detected${NC}"
        COMMITTED=false
    fi
    
    # Check remote
    if git remote -v | grep -q "origin"; then
        REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
        echo -e "${GREEN}✓ Git remote configured: ${REMOTE_URL}${NC}"
        HAS_REMOTE=true
    else
        echo -e "${YELLOW}⚠ No Git remote configured${NC}"
        HAS_REMOTE=false
    fi
else
    echo -e "${YELLOW}⚠ Git repository not initialized${NC}"
    COMMITTED=false
    HAS_REMOTE=false
fi

echo ""

# Step 4: Deployment options
echo "=== Deployment Options ==="
echo ""
echo "Since Render is web-based, you have two options:"
echo ""
echo "Option 1: Web Interface (Recommended)"
echo "  - Go to https://render.com"
echo "  - Connect GitHub repository"
echo "  - Render will auto-deploy"
echo ""
echo "Option 2: Render CLI"
echo "  - Requires: npm install -g render"
echo "  - Command: render deploy"
echo ""

# Check if Render CLI is available
if command -v render &> /dev/null; then
    echo -e "${GREEN}✓ Render CLI is installed${NC}"
    echo ""
    read -p "Deploy using Render CLI? (y/n): " use_cli
    
    if [ "$use_cli" = "y" ] || [ "$use_cli" = "Y" ]; then
        echo ""
        echo "Deploying with Render CLI..."
        
        # Check login
        if ! render whoami &> /dev/null; then
            echo "Please login to Render..."
            render login
        fi
        
        # Deploy
        render deploy
        
        if [ $? -eq 0 ]; then
            echo ""
            echo -e "${GREEN}✓ Deployment successful!${NC}"
            echo ""
            echo "Getting service URL..."
            render services list
        else
            echo ""
            echo -e "${RED}❌ Deployment failed${NC}"
            echo "Try web interface instead."
            show_web_steps
        fi
        exit 0
    fi
fi

# Show web interface steps
show_web_steps() {
    echo ""
    echo "=== Web Interface Deployment Steps ==="
    echo ""
    
    if [ "$HAS_REMOTE" = false ] || [ "$COMMITTED" = false ]; then
        echo "First, prepare your GitHub repository:"
        echo ""
        
        if [ ! -d ".git" ]; then
            echo "1. Initialize Git:"
            echo "   git init"
            echo ""
        fi
        
        if [ "$COMMITTED" = false ]; then
            echo "2. Add and commit files:"
            echo "   git add ."
            echo "   git commit -m 'Resume app for Render deployment'"
            echo ""
        fi
        
        if [ "$HAS_REMOTE" = false ]; then
            echo "3. Add GitHub remote and push:"
            echo "   git remote add origin https://github.com/gitwithnj/Download.git"
            echo "   git push -u origin main"
            echo ""
        else
            echo "3. Push to GitHub:"
            echo "   git push"
            echo ""
        fi
    else
        echo -e "${GREEN}✓ Git repository ready${NC}"
        echo ""
        echo "Push to GitHub (if not already pushed):"
        echo "   git push"
        echo ""
    fi
    
    echo "4. Go to Render Dashboard:"
    echo "   https://dashboard.render.com"
    echo ""
    echo "5. Click 'New' → 'Web Service'"
    echo ""
    echo "6. Connect GitHub:"
    echo "   - Click 'Connect GitHub'"
    echo "   - Authorize Render"
    echo "   - Select repository: gitwithnj/Download"
    echo ""
    echo "7. Configure Service:"
    echo "   - Name: resume-app (or your preferred name)"
    echo "   - Environment: Docker"
    echo "   - Region: Choose closest to you"
    echo "   - Branch: main (or your default branch)"
    echo "   - Root Directory: . (leave as is)"
    echo "   - Dockerfile Path: ./Dockerfile.alternative"
    echo "   - Docker Context: . (leave as is)"
    echo ""
    echo "8. Advanced Settings (optional):"
    echo "   - Plan: Free"
    echo "   - Auto-Deploy: Yes (recommended)"
    echo "   - Health Check Path: /"
    echo ""
    echo "9. Click 'Create Web Service'"
    echo ""
    echo "10. Wait for deployment (2-3 minutes)"
    echo ""
    echo "11. Your app will be live at:"
    echo "    https://resume-app.onrender.com"
    echo "    (or your custom name)"
    echo ""
    echo "=== Deployment Checklist ==="
    echo ""
    echo "Before deploying, ensure:"
    echo "  [ ] All files are committed to Git"
    echo "  [ ] Code is pushed to GitHub"
    echo "  [ ] GitHub repository is accessible"
    echo "  [ ] You have a Render account (free)"
    echo ""
    echo "After deployment:"
    echo "  [ ] Test the live URL"
    echo "  [ ] Check Render logs for errors"
    echo "  [ ] Verify HTTPS is working"
    echo "  [ ] Test on mobile device"
    echo "  [ ] Test print functionality"
    echo ""
}

show_web_steps

echo ""
echo "=== Quick Commands ==="
echo ""
echo "If you need to prepare Git repository:"
echo ""
echo "  # Initialize (if not done)"
echo "  git init"
echo ""
echo "  # Add files"
echo "  git add ."
echo ""
echo "  # Commit"
echo "  git commit -m 'Resume app for Render'"
echo ""
echo "  # Add remote"
echo "  git remote add origin https://github.com/gitwithnj/Download.git"
echo ""
echo "  # Push"
echo "  git push -u origin main"
echo ""

echo -e "${GREEN}=== Ready for Deployment! ===${NC}"
echo ""
echo "Follow the web interface steps above to complete deployment."

