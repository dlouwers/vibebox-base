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
