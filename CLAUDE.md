# MTEX

Open-source MATLAB toolbox for crystallographic texture analysis — EBSD, pole figures, ODF
reconstruction, grain boundaries. No GUI; everything is a function/class API.

## Running MATLAB

Run **from the repo root**, so `startup.m` picks up `startup_mtex` and the path:

```
matlab -batch "your_command_here"
```

Startup costs ~10-20 s, much more when another MATLAB is competing for the machine.

> **Which MATLAB to invoke is developer-local.** Install paths, activated releases,
> container setups and timings differ per machine, so they belong in an untracked
> `CLAUDE.local.md` at the repo root, not here. Point `MATLAB_ROOT` at your install rather
> than hardcoding a path.

MTEX needs the **Statistics and Machine Learning Toolbox** — `knnsearch` is called from the
EBSD/grain code. Without it six core tests fail (`check_calcGrainsCases`, `check_ebsd`,
`check_ebsdImport`, `check_find`, `check_gradient`, `check_jcvoronoi`), which looks exactly
like six regressions. Check `ver('stats')` before believing them.

### Persistent session — the default way to run MATLAB here

`docs/agents/matlab-bridge/` keeps one headless session warm across many calls, paying
startup once:

```
docs/agents/matlab-bridge/setup.sh          # once: Python 3.12 venv + MATLAB Engine API
docs/agents/matlab-bridge/start_session.sh
docs/agents/matlab-bridge/.venv/bin/python docs/agents/matlab-bridge/matlab_run.py "cmd"
docs/agents/matlab-bridge/stop_session.sh
```

`matlab_run.py` mirrors `-batch` semantics — nonzero exit on error, live stdout — and clears
the base workspace per call while keeping the path warm. Compute time is identical to
`-batch`; the difference is startup and that the R2024b teardown hang below cannot strand a
run. It never touches the developer's own interactive session.

Caveats: a **new** `.m` file or folder needs a session restart (the path is fixed at
startup; edits to existing files are picked up immediately), a `classdef` edit needs one
too, and the session holds a license checkout — stop it when not iterating.

### Known MATLAB release defects

**R2024b teardown hang.** After a large `calcGrains`/`jcvoronoi2` workload or a full
`runTests`, MATLAB prints `free(): chunks in smallbin corrupted` at exit and hangs in
teardown with every result already computed — so a `-batch` run looks like slow computation
rather than a finished one. R2024a and R2026a are clean; see issue #2589. Guard `-batch`
jobs with `timeout`, read a hang *after* the last line of output as this, and prefer the
bridge, where it does not occur.

**MEX and libstdc++.** The committed `mex/*.mexa64` are built against a newer libstdc++ than
some releases bundle and fail with `GLIBCXX_3.4.32 not found`, typically in a container.
Rebuilding is the fix, but `mex_install` compiles **in place** and would overwrite the
checked-in binaries — build out-of-tree and `addpath(...,'-begin')` instead.

## Code layout

Class-per-folder: `@ClassName/` holds a class's methods as separate `.m` files, e.g.
`geometry/@vector3d/angle.m`. Each folder below has its own `CLAUDE.md` with the detail.

- `geometry/` — vectors, orientations, Miller indices, symmetries, reference frames
- `EBSDAnalysis/` — EBSD data, grains, grain boundaries, reconstruction
- `PoleFigureAnalysis/` — pole figure data and ODF-from-pole-figure solvers
- `SO3Fun/`, `S2Fun/`, `S1Fun/` — function spaces on SO(3), the sphere, the circle
- `TensorAnalysis/` — elastic/plastic tensor calculations
- `plotting/` — all figure and plot code
- `interfaces/` — file format import/export
- `doc/` — published example scripts, and the source of the online documentation
- `extern/` — vendored third-party code (jsonlab, NFFT, jcvoronoi, …)
- `mex/` — compiled MEX binaries, checked in, not rebuilt by default
- `obsolete/`, `old/`, `compatibility/` — deprecated wrappers that warn and forward. Never a
  reference for current patterns.

