#!/bin/bash

# Simple deployment script for Karnataka PoC Web App
# This script will be executed by GitLab CI/CD pipeline

set -e  # Exit on any error

echo "🚀 Starting deployment to EC2..."

# Configuration
DEPLOY_DIR="/var/www/html"
APP_NAME="karnataka-poc-webapp"
BACKUP_DIR="/var/backups/webapp"

# Create backup of existing deployment if it exists
if [ -d "$DEPLOY_DIR" ]; then
    echo "📦 Creating backup of existing deployment..."
    sudo mkdir -p "$BACKUP_DIR"
    sudo cp -r "$DEPLOY_DIR" "$BACKUP_DIR/backup-$(date +%Y%m%d-%H%M%S)" || true
fi

# Ensure deployment directory exists
echo "📁 Preparing deployment directory..."
sudo mkdir -p "$DEPLOY_DIR"

# Copy application files
echo "📋 Copying application files..."
sudo cp index.html "$DEPLOY_DIR/"

# Set proper permissions
echo "🔒 Setting file permissions..."
sudo chown -R www-data:www-data "$DEPLOY_DIR" || sudo chown -R nginx:nginx "$DEPLOY_DIR" || true
sudo chmod -R 644 "$DEPLOY_DIR"/*

# Restart web server (try multiple options)
echo "🔄 Restarting web server..."
sudo systemctl restart nginx 2>/dev/null || sudo systemctl restart apache2 2>/dev/null || true

echo "✅ Deployment completed successfully!"
echo "🌐 Web application should be accessible at your EC2 public IP"
