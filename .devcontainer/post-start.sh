#!/bin/bash
set -e 

echo "==> Configuring OpenKanban..."
if [ ! -f ~/.config/openkanban/config.json ]; then
    echo '{"agent": {"command": "opencode", "args": ["-y", "ulw"]}}' > ~/.config/openkanban/config.json
fi

echo "==> Configuring OhMyOpenCode..."
if [ -f ~/.config/opencode/opencode.json ] && ! grep -q 'oh-my-opencode' ~/.config/opencode/opencode.json; then
    oh-my-opencode install --no-tui --claude=no --openai=no --gemini=no --copilot=yes
fi

# Configuration
export OPENCODE_PORT=4096
MAX_ATTEMPTS=40
ATTEMPT=0

echo "==> Starting OpenCode engine in background..."
opencode serve --port $OPENCODE_PORT > /dev/null 2>&1 &

# Deterministic Wait with Fail-Safe
echo "==> Waiting for engine to stabilize (Port $OPENCODE_PORT)..."
until curl -s http://localhost:$OPENCODE_PORT > /dev/null || [ $ATTEMPT -eq $MAX_ATTEMPTS ]; do
  sleep 0.5
  ATTEMPT=$((ATTEMPT + 1))
done

if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
  echo "Error: OpenCode engine failed to start within 20s."
  exit 1
fi

echo "==> Engine ready after $((ATTEMPT / 2)) seconds."

echo "==> Setup Complete!"