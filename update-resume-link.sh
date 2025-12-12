#!/bin/bash
# Script to update resume with Render URL

set -e

echo "=== Update Resume with Render URL ==="
echo ""

# Get Render URL from user
read -p "Enter your Render URL (e.g., https://resume-app.onrender.com): " RENDER_URL

if [ -z "$RENDER_URL" ]; then
    echo "❌ URL cannot be empty"
    exit 1
fi

# Remove trailing slash
RENDER_URL=$(echo "$RENDER_URL" | sed 's:/*$::')

echo ""
echo "Updating resume with URL: $RENDER_URL"
echo ""

# Update index.html - find the "Link" section and update
if grep -q 'href="link"' index.html; then
    # Update placeholder link
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s|href=\"link\"|href=\"$RENDER_URL\"|g" index.html
    else
        # Linux
        sed -i "s|href=\"link\"|href=\"$RENDER_URL\"|g" index.html
    fi
    echo "✓ Updated link in header"
fi

# Update showcase section
if grep -q 'href="link"' index.html; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|href=\"link\"|href=\"$RENDER_URL\"|g" index.html
    else
        sed -i "s|href=\"link\"|href=\"$RENDER_URL\"|g" index.html
    fi
    echo "✓ Updated showcase link"
fi

echo ""
echo "✅ Resume updated with Render URL!"
echo ""
echo "Next steps:"
echo "1. Commit changes: git add index.html && git commit -m 'Add Render URL'"
echo "2. Push to GitHub: git push"
echo "3. Render will auto-deploy the update"
echo ""
echo "Your resume is now linked to: $RENDER_URL"

