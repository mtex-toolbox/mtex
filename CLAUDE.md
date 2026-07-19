# MTEX

MTEX is an open-source MATLAB toolbox for crystallographic texture analysis (EBSD, pole figures, ODF reconstruction, grain boundaries, etc.). No GUI; everything is a MATLAB function/class API.

## Running MATLAB

Use `/opt/matlab-2024b/bin/matlab`, not the `matlab` on `$PATH` (that resolves to a newer MATLAB R2025b install which segfaults in headless/`-batch` mode on this machine — a licensing-library crash unrelated to MTEX).

Run from the repo root (`/home/hielscher/mtex/master`) so MATLAB auto-executes the `startup.m` in the current directory, which calls `startup_mtex` and adds all MTEX subfolders to the path:

```
/opt/matlab-2024b/bin/matlab -batch "your_command_here"
```

`-batch` runs headlessly (no desktop/menu) and exits after the command finishes. Startup (path setup + MTEX init) takes ~8-10s before your command runs.

## Code layout

Class-per-folder convention: `@ClassName/` holds a class's methods as separate `.m` files (e.g. `geometry/@vector3d/angle.m`). Top-level folders group by domain:

- `geometry/` — vectors, orientations, Miller indices, symmetries
- `EBSDAnalysis/` — EBSD data, grains, grain boundaries, reconstruction
- `PoleFigureAnalysis/`, `SO3Fun/`, `S2Fun/`, `S1Fun/` — pole figures and function spaces on rotation/sphere groups
- `TensorAnalysis/` — elastic/plastic tensor calculations
- `plotting/` — all figure/plot code
- `interfaces/` — file format import/export
- `doc/` — published example scripts (also the source for the online documentation)
- `extern/` — vendored third-party code (matGeom, jsonlab, NFFT, etc.)
- `mex/` — compiled MEX binaries (checked in; not rebuilt by default)
- `obsolete/`, `old/`, `compatibility/` — deprecated functions kept only as thin wrappers/shims for backward compatibility (they warn/error and forward to the current API); don't use them as a reference for current coding patterns

## Tests

`tests/` contains standalone `check_*.m` (and a few `test_*.m`, e.g. under `tests/SO3FunTests/`) scripts — not a `matlab.unittest` suite. Each is a function that runs a computation and either calls `error(...)` on failure or prints a success message. Run one by name:

```
/opt/matlab-2024b/bin/matlab -batch "check_mtex"
```

There's no single "run all tests" entry point in `tests/` (unlike `extern/matGeom/tests/runAllTests.m`, which only covers the vendored matGeom code).

## Architecture

**Everything is vectorized.** A single object instance holds an array of many entities — a `vector3d` holds a whole point cloud, an `EBSD` object holds an entire scan, a `grain2d` holds every grain in a map — and its properties are arrays/matrices in lockstep, not scalars. Methods operate elementwise across the whole array (MATLAB operator overloading, `bsxfun`-style broadcasting) rather than being called in a loop over individual entities. When reading or writing a method, assume `this` represents N objects at once and check how indexing (`this(idx)`) is implemented before assuming a loop is needed.

**Core geometric class hierarchy** (`geometry/`):
- `quaternion` → `rotation` → `orientation`: a rotation is a quaternion with group-theoretic operations; an orientation is a rotation tied to a pair of `crystalSymmetry`/`specimenSymmetry` (symmetrically equivalent representations, fundamental-zone reduction, misorientation, etc.).
- `vector3d` → `Miller`: a `Miller` index is a `vector3d` expressed in a `crystalSymmetry`'s crystal frame (adds `h,k,l`/`u,v,w` convention handling).
- `symmetry` (→ `crystalSymmetry`, `specimenSymmetry`) is threaded through most geometry/EBSD/tensor objects to determine equivalent orientations and fundamental regions.

**EBSD → grains pipeline** (`EBSDAnalysis/`): an `EBSD` object (per-pixel phase/orientation/property data on a spatial grid, see `@EBSDsquare`/`@EBSDhex`/`@EBSD3`) is segmented by `calcGrains` into a `grain2d` (or `grain3` for volume data), whose boundary segments are a separate `grainBoundary` object. `parentGrainReconstructor` builds a graph over grain boundaries/orientation relationships to reconstruct parent-phase grains from child-phase EBSD data (e.g. austenite from martensite).

**Function-space objects** (`SO3Fun/`, `S2Fun/`, `S1Fun/`): ODFs and spherical/pole-figure data are represented as function objects (`SO3FunHarmonic`, `SO3FunRBF`, `S2FunHarmonic`, `S2FunTri`, ...) sharing a common abstract interface (`SO3Fun`, `S2Fun`) — evaluation, calculus (differentiation/convolution), and arithmetic are overloaded operators, and different representations (harmonic/Fourier, radial basis function, triangulation, homochoric) are interchangeable behind the same interface. `SO3VectorField`/`S2VectorField` mirror this for vector-valued fields (e.g. ODF gradients).

**Plotting** (`plotting/`): all plots go through `mtexFigure`, a wrapper around MATLAB figures that manages multi-axis layouts (e.g. pole figure arrays), colorbars, and annotations consistently; most `plot` methods on geometry/EBSD/ODF classes ultimately call into it rather than raw MATLAB plotting calls.
