#!/bin/bash
# Fetch resume data from GitHub and update local files

set -e

echo "=== Fetching Resume Data from GitHub ==="
echo ""

GITHUB_URL="https://raw.githubusercontent.com/gitwithnj/Download/main/nj"
LOCAL_FILE="nj"

echo "Fetching from: $GITHUB_URL"
echo ""

# Fetch the file
if curl -s -f "$GITHUB_URL" > "$LOCAL_FILE.tmp"; then
    echo "✓ Successfully fetched from GitHub"
    
    # Compare with local file
    if [ -f "$LOCAL_FILE" ]; then
        if diff -q "$LOCAL_FILE" "$LOCAL_FILE.tmp" > /dev/null 2>&1; then
            echo "✓ Local file is up to date"
            rm "$LOCAL_FILE.tmp"
        else
            echo "⚠ Local file differs from GitHub"
            echo ""
            read -p "Update local file from GitHub? (y/n): " update
            
            if [ "$update" = "y" ] || [ "$update" = "Y" ]; then
                mv "$LOCAL_FILE.tmp" "$LOCAL_FILE"
                echo "✓ Local file updated from GitHub"
            else
                rm "$LOCAL_FILE.tmp"
                echo "Local file kept as is"
            fi
        fi
    else
        mv "$LOCAL_FILE.tmp" "$LOCAL_FILE"
        echo "✓ Created local file from GitHub"
    fi
else
    echo "❌ Failed to fetch from GitHub"
    echo "Please check the URL or your internet connection"
    exit 1
fi

echo ""
echo "=== Next Steps ==="
echo ""
echo "If you need to regenerate the HTML resume from this data:"
echo "  - The resume HTML (index.html) should already be up to date"
echo "  - Or manually update index.html with any changes"
echo ""
echo "To deploy to Render:"
echo "  ./final-deploy-render.sh"