**Line endings are LF**, enforced by `.gitattributes` (`*.m text eol=lf`). `extern/**` and
`data/**` are marked `-text` and keep their bytes, because importers parse fixtures byte by
byte and some carry deliberately odd endings — never "fix" a line ending under `data/`.

## Comments

**One line, saying what the next lines do.** Match the surrounding style: lowercase, terse,
no full stop, above the statement or trailing on it. If the code is self-explanatory, write
no comment.

Do **not** write the multi-line justification blocks an agent tends to produce: what the
previous implementation did, which MTEX version changed it, which commit or dataset a number
was measured on, what would go wrong if the line were removed, how many grains some map
gained. None of that helps the next reader, and it ages badly — the repository was swept
once to remove ~2800 such lines. A single line is the budget; two or three only for a
genuinely non-obvious invariant or a formula. Where the reasoning is worth keeping it belongs
in the commit message, an issue, or an ADR under `docs/adr/` — not in the source.

## Architecture

**Everything is vectorized.** One object instance holds an array of many entities — a
`vector3d` is a point cloud, an `EBSD` a whole scan, a `grain2d` every grain in a map — with
its properties as arrays in lockstep. Methods operate elementwise across the array via
operator overloading and broadcasting. Assume `this` represents N objects and check how
`this(idx)` is implemented before writing a loop.

- **Geometry** (`geometry/`): `quaternion` → `rotation` → `orientation`, and `vector3d` →
  `Miller`. `symmetry` is threaded through both. A `@referenceFrame` carries the axes and
  the plotting convention, and is the **only** thing that carries a convention.
- **EBSD → grains** (`EBSDAnalysis/`): `calcGrains` segments an `EBSD` into a `grain2d`
  (`grain3d` for volume data), whose segments are a separate `grainBoundary`.
  `parentGrainReconstructor` recovers parent-phase grains from child-phase data.
- **Function spaces** (`SO3Fun/`, `S2Fun/`, `S1Fun/`): ODFs and spherical data are function
  objects behind one abstract interface, so harmonic, RBF, triangulated and homochoric
  representations are interchangeable. `SO3VectorField`/`S2VectorField` mirror this for
  vector-valued fields.
- **Plotting** (`plotting/`): everything goes through `mtexFigure`, which owns multi-axis
  layout, colorbars and annotations.

Decisions with lasting consequences are recorded in `docs/adr/`, and the source cites them
by number. ADR 0003 (reference frame vs symmetry) is the one most code refers to.

## Tests

`tests/` holds standalone `check_*.m` functions, not a `matlab.unittest` suite, sorted into
tiers. `runTests` runs a tier, each test in its own try/catch, and raises at the end so
`-batch` exits nonzero.

```
matlab -batch "runTests"            # core, the fast tier
matlab -batch "runTests('slow')"
```

> **Never start a test run without asking first, and never start any run that could take
> longer than 5 minutes.** That means `runTests` in any tier, `check_mtex`, and any individual
> `check_*.m` — a tier is minutes of the machine, and the developer may already have a session
> doing something they care about. Say what you want to run and why, and wait. Targeted
> commands of your own through the bridge are fine, under the same limit: give every command a
> timeout that enforces it, and when a check does not fit, find the way to get the same answer
> inside it — a handful of cases rather than the whole set — instead of raising the timeout.

**Read `tests/CLAUDE.md` before adding a test.** It has the tier budgets, which file owns
which subsystem, and when a bug earns a new file at all.

## Agent skills

- **Issues** live in GitHub Issues on `mtex-toolbox/mtex`, via `gh`. See
  `docs/agents/issue-tracker.md`.
- **Triage labels**: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`,
  `wontfix`. See `docs/agents/triage-labels.md`.
- **Domain docs**: `CONTEXT.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.
