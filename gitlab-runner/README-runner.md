# GitLab Runner with Podman

This directory contains a Dockerfile to build a custom GitLab Runner container with Podman.

## Build the Runner Image

```bash
podman build -f Dockerfile.runner -t gitlab-runner-podman .
```

## Run the Runner Container

### Method 1: Automatic Network Detection (Recommended)

```bash
# Get GitLab container network dynamically
GITLAB_NETWORK=$(podman inspect gitlab --format '{{range $net, $conf := .NetworkSettings.Networks}}{{$net}}{{end}}')
echo "Using GitLab network: $GITLAB_NETWORK"

# For Fish shell users:
# set GITLAB_NETWORK (podman inspect gitlab --format '{{range $net, $conf := .NetworkSettings.Networks}}{{$net}}{{end}}')

podman run -d \
    --name gitlab-runner \
    --network "$GITLAB_NETWORK" \
    -e RUNNER_TOKEN="glrt-SlDDWdqI1lWeRXKNPJqZ8286MQp0OjEKdToxCw.01.120uun6fh" \
    -e GITLAB_URL="http://gitlab:8929" \
    -e RUNNER_NAME="podman-runner-1" \
    -e RUNNER_TAGS="podman,shell,ci" \
    -v gitlab-runner-config:/etc/gitlab-runner \
    -v gitlab-runner-home:/home/gitlab-runner \
    gitlab-runner-podman
```

### Method 2: Using Known Network Name

```bash
# If you know your network name (e.g., from docker-compose)
podman run -d \
    --name gitlab-runner \
    --network karnataka-poc_gitlab-network \
    -e RUNNER_TOKEN="glrt-SlDDWdqI1lWeRXKNPJqZ8286MQp0OjEKdToxCw.01.120uun6fh" \
    -e GITLAB_URL="http://gitlab:8929" \
    -e RUNNER_NAME="podman-runner-1" \
    -e RUNNER_TAGS="podman,shell,ci" \
    -v gitlab-runner-config:/etc/gitlab-runner \
    -v gitlab-runner-home:/home/gitlab-runner \
    gitlab-runner-podman
```

## Getting a New Runner Token

Before running the runner, you need to create a new runner token in GitLab:

1. **Access GitLab**: http://localhost:8929
2. **Login as root** with the password from GitLab setup
3. **Go to Admin Area** → **CI/CD** → **Runners** 
4. **Click "New instance runner"**
5. **Configure runner settings** and click "Create runner"
6. **Copy the authentication token** (starts with `glrt-`)

## Configuration Options

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `RUNNER_TOKEN` | (required) | GitLab Runner authentication token |
| `GITLAB_URL` | `http://gitlab:8929` | GitLab instance URL (use container name when on same network) |
| `RUNNER_NAME` | `podman-runner` | Runner name in GitLab |
| `RUNNER_EXECUTOR` | `shell` | Runner executor type |
| `RUNNER_DESCRIPTION` | `GitLab Runner in Podman` | Runner description |
| `RUNNER_TAGS` | `podman,shell,docker` | Runner tags for job selection |

## Manage the Runner

```bash
# Check runner status
podman ps --filter name=gitlab-runner

# View runner logs
podman logs gitlab-runner

# Stop runner
podman stop gitlab-runner

# Remove runner
podman rm gitlab-runner

# Clean up volumes (optional)
podman volume rm gitlab-runner-config gitlab-runner-home
```

## Features

- ✅ Automatic runner registration with authentication token
- ✅ Pre-installed development tools (git, curl, python3, nodejs)
- ✅ Shell executor for flexible job execution
- ✅ Persistent configuration and data volumes
- ✅ Automatic network detection for GitLab connectivity
- ✅ Container-to-container communication on shared networks
