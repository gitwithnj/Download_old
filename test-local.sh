#!/bin/bash
# Simple local test using Python HTTP server (no Docker/Podman needed)

echo "Starting local test server..."
echo "Serving resume.html on http://localhost:8080"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Check if Python 3 is available
if command -v python3 &> /dev/null; then
    cd "$(dirname "$0")"
    python3 -m http.server 8080
elif command -v python &> /dev/null; then
    cd "$(dirname "$0")"
    python -m SimpleHTTPServer 8080
else
    echo "Python not found. Trying Node.js..."
    if command -v npx &> /dev/null; then
        npx http-server -p 8080 -o resume.html
    else
        echo "Please install Python 3 or Node.js to test locally"
        exit 1
    fi
fi


