#!/bin/bash

# GitLab Runner Registration and Startup Script
set -e

# Configuration
GITLAB_URL=${GITLAB_URL:-"http://localhost:8929"}
RUNNER_TOKEN=${RUNNER_TOKEN:-""}
RUNNER_NAME=${RUNNER_NAME:-"podman-runner"}
RUNNER_EXECUTOR=${RUNNER_EXECUTOR:-"shell"}
RUNNER_DESCRIPTION=${RUNNER_DESCRIPTION:-"GitLab Runner in Podman"}
RUNNER_TAGS=${RUNNER_TAGS:-"podman,shell,docker"}

echo "=== GitLab Runner Setup ==="
echo "GitLab URL: $GITLAB_URL"
echo "Runner Name: $RUNNER_NAME"
echo "Runner Executor: $RUNNER_EXECUTOR"
echo "Runner Tags: $RUNNER_TAGS"

# Check if runner is already registered
if [ ! -f /etc/gitlab-runner/config.toml ] || [ ! -s /etc/gitlab-runner/config.toml ]; then
    echo "Registering GitLab Runner..."
    
    # Validate token
    if [ -z "$RUNNER_TOKEN" ]; then
        echo "ERROR: RUNNER_TOKEN environment variable is required!"
        echo "Usage: podman run -e RUNNER_TOKEN=glrt-xxx..."
        exit 1
    fi
    
    # Register runner using new authentication method
    gitlab-runner register \
        --non-interactive \
        --url "$GITLAB_URL" \
        --token "$RUNNER_TOKEN" \
        --executor "$RUNNER_EXECUTOR" \
        --clone-url "http://gitlab:8929"
    
    echo "Runner registered successfully!"
else
    echo "Runner already registered, skipping registration."
fi

# Start the runner
echo "Starting GitLab Runner..."
exec gitlab-runner run --user gitlab-runner --working-directory /home/gitlab-runner
