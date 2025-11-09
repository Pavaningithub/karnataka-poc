#!/bin/bash
# GitLab Self-Hosted Setup Script
# Generic setup that works for any user and environment

set -e

echo "🚀 GitLab Self-Hosted Setup"
echo "=========================="

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if podman is installed
if ! command -v podman &> /dev/null; then
    print_error "Podman is not installed. Please install Podman first."
    echo "Visit: https://podman.io/getting-started/installation"
    exit 1
fi

# Check if podman compose is available
if ! podman compose --help &> /dev/null; then
    print_error "podman compose is not available. Please update Podman or install docker-compose."
    echo "Visit: https://podman.io/getting-started/installation"
    exit 1
fi

print_status "Checking for existing containers..."

# Clean up any existing containers and volumes
CONTAINERS=$(podman ps -a --filter "name=gitlab" --format "{{.Names}}" 2>/dev/null || true)
if [ -n "$CONTAINERS" ]; then
    print_warning "Found existing GitLab containers. Cleaning up..."
    podman stop $CONTAINERS 2>/dev/null || true
    podman rm $CONTAINERS 2>/dev/null || true
fi

# Remove existing volumes
VOLUMES=$(podman volume ls --filter "name=gitlab" --format "{{.Name}}" 2>/dev/null || true)
if [ -n "$VOLUMES" ]; then
    print_warning "Found existing GitLab volumes. Removing..."
    podman volume rm $VOLUMES 2>/dev/null || true
fi

print_status "Starting GitLab services..."

# Navigate to gitlab directory
cd "$PROJECT_ROOT/gitlab"

# Start GitLab CE
print_status "Starting GitLab CE container..."
podman compose up -d gitlab

print_status "Waiting for GitLab to start (this may take 2-3 minutes)..."
sleep 30

# Wait for GitLab to be ready
print_status "Checking GitLab health..."
RETRIES=30
while [ $RETRIES -gt 0 ]; do
    if podman exec gitlab-selfhosted-gitlab gitlab-ctl status >/dev/null 2>&1; then
        print_success "GitLab is ready!"
        break
    fi
    print_status "GitLab still starting... ($RETRIES attempts left)"
    sleep 10
    RETRIES=$((RETRIES - 1))
done

if [ $RETRIES -eq 0 ]; then
    print_error "GitLab failed to start properly"
    exit 1
fi

# Get GitLab root password
print_status "Retrieving GitLab root password..."
ROOT_PASSWORD=$(podman exec gitlab-selfhosted-gitlab grep 'Password:' /etc/gitlab/initial_root_password 2>/dev/null | cut -d' ' -f2 || echo "Password file not found")

# Get runner registration token
print_status "Getting GitLab Runner registration token..."
sleep 5
RUNNER_TOKEN=$(podman exec gitlab-selfhosted-gitlab gitlab-rails runner "puts Gitlab::CurrentSettings.runners_registration_token" 2>/dev/null || echo "")

if [ -z "$RUNNER_TOKEN" ]; then
    print_warning "Could not retrieve runner token automatically. You'll need to get it from GitLab UI."
    RUNNER_TOKEN="<GET_FROM_GITLAB_UI>"
fi

# Update .env file with runner token
if [ "$RUNNER_TOKEN" != "<GET_FROM_GITLAB_UI>" ]; then
    sed -i "s/GITLAB_RUNNER_TOKEN=\"\"/GITLAB_RUNNER_TOKEN=\"$RUNNER_TOKEN\"/" .env
    print_success "Runner token updated in .env file"
fi

# Start GitLab Runner
print_status "Starting GitLab Runner..."
podman compose up -d gitlab-runner

print_success "GitLab setup completed!"
echo ""
echo "📋 Setup Summary"
echo "==============="
echo "GitLab URL: http://localhost:8929"
echo "Username: root"
echo "Password: $ROOT_PASSWORD"
echo ""
echo "Runner Token: $RUNNER_TOKEN"
echo ""
echo "🔧 Next Steps:"
echo "1. Visit http://localhost:8929"
echo "2. Login with root credentials above"
echo "3. Create a new project"
echo "4. Test the CI/CD pipeline"
echo ""
echo "🗂️ Project Structure:"
echo "- gitlab/          - GitLab CE configuration"
echo "- gitlab-runner/   - GitLab Runner configuration"  
echo "- demo-project/    - Sample project for testing"
echo "- docs/           - Documentation"
echo "- scripts/        - Setup and utility scripts"
