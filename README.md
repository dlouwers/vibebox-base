# VibeBox Base

[![Docker Image](https://img.shields.io/docker/v/dlouwers/vibebox-base?label=Docker%20Hub)](https://hub.docker.com/r/dlouwers/vibebox-base)
[![Build Status](https://github.com/dlouwers/vibebox-base/actions/workflows/publish.yml/badge.svg)](https://github.com/dlouwers/vibebox-base/actions)

Secure, reusable Docker base image for Vibe Coding agents. Provides isolated tooling and sandboxed execution environment.

## Features

- **Multi-Architecture Support**: Native support for AMD64 (x86_64) and ARM64 (Apple Silicon, Raspberry Pi)
- **Debian Bookworm Base**: Stable, slim foundation from Microsoft Dev Containers
- **Pre-installed Tools**: `opencode-ai`, `vibebox`, Node.js, npm
- **Security First**: Strict isolation via `vibebox.toml` with blocked sensitive paths
- **CI/CD Ready**: Automated builds and publishing via GitHub Actions
- **Auto-updates**: Dependabot monitoring for base image and action updates

## Quick Start

### Pull from DockerHub

```bash
docker pull dlouwers/vibebox-base:latest
```

The image automatically pulls the correct architecture for your platform (AMD64 or ARM64).

### Run Interactive Container

```bash
docker run -it --rm -v $(pwd):/workspaces dlouwers/vibebox-base:latest
```

### Use in Dockerfile

```dockerfile
FROM dlouwers/vibebox-base:latest

# Your custom agent setup here
COPY ./agent-config /workspaces/config
```

## Supported Architectures

This image supports multiple architectures:

- `linux/amd64` - x86_64 processors (Intel, AMD)
- `linux/arm64` - ARM64 processors (Apple Silicon M1/M2/M3, Raspberry Pi 4/5)

Docker automatically selects the correct image for your platform.

## Using with Dev Containers

This image is optimized for use with [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers) and [IntelliJ IDEA](https://www.jetbrains.com/help/idea/connect-to-devcontainer.html).

### VS Code Setup

Create a `.devcontainer/devcontainer.json` file in your project:

```json
{
  "name": "Vibe Coding Environment",
  "image": "dlouwers/vibebox-base:latest",
  "workspaceFolder": "/workspaces/${localWorkspaceFolderBasename}",
  "workspaceMount": "source=${localWorkspaceFolder},target=/workspaces/${localWorkspaceFolderBasename},type=bind",
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-vscode.vscode-typescript-next",
        "dbaeumer.vscode-eslint",
        "esbenp.prettier-vscode"
      ],
      "settings": {
        "terminal.integrated.defaultProfile.linux": "bash"
      }
    }
  },
  "remoteUser": "vscode",
  "features": {
    "ghcr.io/devcontainers/features/git:1": {}
  }
}
```

**To use:**
1. Install [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
2. Open your project in VS Code
3. Press `F1` → "Dev Containers: Reopen in Container"
4. VS Code will build and connect to the container automatically

### IntelliJ IDEA Setup

IntelliJ IDEA supports Dev Containers via Docker integration.

**Prerequisites:**
- IntelliJ IDEA 2023.3+ (Ultimate or Community Edition)
- Docker Desktop running

**Setup Steps:**

1. **Create `.devcontainer/devcontainer.json`** in your project root:

```json
{
  "name": "Vibe Coding Environment",
  "image": "dlouwers/vibebox-base:latest",
  "workspaceFolder": "/workspaces/${localWorkspaceFolderBasename}",
  "workspaceMount": "source=${localWorkspaceFolder},target=/workspaces/${localWorkspaceFolderBasename},type=bind"
}
```

2. **Open Project in IntelliJ:**
   - File → Open → Select your project directory
   - IntelliJ will detect the `.devcontainer` configuration

3. **Connect to Dev Container:**
   - Click the notification: "Dev Container configuration detected"
   - Or: Tools → Dev Containers → Create Dev Container and Mount Sources
   - IntelliJ will build/start the container and configure remote development

4. **Verify Connection:**
   - Terminal should show container shell
   - Run `which opencode-ai` to verify tools are available

**Note:** IntelliJ Ultimate has better Dev Container support than Community Edition. For Community Edition, consider using Docker Compose instead.

### Using with Docker Compose

For projects requiring multiple services, create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  dev:
    image: dlouwers/vibebox-base:latest
    volumes:
      - .:/workspaces:cached
    working_dir: /workspaces
    command: sleep infinity
    stdin_open: true
    tty: true
```

Then in `.devcontainer/devcontainer.json`:

```json
{
  "name": "Vibe Coding Environment",
  "dockerComposeFile": "../docker-compose.yml",
  "service": "dev",
  "workspaceFolder": "/workspaces"
}
```

## Security Configuration

The image includes `vibebox.toml` with strict isolation:

- **Allowed Workspace**: `/workspaces` (read-write)
- **Blocked Paths**: SSH keys, shell history, credentials, Docker socket

See [`vibebox.toml`](./vibebox.toml) for full configuration.

## Development

### Build Locally

```bash
docker build -t vibebox-base:local .
```

### Test Container

```bash
docker run -it --rm vibebox-base:local
```

## CI/CD Pipeline

Automated via GitHub Actions:

- **On Push to `main`**: Builds and publishes `latest` tag
- **On Release Tag (`v*`)**: Publishes versioned tags
- **On Pull Request**: Builds without publishing (validation)

## Versioning

- `latest`: Latest stable build from `main`
- `v1.0.0`: Semantic versioning for releases
- `v1.0`: Major.minor tags
- `v1`: Major version tags

## Maintenance

- **Dependabot**: Weekly checks for base image and GitHub Actions updates
- **Manual Review**: PRs reviewed before merging

## License

MIT License - See [LICENSE](LICENSE) for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

For issues or questions, open a [GitHub Issue](https://github.com/dlouwers/vibebox-base/issues).
