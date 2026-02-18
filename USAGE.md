# Using VibeBox Base

**Objective:** Build secure, isolated AI coding agents using the VibeBox Base Docker image.

**Who This Is For:** Developers creating AI agents that need sandboxed execution environments with pre-configured tooling.

---

## Quick Start

### 1. Pull the Base Image

```bash
docker pull dlouwers/vibebox-base:latest
```

### 2. Create Your Agent Configuration

Create a `.devcontainer/devcontainer.json` in your project:

```json
{
  "name": "My Vibe Coding Agent",
  "image": "dlouwers/vibebox-base:latest",
  "workspaceFolder": "/workspaces/${localWorkspaceFolderBasename}",
  "workspaceMount": "source=${localWorkspaceFolder},target=/workspaces/${localWorkspaceFolderBasename},type=bind",
  "remoteUser": "vscode"
}
```

### 3. Add Agent System Prompt

Copy the agent instructions from [AGENT.md](https://github.com/dlouwers/vibebox-base/blob/main/AGENT.md) and use them as your AI agent's system prompt. This configures the agent to:
- Understand the containerized environment
- Respect security boundaries
- Use pre-installed tools correctly
- Work within `/workspaces` only

### 4. Launch Your Agent

**VS Code:**
1. Install [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
2. Open your project
3. Press `F1` → "Dev Containers: Reopen in Container"

**IntelliJ IDEA:**
1. Open your project
2. Tools → Dev Containers → Create Dev Container and Mount Sources

**Docker CLI:**
```bash
docker run -it --rm -v $(pwd):/workspaces dlouwers/vibebox-base:latest
```

---

## What's Included

### Pre-installed Tools
- **Node.js & npm** - JavaScript/TypeScript runtime and package manager
- **opencode-ai** - AI coding assistant CLI (v1.2.6)
- **vibebox** - Sandbox security tooling
- **git** - Version control
- **build-essential** - C/C++ compiler toolchain (gcc, g++, make)

### Security Configuration
- **Allowed**: `/workspaces` (full read-write access)
- **Blocked**: SSH keys, credentials, shell history, Docker socket, system files
- **Config Location**: `/etc/vibebox.toml` in container

### Architecture Support
- **AMD64** (x86_64) - Intel/AMD processors
- **ARM64** - Apple Silicon (M1/M2/M3), Raspberry Pi 4/5

---

## Usage Patterns

### Pattern 1: Single-File Agent Script

Create a standalone agent that works in any project:

```bash
#!/bin/bash
docker run -it --rm \
  -v $(pwd):/workspaces \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  dlouwers/vibebox-base:latest \
  bash -c "opencode --task='$1'"
```

Usage:
```bash
./agent.sh "Add error handling to all functions"
```

### Pattern 2: Dev Container Agent

Persistent development environment with your agent:

```json
{
  "name": "Project Agent",
  "image": "dlouwers/vibebox-base:latest",
  "workspaceFolder": "/workspaces/${localWorkspaceFolderBasename}",
  "customizations": {
    "vscode": {
      "extensions": ["ms-vscode.vscode-typescript-next"],
      "settings": {
        "agent.systemPrompt": "file:///.devcontainer/AGENT.md"
      }
    }
  }
}
```

### Pattern 3: Custom Agent Image

Extend the base for specialized agents:

```dockerfile
FROM dlouwers/vibebox-base:latest

RUN npm install -g typescript @types/node

COPY agent-config.json /etc/agent-config.json

ENV AGENT_MODE=code-review
ENV AGENT_STRICTNESS=high

WORKDIR /workspaces
CMD ["bash", "-c", "opencode agent start"]
```

Build and use:
```bash
docker build -t my-custom-agent .
docker run -it --rm -v $(pwd):/workspaces my-custom-agent
```

---

## Integration Examples

### With OpenCode AI

```bash
docker run -it --rm \
  -v $(pwd):/workspaces \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  dlouwers/vibebox-base:latest \
  bash -c "cd /workspaces && opencode --interactive"
```

### With LangChain Agents

```python
from langchain.agents import Tool, initialize_agent
from langchain.llms import OpenAI
import subprocess

def run_in_vibebox(command: str) -> str:
    result = subprocess.run([
        'docker', 'run', '--rm',
        '-v', f'{os.getcwd()}:/workspaces',
        'dlouwers/vibebox-base:latest',
        'bash', '-c', f'cd /workspaces && {command}'
    ], capture_output=True, text=True)
    return result.stdout

vibebox_tool = Tool(
    name="VibeBoxExecutor",
    func=run_in_vibebox,
    description="Execute code in secure sandbox"
)

agent = initialize_agent(
    tools=[vibebox_tool],
    llm=OpenAI(temperature=0),
    agent="zero-shot-react-description"
)
```

### With AutoGPT

Add to `autogpt/plugins/vibebox_plugin.py`:

```python
class VibeBoxPlugin:
    def execute_code(self, code: str) -> str:
        with tempfile.NamedTemporaryFile(mode='w', suffix='.js') as f:
            f.write(code)
            f.flush()
            result = subprocess.run([
                'docker', 'run', '--rm',
                '-v', f'{f.name}:/workspaces/script.js',
                'dlouwers/vibebox-base:latest',
                'node', '/workspaces/script.js'
            ], capture_output=True, text=True)
        return result.stdout
```

---

## Agent System Prompt Template

Use this template when configuring your AI agent:

```markdown
# System Prompt

You are a coding agent running in VibeBox Base (dlouwers/vibebox-base:latest).

## Environment
- **OS**: Debian Bookworm
- **Workspace**: /workspaces (read-write)
- **Tools**: Node.js, npm, git, gcc, opencode-ai, vibebox

## Security Rules
✅ ALLOWED: /workspaces (all operations)
❌ BLOCKED: /root/.ssh, /etc/shadow, /etc/passwd, Docker socket

## Operating Instructions
1. All file operations in /workspaces only
2. Install dependencies locally (npm install, not npm install -g)
3. Use git for version control
4. Run tests before committing (npm test)
5. Never attempt to access blocked paths

## Error Handling
- Try fix 3 times maximum
- If stuck, report what was attempted
- Never use sudo or attempt privilege escalation

See full instructions: https://github.com/dlouwers/vibebox-base/blob/main/AGENT.md
```

---

## Security Best Practices

### 1. Never Mount Sensitive Directories
```bash
# ❌ BAD: Exposes host SSH keys
docker run -v ~/.ssh:/workspaces/.ssh dlouwers/vibebox-base

# ✅ GOOD: Only mount project directory
docker run -v $(pwd):/workspaces dlouwers/vibebox-base
```

### 2. Use Read-Only Mounts for Reference Data
```bash
docker run \
  -v $(pwd):/workspaces \
  -v /path/to/docs:/docs:ro \
  dlouwers/vibebox-base
```

### 3. Limit Network Access
```bash
docker run --network none \
  -v $(pwd):/workspaces \
  dlouwers/vibebox-base
```

### 4. Set Resource Limits
```bash
docker run \
  --memory=2g \
  --cpus=1.5 \
  -v $(pwd):/workspaces \
  dlouwers/vibebox-base
```

---

## Troubleshooting

### Issue: "Permission Denied" in Container
**Cause**: File ownership mismatch between host and container
**Solution**: 
```bash
docker run -u $(id -u):$(id -g) \
  -v $(pwd):/workspaces \
  dlouwers/vibebox-base
```

### Issue: "opencode-ai: command not found"
**Cause**: Using old cached image
**Solution**:
```bash
docker pull dlouwers/vibebox-base:latest
docker image prune -f
```

### Issue: "vibebox.toml not found"
**Cause**: Using image built before Feb 18, 2026
**Solution**:
```bash
docker pull dlouwers/vibebox-base:latest
```

### Issue: Changes Not Persisting
**Cause**: Working outside `/workspaces`
**Solution**: Always work in `/workspaces` which is mounted from host

### Issue: Slow Build on Apple Silicon
**Cause**: Multi-arch images require emulation for some layers
**Solution**: This is normal. First pull takes 2-3 minutes, then cached.

---

## CI/CD Integration

### GitHub Actions

```yaml
name: Agent Code Review

on: [pull_request]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run VibeBox Agent Review
        run: |
          docker run --rm \
            -v ${{ github.workspace }}:/workspaces \
            -e OPENAI_API_KEY=${{ secrets.OPENAI_API_KEY }} \
            dlouwers/vibebox-base:latest \
            bash -c "cd /workspaces && opencode review --pr=${{ github.event.pull_request.number }}"
```

### GitLab CI

```yaml
agent_review:
  image: dlouwers/vibebox-base:latest
  script:
    - cd /workspaces
    - opencode review --diff="$CI_MERGE_REQUEST_DIFF_BASE_SHA..$CI_COMMIT_SHA"
  only:
    - merge_requests
```

---

## Updating the Base Image

The image auto-updates via Dependabot weekly. To trigger manual rebuild:

1. Go to [GitHub Actions](https://github.com/dlouwers/vibebox-base/actions)
2. Select "Publish Docker Image" workflow
3. Click "Run workflow" → "Run workflow"

New tags are created on release:
- `latest` - Always newest stable
- `v1.0.0` - Semantic version tags
- `main` - Latest commit from main branch

---

## Resources

- **Base Image**: https://hub.docker.com/r/dlouwers/vibebox-base
- **Source Code**: https://github.com/dlouwers/vibebox-base
- **Agent System Prompt**: [AGENT.md](https://github.com/dlouwers/vibebox-base/blob/main/AGENT.md)
- **Security Config**: [vibebox.toml](https://github.com/dlouwers/vibebox-base/blob/main/vibebox.toml)
- **License**: [MIT](https://github.com/dlouwers/vibebox-base/blob/main/LICENSE)

---

## Support

- **Documentation Issues**: Open GitHub issue
- **Security Concerns**: Email security issues to the repository owner
- **General Questions**: Use GitHub Discussions

**Community**: https://github.com/dlouwers/vibebox-base/discussions
