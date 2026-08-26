#!/usr/bin/env python3
"""Run a MATLAB command against the persistent shared session started by
start_session.sh. Mirrors `matlab -batch "cmd"`: prints stdout/stderr live and
exits non-zero on a MATLAB error - but reuses the already-warm session instead
of paying startup cost again.
"""
import io
import os
import sys
import time

import matlab.engine

# must match what start_session.sh was given, see there
SESSION_NAME = os.environ.get("SESSION_NAME", "mtexcc")
POLL_INTERVAL = 0.1


def _flush(buf: io.StringIO, printed: int, stream) -> int:
    value = buf.getvalue()
    if len(value) > printed:
        stream.write(value[printed:])
        stream.flush()
    return len(value)


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: matlab_run.py \"<matlab command>\"", file=sys.stderr)
        return 2

    try:
        eng = matlab.engine.connect_matlab(SESSION_NAME)
    except matlab.engine.EngineError as e:
        print(f"Could not connect to session '{SESSION_NAME}': {e}", file=sys.stderr)
        print("Run start_session.sh first.", file=sys.stderr)
        return 1

    # Fresh workspace per call - the shared session otherwise keeps variables
    # from the previous call around, unlike a new `-batch` process.
    eng.eval("clear variables; close all;", nargout=0)

    out, err = io.StringIO(), io.StringIO()
    # The Engine API requires io.StringIO for stdout/stderr (not a real file
    # stream); run in the background and poll the buffers to still get
    # roughly live output instead of only seeing it after completion.
    future = eng.eval(sys.argv[1], nargout=0, stdout=out, stderr=err, background=True)
    printed_out = printed_err = 0
    while not future.done():
        printed_out = _flush(out, printed_out, sys.stdout)
        printed_err = _flush(err, printed_err, sys.stderr)
        time.sleep(POLL_INTERVAL)

    status = 0
    error_message = None
    try:
        future.result()
    except matlab.engine.MatlabExecutionError as e:
        status = 1
        error_message = str(e)
    finally:
        _flush(out, printed_out, sys.stdout)
        _flush(err, printed_err, sys.stderr)
    if error_message:
        print(error_message, file=sys.stderr)
    return status


if __name__ == "__main__":
    sys.exit(main())
