#!/usr/bin/env bash
# Stops the dedicated headless MATLAB session started by start_session.sh.
# Only ever acts on the recorded pid - never touches the user's own interactive
# MATLAB desktop session.
set -uo pipefail

BRIDGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$BRIDGE_DIR/session.pid"

if [[ ! -f "$PID_FILE" ]]; then
    echo "No session.pid found; nothing to stop."
    exit 0
fi

pid="$(cat "$PID_FILE")"
if kill -0 "$pid" 2>/dev/null; then
    kill "$pid"
    echo "Stopped session (pid $pid)."
else
    echo "Process $pid not running."
fi
rm -f "$PID_FILE"
