#!/bin/bash
# Startup script for nginx that uses Render's PORT environment variable
# This ensures the service binds to 0.0.0.0 and uses the dynamic port

set -e

# Get PORT from environment variable, default to 80 if not set
PORT=${PORT:-80}

echo "Starting nginx on port $PORT (0.0.0.0:$PORT)"

# Create nginx config with dynamic port
cat > /etc/nginx/sites-available/default <<EOF
server {
    listen ${PORT};
    listen [::]:${PORT};
    server_name _;
    root /var/www/html;
    index resume.html;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/javascript application/json;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Main location
    location / {
        try_files \$uri \$uri/ /resume.html;
    }

    # Cache static assets
    location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Error pages
    error_page 404 /resume.html;
    error_page 500 502 503 504 /resume.html;
}
EOF

# Test nginx configuration
nginx -t

# Start nginx in foreground mode (required for containers)
exec nginx -g "daemon off;"

