#!/usr/bin/env bash
# Stops the dedicated headless MATLAB session started by start_session.sh.
# Only ever acts on the recorded pid - never touches the user's own interactive
# MATLAB desktop session.
set -uo pipefail

BRIDGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$BRIDGE_DIR/session.pid"
SESSION_NAME="mtexcc"

if [[ ! -f "$PID_FILE" ]]; then
    echo "No session.pid found; nothing to stop."
else
    pid="$(cat "$PID_FILE")"
    if kill -0 "$pid" 2>/dev/null; then
        kill "$pid"
        # wait for it to actually go away before reclaiming the socket below
        for _ in $(seq 1 20); do
            kill -0 "$pid" 2>/dev/null || break
            sleep 0.5
        done
        echo "Stopped session (pid $pid)."
    else
        echo "Process $pid not running."
    fi
    rm -f "$PID_FILE"
fi

# shareEngine registers the name as a unix socket in $TMPDIR. MATLAB does not
# remove it on exit, so the next start_session.sh fails with "MATLAB session
# 'mtexcc' already exists" and silently falls back to a default name that
# matlab_run.py cannot connect to.
rm -f "${TMPDIR:-/tmp}/$SESSION_NAME"
