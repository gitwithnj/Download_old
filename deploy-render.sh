#!/bin/bash
# Script to prepare and deploy to Render
# Render is primarily web-based, but this script helps prepare everything

set -e

echo "=== Render Deployment Preparation ==="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if required files exist
echo "Checking required files..."

REQUIRED_FILES=("Dockerfile.alternative" "index.html" "nginx.conf")
MISSING_FILES=()

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $file"
    else
        echo -e "${YELLOW}✗${NC} $file (missing)"
        MISSING_FILES+=("$file")
    fi
done

if [ ${#MISSING_FILES[@]} -gt 0 ]; then
    echo ""
    echo "Missing files: ${MISSING_FILES[*]}"
    echo "Please ensure all required files are present."
    exit 1
fi

echo ""
echo -e "${GREEN}✓ All required files present${NC}"
echo ""

# Check if render.yaml exists
if [ -f "render.yaml" ]; then
    echo -e "${GREEN}✓ render.yaml found${NC}"
else
    echo -e "${YELLOW}⚠ render.yaml not found, creating...${NC}"
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
    echo -e "${GREEN}✓ Created render.yaml${NC}"
fi

echo ""
echo "=== Deployment Options ==="
echo ""
echo "Render is primarily web-based. Choose your deployment method:"
echo ""
echo "Option 1: Web Interface (Recommended - No CLI needed)"
echo "  1. Go to: https://render.com"
echo "  2. Sign up (free)"
echo "  3. Click 'New' → 'Web Service'"
echo "  4. Connect your GitHub repository"
echo "  5. Render will auto-detect Dockerfile"
echo "  6. Click 'Create Web Service'"
echo ""
echo "Option 2: Render CLI (If you want command-line)"
echo "  1. Install: npm install -g render"
echo "  2. Login: render login"
echo "  3. Deploy: render deploy"
echo ""

# Function to show web interface instructions
show_web_instructions() {
    echo ""
    echo "=== Web Interface Deployment Steps ==="
    echo ""
    echo "1. Push your code to GitHub:"
    echo "   git init"
    echo "   git add ."
    echo "   git commit -m 'Resume app for Render'"
    echo "   git remote add origin https://github.com/gitwithnj/Download.git"
    echo "   git push -u origin main"
    echo ""
    echo "2. Go to Render:"
    echo "   https://render.com"
    echo ""
    echo "3. Sign up / Login (free)"
    echo ""
    echo "4. Click 'New' → 'Web Service'"
    echo ""
    echo "5. Connect GitHub and select repository: gitwithnj/Download"
    echo ""
    echo "6. Configure:"
    echo "   - Name: resume-app"
    echo "   - Environment: Docker"
    echo "   - Dockerfile Path: ./Dockerfile.alternative"
    echo "   - Build Command: (leave empty)"
    echo "   - Start Command: (auto-detected)"
    echo ""
    echo "7. Click 'Create Web Service'"
    echo ""
    echo "8. Wait for deployment (2-3 minutes)"
    echo ""
    echo "9. Your app will be live at: https://resume-app.onrender.com"
    echo ""
    echo "=== Files Ready for Deployment ==="
    echo ""
    echo "Required files:"
    ls -lh Dockerfile.alternative index.html nginx.conf render.yaml 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}'
    echo ""
    echo "All set! Follow the web interface steps above."
}

# Check if Render CLI is installed
if command -v render &> /dev/null; then
    echo -e "${GREEN}✓ Render CLI is installed${NC}"
    echo ""
    read -p "Use Render CLI to deploy? (y/n): " use_cli
    
    if [ "$use_cli" = "y" ] || [ "$use_cli" = "Y" ]; then
        echo ""
        echo "Deploying with Render CLI..."
        
        # Check if logged in
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
            echo "Get your service URL:"
            render services list
        else
            echo ""
            echo "Deployment failed. Try web interface instead."
            show_web_instructions
        fi
    else
        show_web_instructions
    fi
else
    show_web_instructions
fi

echo ""
echo "=== Alternative: Install Render CLI ==="
echo ""
echo "If you want to use CLI:"
echo "  npm install -g render"
echo "  render login"
echo "  render deploy"
echo ""

