#!/usr/bin/env bash
# One-time provisioning of a Python 3.12 venv with the MATLAB Engine API installed.
# MATLAB R2024b's Engine API only supports Python 3.9-3.12; the system Python is newer,
# so we fetch an isolated 3.12 via uv rather than touching system packages.
set -euo pipefail

BRIDGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MATLAB_ROOT="/opt/matlab-2024b"
VENV_DIR="$BRIDGE_DIR/.venv"

if ! command -v uv >/dev/null 2>&1; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

uv python install 3.12
uv venv "$VENV_DIR" --python 3.12
uv pip install --python "$VENV_DIR/bin/python" "$MATLAB_ROOT/extern/engines/python"

echo "Verifying install..."
"$VENV_DIR/bin/python" -c "import matlab.engine; print('matlab.engine OK, python', __import__('sys').version)"

echo "Setup complete. Next: ./start_session.sh"
