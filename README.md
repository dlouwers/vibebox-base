# VibeBox DevContainer

[![Docker Image](https://img.shields.io/docker/v/dlouwers/vibebox-base?label=Docker%20Hub)](https://hub.docker.com/r/dlouwers/vibebox-base)
[![Build Status](https://github.com/dlouwers/vibebox-base/actions/workflows/publish.yml/badge.svg)](https://github.com/dlouwers/vibebox-base/actions)

> ⚠️ **INTERNAL USE ONLY (v0.x)** - This project is in active development and currently used internally. Public usage instructions are not yet available. The devcontainer template and published Docker image are under heavy iteration.

A devcontainer environment that brings AI-powered coding assistance to any project through OpenCode AI agents, OpenKanban task management, and an isolated development environment.

## What Is This?

This project provides a **devcontainer template** that transforms any codebase into a Vibe coding environment with:

- **OpenCode AI** - Autonomous AI coding agents with Claude, GPT, Gemini support
- **OpenKanban** - Terminal-based kanban board for managing development tasks
- **oh-my-opencode** - Plugin system for multi-agent orchestration
- **VS Code & IntelliJ Support** - Full IDE integration
- **Isolated Workspaces** - Secure sandboxed execution with git worktree support

## Status

**Current Phase:** Internal development and testing. We are dogfooding this devcontainer to build itself.

**What's Ready:**
- Docker image build and publishing pipeline
- Core devcontainer configuration
- OpenCode AI + OpenKanban integration
- VS Code auto-launch tasks

**What's Pending:**
- Public usage documentation
- Template distribution method (manual copy or CLI tool)
- Stability and compatibility testing across different projects
- Production-ready versioning

## What Gets Installed

The devcontainer uses the published `dlouwers/vibebox-base:latest` Docker image, which includes:

- **OpenCode AI** - Installed per-user in `/home/node/.opencode/bin/`
- **OpenKanban** - Binary at `/usr/local/bin/openkanban`
- **oh-my-opencode** - Global npm package for plugin management
- **Node.js 20** - JavaScript runtime (Microsoft devcontainer base)
- **Git** - Pre-configured with worktree support

## How It Works

### File System Layout

```
your-project/
├── .devcontainer/
│   ├── devcontainer.json       # Container configuration
│   ├── initialize-host.sh      # Runs on host before container starts
│   └── post-start.sh           # Runs inside container after startup
├── (your project files)
└── .kanban-worktrees/          # Created automatically on host
    └── (git worktrees for tasks)
```

### Host Mounts

The devcontainer mounts these directories from your host machine:

| Host Path | Container Path | Purpose |
|-----------|----------------|---------|
| `~/.config/openkanban` | `/home/node/.config/openkanban` | OpenKanban config |
| `~/.config/opencode` | `/home/node/.config/opencode` | OpenCode AI config |
| `~/.local/share/opencode` | `/home/node/.local/share/opencode` | OpenCode data |
| `~/.local/state/opencode` | `/home/node/.local/state/opencode` | OpenCode state |
| `~/.kanban-worktrees` | `/worktrees` | Git worktrees for isolated tasks |

These directories are automatically created by `initialize-host.sh` before the container starts.

### Startup Sequence

1. **initializeCommand** (`initialize-host.sh`) - Runs on your host machine:
   - Creates required directories in your home folder
   - Sets permissions for Docker volume mounts

2. **Container Start** - Docker launches the container with mounted volumes

3. **postStartCommand** (`post-start.sh`) - Runs inside container:
   - Configures OpenKanban to use `/worktrees` for git worktrees
   - Installs oh-my-opencode plugins (if not already configured)
   - Starts OpenCode engine on port 4096
   - Sets up git worktree symlinks for OpenKanban compatibility
   - Launches OpenKanban dashboard automatically (VS Code only)

## Using OpenKanban

OpenKanban is a terminal-based task management tool that creates isolated git worktrees for each task.

### Automatic Launch (VS Code)

OpenKanban automatically starts in a terminal when you open the devcontainer (configured in `.vscode/tasks.json`).

### Manual Launch

```bash
openkanban
```

### Configuration

OpenKanban config is stored at `~/.config/openkanban/config.json`:

```json
{
  "agent": {
    "command": "opencode",
    "args": ["-y", "ulw"]
  },
  "defaults": {
    "worktree_base": "/worktrees"
  }
}
```

**Note:** The `worktree_base` setting is currently not fully functional in OpenKanban. The devcontainer works around this by creating a symlink from the expected location to `/worktrees`.

## Using OpenCode AI

### Direct CLI Usage

```bash
# Interactive chat
opencode

# Run with auto-approval
opencode -y

# Use specific mode
opencode -y ulw
```

### Check OpenCode Status

```bash
# Verify installation
which opencode

# Check running engine
curl http://localhost:4096
```

### Configuration

OpenCode config is stored at `~/.config/opencode/opencode.json`. You can configure:
- API keys for Claude, GPT, Gemini
- GitHub Copilot integration
- Custom plugins via oh-my-opencode

## Customization

### Modify VS Code Extensions

Edit `.devcontainer/devcontainer.json`:

```json
{
  "customizations": {
    "vscode": {
      "extensions": [
        "dbaeumer.vscode-eslint",
        "your-extension-id-here"
      ]
    }
  }
}
```

### Change OpenCode Port

Edit `.devcontainer/post-start.sh`:

```bash
export OPENCODE_PORT=4096  # Change to your preferred port
```

And update `.vscode/tasks.json` if you want OpenKanban to use a different port:

```json
{
  "options": {
    "env": {
      "OPENCODE_PORT": "4096"
    }
  }
}
```

### Add Custom Initialization

Edit `.devcontainer/post-start.sh` to add your own setup commands:

```bash
# Example: Install project dependencies
if [ -f package.json ]; then
    npm install
fi
```

## IntelliJ IDEA Support

IntelliJ IDEA 2023.3+ supports Dev Containers. After copying `.devcontainer/` into your project:

1. **Open your project in IntelliJ**
2. **Notification appears**: "Dev Container configuration detected"
3. **Click**: "Create Dev Container and Mount Sources"
4. **Wait for container to build and start**
5. **Terminal access**: IntelliJ terminal connects to container shell
6. **Run OpenKanban**: Type `openkanban` in the terminal

**Note:** IntelliJ does not auto-run the VS Code task that launches OpenKanban. You must start it manually in the terminal.

## Architecture

### Image Publishing

The Docker image is built from the root `Dockerfile` and published to DockerHub as `dlouwers/vibebox-base:latest` (and versioned tags like `v0.1.0`).

**Build Platforms:**
- `linux/amd64` - Intel/AMD processors
- `linux/arm64` - Apple Silicon (M1/M2/M3), ARM-based systems

**CI/CD Pipeline:**
- Push to `main` → publishes `latest` tag
- Push tag `v0.x.y` → publishes versioned tags (`v0.1.0`, `v0.1`, `latest`)
- Pull requests → build-only (no publish)

### Security Configuration

The published Docker image includes `vibebox.toml` for security isolation (future use with `vibebox` CLI):

```toml
[security]
mode = "strict"

[mounts]
allowed = ["/workspaces"]
read_write = ["/workspaces"]

[blocked_paths]
paths = [
    "/root/.ssh",
    "/root/.bash_history",
    "/root/.config",
    "/etc/shadow",
    "/etc/passwd",
    "/etc/sudoers",
    "/etc/ssh",
    "/home/*/.ssh",
    "/var/run/docker.sock"
]
```

**Current Status:** The `vibebox` security enforcement tool is installed but not actively enforced in this devcontainer setup. This is planned for future versions.

### Dogfooding: Building the Devcontainer with Itself

This project uses its own devcontainer for development, creating a chicken-and-egg scenario:

**The Problem:**
- `.devcontainer/devcontainer.json` references `dlouwers/vibebox-base:latest` from DockerHub
- The image doesn't exist until we push to `main` and CI publishes it
- We need the devcontainer to develop the devcontainer

**The Solution:**
- `devcontainer.json` includes both `image` and `build` properties
- If the published image isn't available, VS Code falls back to building locally from `Dockerfile`
- After first publish, the image will be cached and used directly

**During Development:**
- First-time setup builds locally (takes longer)
- After merge to main, CI publishes the image
- Subsequent opens use the published image (faster)

This is intentional dogfooding to ensure the devcontainer works in real-world scenarios.

## Troubleshooting

### Container Won't Start

**Check Docker Desktop is running:**
```bash
docker ps
```

**Check logs:**
```bash
docker logs <container-name>
```

### OpenCode Not Found

**Verify PATH:**
```bash
echo $PATH | grep opencode
```

**Manually source profile:**
```bash
source /etc/profile.d/opencode.sh
which opencode
```

### OpenKanban Can't Create Worktrees

**Check permissions on host:**
```bash
ls -la ~/.kanban-worktrees
```

**Ensure directory exists and is writable:**
```bash
mkdir -p ~/.kanban-worktrees
chmod 755 ~/.kanban-worktrees
```

**Check inside container:**
```bash
ls -la /worktrees
```

### OpenCode Engine Not Responding

**Check if engine is running:**
```bash
curl http://localhost:4096
```

**Check startup logs:**
```bash
cat /tmp/opencode-startup.log
```

**Restart engine manually:**
```bash
pkill -f "opencode serve"
opencode serve --port 4096 &
```

## Development (Building the Docker Image Locally)

If you want to build the Docker image yourself instead of using the published version:

```bash
# Clone this repository
git clone https://github.com/dlouwers/vibebox-base.git
cd vibebox-base

# Build the image
docker build -t vibebox-base:local .

# Test the image
docker run -it --rm vibebox-base:local

# Use local image in devcontainer
# Edit .devcontainer/devcontainer.json:
# Change "image": "dlouwers/vibebox-base:latest"
# To "image": "vibebox-base:local"
```

## Versioning

This project follows semantic versioning with a **0.x.x** pre-release scheme:

- **v0.x.y** - Alpha releases (breaking changes expected)
- **v1.0.0** - First stable release (when ready for production)

**Current Status:** All releases are `v0.x` and considered **unstable**. APIs, configuration formats, and behavior may change without backward compatibility guarantees.

## License

MIT License - See [LICENSE](LICENSE) for details.

## Contributing

Contributions welcome! This project is in active development.

1. Fork the repository
2. Create a feature branch
3. Test your changes with the devcontainer
4. Submit a pull request

For issues or questions, open a [GitHub Issue](https://github.com/dlouwers/vibebox-base/issues).

## Roadmap

- [ ] Automated template generator CLI (`vibebox-init` or similar)
- [ ] Better IntelliJ IDEA integration (auto-launch OpenKanban)
- [ ] Active enforcement of `vibebox.toml` security policies
- [ ] Multi-project workspace support
- [ ] Web UI for OpenKanban (in addition to terminal TUI)
- [ ] Pre-configured language-specific variants (Python, Go, Rust, etc.)
