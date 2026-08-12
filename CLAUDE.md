# MTEX

MTEX is an open-source MATLAB toolbox for crystallographic texture analysis (EBSD, pole figures, ODF reconstruction, grain boundaries, etc.). No GUI; everything is a MATLAB function/class API.

## Running MATLAB

Run MATLAB **from the repo root**, so it auto-executes the `startup.m` in the current directory, which calls `startup_mtex` and adds all MTEX subfolders to the path:

```
matlab -batch "your_command_here"
```

`-batch` runs headlessly (no desktop/menu) and exits after the command finishes. Startup (path setup + MTEX init) typically takes ~10-20s before your command runs, and can spike much higher (minutes) if another MATLAB instance (e.g. an interactive desktop session) is already running and contending for the same CPU, RAM and service-host processes.

> **Which MATLAB to invoke is developer-local.** Install locations, which releases are activated on a given machine, container setups and measured timings differ for everyone, so they do not belong in this file. Put them in an untracked `CLAUDE.local.md` at the repo root (gitignored). If `matlab` on `$PATH` is not the interpreter you want, set `MATLAB_ROOT` (see the bridge scripts below) rather than hardcoding a path here.

MTEX requires the **Statistics and Machine Learning Toolbox**: parts of the EBSD/grain code call `knnsearch`, and on an install without it six core tests fail with `Undefined function 'knnsearch'` (`check_calcGrainsCases`, `check_ebsd`, `check_ebsdImport`, `check_find`, `check_gradient`, `check_jcvoronoi`). A partial install therefore looks like six real regressions — check `ver('stats')` before believing them.

### Known MATLAB release defects

**R2024b — teardown hang.** After a large `calcGrains`/`jcvoronoi2` workload, and after a full `runTests`, MATLAB prints `free(): chunks in smallbin corrupted` at exit and then hangs in teardown with all results already computed, so a `-batch` run looks like a slow computation rather than a finished one. R2024a and R2026a are clean on the same input; see issue #2589. Guard `-batch` jobs with `timeout`, read a hang *after* the last line of output as this rather than as slow code, and prefer the persistent session below, where it does not occur at all.

**MEX and libstdc++.** The committed `mex/*.mexa64` are built against a newer libstdc++ than some MATLAB releases bundle, and fail to load with `GLIBCXX_3.4.32 not found` on those (typically inside a container, where the system GCC runtime does not win). Rebuilding is the fix, but note `mex_install` compiles **in place** and will overwrite the checked-in binaries — build out-of-tree into a scratch directory and `addpath(...,'-begin')` instead.

### Persistent session for iterative work

Spawning a fresh `-batch` process pays the full startup cost every time, which adds up when running several `check_*.m`/test commands back-to-back in one task. `docs/agents/matlab-bridge/` provides a persistent, headless MATLAB session (driven via the Python MATLAB Engine API) that pays startup once and stays warm across many calls:

```
docs/agents/matlab-bridge/setup.sh          # one-time: provisions a Python 3.12 venv + MATLAB Engine API
docs/agents/matlab-bridge/start_session.sh  # starts the shared session, waits for readiness
docs/agents/matlab-bridge/.venv/bin/python docs/agents/matlab-bridge/matlab_run.py "your_command_here"
docs/agents/matlab-bridge/stop_session.sh   # stop when done iterating
```

`matlab_run.py` mirrors `-batch` semantics (nonzero exit on MATLAB error, live stdout/stderr) and clears the base workspace before every call, but keeps the path/MTEX init warm. Caveats: adding *new* `.m` files or folders requires restarting the session (the path is fixed at startup — editing existing files is picked up immediately); the session holds an extra MATLAB license checkout for as long as it's alive, so stop it when not actively iterating. This is separate from and never interferes with the user's own interactive MATLAB desktop session.

Both scripts take the MATLAB install from `MATLAB_ROOT` (falling back to a default), so point that at your own install rather than editing them.

The bridge is the default way to run MATLAB here, not merely a convenience: compute time is identical to `-batch`, but startup is paid once instead of per call, and the R2024b teardown hang above cannot strand a run, because the session never exits. On one measured machine a full `runTests` took the same ~110 s of compute either way, but 300 s of wall time under `-batch` (hung in teardown) against 112 s through the bridge, with subsequent calls costing a few seconds instead of a fresh startup.

## Code layout

Class-per-folder convention: `@ClassName/` holds a class's methods as separate `.m` files (e.g. `geometry/@vector3d/angle.m`). Top-level folders group by domain:

- `geometry/` — vectors, orientations, Miller indices, symmetries (see `geometry/CLAUDE.md`)
- `EBSDAnalysis/` — EBSD data, grains, grain boundaries, reconstruction (see `EBSDAnalysis/CLAUDE.md`)
- `PoleFigureAnalysis/` — pole figure data and ODF-from-pole-figure solvers
- `SO3Fun/`, `S2Fun/`, `S1Fun/` — function spaces on the rotation group, sphere, and circle (see `SO3Fun/CLAUDE.md`, `S2Fun/CLAUDE.md`, `S1Fun/CLAUDE.md`)
- `TensorAnalysis/` — elastic/plastic tensor calculations (see `TensorAnalysis/CLAUDE.md`)
- `plotting/` — all figure/plot code (see `plotting/CLAUDE.md`)
- `interfaces/` — file format import/export (see `interfaces/CLAUDE.md`)
- `doc/` — published example scripts (also the source for the online documentation)
- `extern/` — vendored third-party code (jsonlab, NFFT, jcvoronoi, etc.)
- `mex/` — compiled MEX binaries (checked in; not rebuilt by default)
- `obsolete/`, `old/`, `compatibility/` — deprecated functions kept only as thin wrappers/shims for backward compatibility (they warn/error and forward to the current API); don't use them as a reference for current coding patterns

