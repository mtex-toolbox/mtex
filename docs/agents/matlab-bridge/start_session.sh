#!/usr/bin/env bash
# Starts (or reuses) a persistent, headless MATLAB session with MTEX on the path,
# shared under the name below so matlab_run.py can connect to it via the Engine API.
# This process is dedicated to this tooling only - it never touches the user's own
# interactive MATLAB desktop session.
set -uo pipefail

BRIDGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$BRIDGE_DIR/../../.." && pwd)"
MATLAB_BIN="/opt/matlab-2024b/bin/matlab"
SESSION_NAME="mtexcc"
PID_FILE="$BRIDGE_DIR/session.pid"
LOG_FILE="$BRIDGE_DIR/session.log"
READY_MARKER="MTEX_BRIDGE_READY"

if [[ -f "$PID_FILE" ]]; then
    old_pid="$(cat "$PID_FILE")"
    if kill -0 "$old_pid" 2>/dev/null; then
        echo "Session already running (pid $old_pid)."
        exit 0
    fi
    echo "Stale pid file, removing."
    rm -f "$PID_FILE"
fi

: > "$LOG_FILE"
(
    cd "$REPO_ROOT"
    # MATLAB's -nodesktop mode reads an interactive command line from stdin; without
    # this it hits EOF immediately (stdin is closed in a backgrounded job) and quits
    # right after startup instead of staying resident.
    exec "$MATLAB_BIN" -nodesktop -nosplash \
        -r "matlab.engine.shareEngine('$SESSION_NAME'); disp('$READY_MARKER')" \
        < <(exec sleep infinity)
) >> "$LOG_FILE" 2>&1 &
new_pid=$!
echo "$new_pid" > "$PID_FILE"

echo "Starting MATLAB session (pid $new_pid), waiting for readiness..."
for _ in $(seq 1 120); do
    if grep -q "$READY_MARKER" "$LOG_FILE" 2>/dev/null; then
        echo "Session ready (session name: $SESSION_NAME)."
        exit 0
    fi
    if ! kill -0 "$new_pid" 2>/dev/null; then
        echo "MATLAB process exited before becoming ready. Log:"
        cat "$LOG_FILE"
        rm -f "$PID_FILE"
        exit 1
    fi
    sleep 1
done

echo "Timed out waiting for readiness. Log:"
cat "$LOG_FILE"
exit 1
