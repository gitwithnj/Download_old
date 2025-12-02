#!/bin/bash
# Deploy to Google Cloud Run - Serverless containers

set -e

echo "=== Deploying to Google Cloud Run ==="
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI not found!"
    echo ""
    echo "Please install Google Cloud SDK:"
    echo "  https://cloud.google.com/sdk/docs/install"
    exit 1
fi

echo "✓ gcloud CLI found"
echo ""

# Get project ID
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

if [ -z "$PROJECT_ID" ]; then
    echo "No project set. Please set a project:"
    echo "  gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

echo "Project: $PROJECT_ID"
echo ""

# Enable required APIs
echo "Enabling required APIs..."
gcloud services enable run.googleapis.com --quiet
gcloud services enable cloudbuild.googleapis.com --quiet

echo "✓ APIs enabled"
echo ""

# Set region
REGION=${REGION:-us-central1}
echo "Region: $REGION"
echo ""

# Build and push image
echo "Building and pushing image to GCR..."
gcloud builds submit --tag gcr.io/${PROJECT_ID}/resume-app

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo "✓ Image built and pushed"
echo ""

# Deploy to Cloud Run
echo "Deploying to Cloud Run..."
gcloud run deploy resume-app \
  --image gcr.io/${PROJECT_ID}/resume-app \
  --platform managed \
  --region ${REGION} \
  --allow-unauthenticated \
  --port 80 \
  --memory 256Mi \
  --cpu 1

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Deployment successful!"
    echo ""
    echo "Getting service URL..."
    SERVICE_URL=$(gcloud run services describe resume-app --region ${REGION} --format 'value(status.url)')
    echo ""
    echo "Your resume app is live at:"
    echo "  $SERVICE_URL"
    echo ""
    echo "Open in browser:"
    echo "  open $SERVICE_URL"
else
    echo ""
    echo "❌ Deployment failed"
    exit 1
fi