## Tests

`tests/` contains standalone `check_*.m` functions — not a `matlab.unittest` suite. Each runs a computation and calls `error(...)`/`assert(...)` on failure. They are sorted into tiers, and `runTests` runs a tier:

```
matlab -batch "runTests"            # core, the fast suite
matlab -batch "runTests('slow')"
matlab -batch "check_mtex"          # same as runTests
```

| tier | what is in it |
| --- | --- |
| `tests/core/` | the computational core on synthetic or tiny data — **held to 60 s for the whole tier**, so it can be run before every commit |
| `tests/slow/` | real datasets and benchmarks, minutes |
| `tests/plotting/` | tests whose assertion is about a graphics object |
| `tests/lib/` | fixtures and generators, never collected as tests |

Every `check_*.m` in a tier folder is a test of that tier — there is no list to register with. `runTests` runs each in its own try/catch, resets figures/RNG/warning state between them, prints a pass/fail table with timings, and raises at the end so `-batch` exits nonzero.

`check_mex` and `check_mexComplete` stay at `tests/` root and are not tests: the first is an installer called from `startup_mtex.m` on every start, the second is the build gate used by `.github/workflows/build-mex.yml`.

**Read `tests/CLAUDE.md` before adding a test.** It records which file owns which subsystem, when a bug earns a new file at all, and which tier to run when — the folder reached 84 files by adding roughly one per bug, and about a third of them asserted nothing.

## Architecture

**Everything is vectorized.** A single object instance holds an array of many entities — a `vector3d` holds a whole point cloud, an `EBSD` object holds an entire scan, a `grain2d` holds every grain in a map — and its properties are arrays/matrices in lockstep, not scalars. Methods operate elementwise across the whole array (MATLAB operator overloading, `bsxfun`-style broadcasting) rather than being called in a loop over individual entities. When reading or writing a method, assume `this` represents N objects at once and check how indexing (`this(idx)`) is implemented before assuming a loop is needed.

**Core geometric class hierarchy** (`geometry/`, full detail in `geometry/CLAUDE.md`):
- `quaternion` → `rotation` → `orientation`: a rotation is a quaternion with group-theoretic operations; an orientation is a rotation tied to a pair of `crystalSymmetry`/`specimenSymmetry` (symmetrically equivalent representations, fundamental-zone reduction, misorientation, etc.).
- `vector3d` → `Miller`: a `Miller` index is a `vector3d` expressed in a `crystalSymmetry`'s crystal frame (adds `h,k,l`/`u,v,w` convention handling).
- `symmetry` (→ `crystalSymmetry`, `specimenSymmetry`) is threaded through most geometry/EBSD/tensor objects to determine equivalent orientations and fundamental regions.

**EBSD → grains pipeline** (`EBSDAnalysis/`, full detail in `EBSDAnalysis/CLAUDE.md`): an `EBSD` object (per-pixel phase/orientation/property data on a spatial grid, see `@EBSDsquare`/`@EBSDhex`/`@EBSD3`) is segmented by `calcGrains` into a `grain2d` (or `grain3` for volume data), whose boundary segments are a separate `grainBoundary` object. `parentGrainReconstructor` builds a graph over grain boundaries/orientation relationships to reconstruct parent-phase grains from child-phase EBSD data (e.g. austenite from martensite).

**Function-space objects** (`SO3Fun/`, `S2Fun/`, `S1Fun/`, full detail in each folder's `CLAUDE.md`): ODFs and spherical/pole-figure data are represented as function objects (`SO3FunHarmonic`, `SO3FunRBF`, `S2FunHarmonic`, `S2FunTri`, ...) sharing a common abstract interface (`SO3Fun`, `S2Fun`) — evaluation, calculus (differentiation/convolution), and arithmetic are overloaded operators, and different representations (harmonic/Fourier, radial basis function, triangulation, homochoric) are interchangeable behind the same interface. `SO3VectorField`/`S2VectorField` mirror this for vector-valued fields (e.g. ODF gradients).

**Plotting** (`plotting/`, full detail in `plotting/CLAUDE.md`): all plots go through `mtexFigure`, a wrapper around MATLAB figures that manages multi-axis layouts (e.g. pole figure arrays), colorbars, and annotations consistently; most `plot` methods on geometry/EBSD/ODF classes ultimately call into it rather than raw MATLAB plotting calls.

## Agent skills

### Issue tracker

Issues live in GitHub Issues on `mtex-toolbox/mtex`, via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Default five canonical labels (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`), unchanged. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context — `CONTEXT.md` + `docs/adr/` at the repo root (neither exists yet; created lazily by `/domain-modeling`). See `docs/agents/domain.md`.
