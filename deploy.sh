#!/bin/bash
# This script builds the website and deploys it to the production server via rsync

# Exit immediately if a command exits with a non-zero status
set -e

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Build the project using Docker Compose
log "Building the project..."
if ! docker compose exec -T web npm run build; then
    log "Error: Build failed"
    exit 1
fi

# Check if the dist directory exists
if [ ! -d "dist" ]; then
    log "Error: dist directory not found. Make sure the build process creates this directory."
    exit 1
fi

# remove the contents of /home/quantumg/simonbermudez.com/logo/ 
log "Removing contents of /home/quantumg/simonbermudez.com/logo/"
if ! ssh -p 7822 quantumg@quantumgl.org "rm -rf /home/quantumg/simonbermudez.com/logo/*"; then
    log "Error: Failed to remove contents of /home/quantumg/simonbermudez.com/logo/"
    exit 1
fi

# Deploy to the production server using rsync
log "Deploying to production server..."
if ! rsync -avz -e "ssh -p 7822" dist/ quantumgl.org:/home/quantumg/simonbermudez.com/logo/; then
    log "Error: Deployment failed"
    exit 1
fi

log "Deployment completed successfully!"
