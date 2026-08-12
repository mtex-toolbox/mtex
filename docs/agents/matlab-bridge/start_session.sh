#!/usr/bin/env bash
# Starts (or reuses) a persistent, headless MATLAB session with MTEX on the path,
# shared under the name below so matlab_run.py can connect to it via the Engine API.
# This process is dedicated to this tooling only - it never touches the user's own
# interactive MATLAB desktop session.
set -uo pipefail

BRIDGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$BRIDGE_DIR/../../.." && pwd)"
# Override for your own install: MATLAB_ROOT=/opt/matlab-R20XXx ./start_session.sh
MATLAB_ROOT="${MATLAB_ROOT:-/opt/matlab-2024b}"
MATLAB_BIN="$MATLAB_ROOT/bin/matlab"
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

# A shared engine name is a unix socket under $TMPDIR that MATLAB does not clean
# up when it exits. A leftover one makes shareEngine error and fall back to a
# default name, which matlab_run.py then cannot find - so drop it up front. Safe
# because we already established above that our own session is not running.
SOCKET="${TMPDIR:-/tmp}/$SESSION_NAME"
if [[ -S "$SOCKET" ]]; then
    echo "Removing stale session socket $SOCKET."
    rm -f "$SOCKET"
fi

(
    cd "$REPO_ROOT"
    # MATLAB's -nodesktop mode reads an interactive command line from stdin; without
    # this it hits EOF immediately (stdin is closed in a backgrounded job) and quits
    # right after startup instead of staying resident.
    # -nodesktop only drops the IDE, it keeps the display. Without -nodisplay
    # every figure a driven script creates is rendered onto the user's screen,
    # and a script that plots in a loop buries their desktop in windows.
    # -noFigureWindows does not have that effect here - it leaves
    # feature('ShowFigureWindows') at 1 - so -nodisplay is the one that counts.
    # Figures are still created, so saveas/print/export_fig keep working; the
    # DefaultFigureVisible default is belt and braces for the same thing.
    exec "$MATLAB_BIN" -nodesktop -nosplash -nodisplay \
        -r "set(0,'DefaultFigureVisible','off'); matlab.engine.shareEngine('$SESSION_NAME'); disp('$READY_MARKER')" \
        < <(exec sleep infinity)
) >> "$LOG_FILE" 2>&1 &
new_pid=$!
echo "$new_pid" > "$PID_FILE"

echo "Starting MATLAB session (pid $new_pid), waiting for readiness..."
for _ in $(seq 1 120); do
    # shareEngine failing is not fatal to MATLAB - it keeps running under a
    # default name and would still print the ready marker, so check this first
    if grep -q "already exists" "$LOG_FILE" 2>/dev/null; then
        echo "Session name '$SESSION_NAME' is taken by another MATLAB; not reachable. Log:"
        cat "$LOG_FILE"
        kill "$new_pid" 2>/dev/null
        rm -f "$PID_FILE"
        exit 1
    fi
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
