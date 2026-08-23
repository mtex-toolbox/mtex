# Does the TrueEBSD workflow belong in MTEX?

**Status: Proposed — a spike, on branch `spike/trueebsd-in-mtex`. Not merged, not a
commitment to ship.**

**Verdict: GO WITH CONDITIONS.** The class runs on MTEX alone, reproduces every published
number exactly, and needed no restructuring to arrive. Three conditions stand between the
spike and a merge, and one of them is not a technical question at all.

## Why this was asked

TrueEBSD ([arXiv 2605.00703](https://arxiv.org/abs/2605.00703), Apache-2.0) is an add-on
that aligns EBSD maps with electron images of the same specimen area. Over the last months
the machinery underneath it moved into MTEX one primitive at a time — `@spatialTransform`
and its fitted subclasses, `@mapImage`, `xcfShift`, `@gridLayout`. What was left in the
add-on was the *workflow*: the job class that walks the chain of maps, fits each hop and
resamples.

Whether that last piece belongs here was deferred as needing an ownership answer rather
than a technical one — it ties the method's release cadence to MTEX's, and a waived licence
objection is not an offer to maintain someone else's method. That deferral is still correct.
But half the question *is* technical, and this spike answers that half so the other half can
be decided on evidence.

The add-on keeps `@trueEbsd` and `@distortedImg` as a working fallback throughout.

## What was done

Six stages, each independently revertible, on paired branches in MTEX and the add-on.

| | |
|---|---|
| 0 | the A/B harness gained assertions — it had none |
| 1 | `@pairShifts` and `remapShifted` **copied** into `tools/registration_tools/` |
| 2 | `@trueEbsd2` copied into `EBSDAnalysis/`, byte-identical |
| 3 | the add-on deleted its copy, so MTEX's became load-bearing |
| 4 | `tests_autoTune` became `tests/slow/check_trueEbsd` |
| 5 | error ids namespaced, classdef header reshaped |

The class kept the transitional name `trueEbsd2` throughout. Renaming it to `trueEbsd` on
arrival would collide with the add-on's own `@trueEbsd` whenever both are on the path —
which is the normal state, and is required by the A/B harness that compares them.

## Findings

### 1. Self-sufficiency — yes, unambiguously

With the add-on's 44 path entries stripped, the five-map WC-Co sequence runs
`pixelSizeMatch` → `setOptions` → `calcDistortion('fitErr')` → `undistort` in **3.9 s** and
returns exactly the add-on's numbers: hop shifts 0.638739 / 0 / 3.25171 / 0.384742 px,
residuals 1.40711 / 1.19196 / 0.286432 / 0.280595 px, 44832 indexed, `corr(bc,img)`
0.930867. Nothing in `@distortedImg` or `funcsV0` is reachable while that runs.

This needed care to establish. The add-on is on this machine's **saved** path, so a fresh
session already has it; `startup_mtex` prepends MTEX, so MTEX happens to win, but that is
shadowing rather than absence. A probe that only checked `which` would have passed while
still being one path entry away from the thing it claimed not to use. `check_trueEbsd`'s
`checkSelfSufficient` pins the honest property instead — everything resolves under
`mtex_path` — which is also true for a user who legitimately has the add-on installed.

### 2. Two new external dependencies — one removed, one open (**condition 1**)

Both were in `checkOrientation`, the defensive check that errored when an EBSD map read
mirrored against the image it registers to.

- **Image Processing Toolbox — resolved.** `imresize` and `normxcorr2` appeared nowhere in
  `EBSDAnalysis/`, `geometry/`, `tools/` or `plotting/`; the only occurrences in the
  repository are vendored files under `extern/`. **`checkOrientation` was deleted**, which
  removes both calls, the `'skipOrientationCheck'` option and
  `MTEX:trueEbsd:orientationMismatch` — 116 lines. MTEX gains no toolbox dependency.
- **`createArray` — still open.** Two calls in `calcDistortion`. It was **introduced in
  R2024a** — verified by bisecting the eleven MATLAB installs on this machine: absent in
  R2023a and R2023b, present as `toolbox/matlab/elmat/createArray.m` from R2024a (24.1.0)
  onward, and promoted to a built-in by R2026a. `README.md:38` declares MTEX supports R2014b
  and `createArray` appears nowhere else in the repository, so the class as it stands cannot
  run on the declared floor. `createArray(n,1,'pairShifts')` is `repmat(pairShifts,n,1)`;
  this has not been done.

  Raising the floor to R2024a would also close it, and is the wrong trade: ten years of
  supported releases for two calls that have an exact one-token replacement. Note too that
  nobody has swept the class for its *actual* binding constraint — `xcfShift` beneath it
  already needs `pagemtimes` (R2020b) — so R2024a is the floor `createArray` imposes, not
  necessarily the floor the workflow imposes.

Neither broke anything here — IPT is licensed on this machine and the bridge runs R2024b —
which is exactly why they had to be looked for rather than waited for.

**On deleting the check rather than rewriting it.** It guarded a real failure mode: a map
read into image order through the wrong plotting convention arrives mirrored, the ROI shifts
come out as noise, the fits succeed on that noise, and the workflow returns a
finished-looking job. What changed is that it is no longer the only guard. The constructor
compares every entry's `@gridLayout` and raises `MTEX:trueEbsd:frameMismatch`, and a map
entry's array order is now read off `d1`/`d2` with no convention consulted anywhere — so the
session convention, which was what made the mirror reachable, is no longer load-bearing. The
add-on's own notes had already asked whether the check still earned its lines.

What is genuinely lost is the case the constructor cannot see: a *single* map registered
against images that carry no frame to compare against. That is the configuration both
shipped examples use. The residual risk is that such a job now fails as a bad registration
rather than as a named error — visible in the residuals, but not explained. If it should
come back, it belongs as a cheap check built on `xcfShift`, which is already in
`tools/registration_tools/`, rather than on `normxcorr2`.

### 3. Numerical neutrality — exact

`tests_migrationAB` pins both columns and every value is unchanged across all six stages,
including after the error-id sweep. Since Stage 3 it compares MTEX's `@trueEbsd2` against
the add-on's `@trueEbsd`, so the reproduction is genuinely cross-repository.

| | `@trueEbsd` | `@trueEbsd2` |
|---|---|---|
| hop 1–4 residual (px) | 1.32538 / 1.19196 / 0.287235 / 0.316595 | 1.40711 / 1.19196 / 0.286432 / 0.280595 |
| indexed | 45644 | 44832 |
| `corr(bc,img)` | 0.930941 | 0.930867 |

The gap between the columns is the documented result of moving the fitting to
`spatialTransform.fit`, not of this move. Two hops improved, one is worse by 0.082 px which
is inside that hop's own scatter, and the 812 lost points are all border pixels where the
drift spline extrapolates rather than measures — an open question about the method, tracked
in the add-on.

The harness had **zero assertions** before Stage 0. It printed a table for a human to
compare by eye, which meant the numbers every claim about this migration rests on could have
drifted silently. Fixing that first was what made every later stage's proof mean anything.

### 4. Conformance debt — smaller than feared, and editorial — **condition 2**

Of 2048 lines, 909 (44%) are comments. But the breakdown matters:

| | |
|---|---|
| file and function headers — **required**, they generate the reference pages | 400 lines, 10 blocks |
| body blocks of ≥4 consecutive comment lines — **the actual debt** | **330 lines, 41 blocks** |

`CLAUDE.md` forbids the multi-line justification block and records that the repository was
swept once to remove ~2800 of them. 330 is about a tenth of that, not the third an
undifferentiated count suggests.

It is not a mechanical delete. Three sampled blocks, and none of them is simply removable:

- **`private/autoTune.m:163`, 23 lines** — why `registerOn` is *stated* rather than
  measured: two criteria were implemented and both failed against a case whose answer is
  known, one of them costing 8000 indexed points. → **extract to an ADR**, the same move
  `0004-fmc-parameter-defaults.md` made for `gbcFMC`.
- **`calcDistortion.m:487`, 12 lines** — justifies the 1.5× threshold with the measured
  margins it was chosen from. → **compress to one line, numbers to the ADR.** Deleting it
  outright would leave a magic number with no reason.
- **`trueEbsd2.m:144`, 14 lines** — what the `opt` settings are and why they live on the job
  rather than on `@mapImage`. → **move into a header**, where it is interface documentation
  rather than a body comment.

So the conversion is a day of editorial work plus one or two ADRs, not a `sed`. That it has
a known destination — ADR 0004 set the precedent — is what makes it a condition rather than
an objection.

### 5. Structural fit — nothing had to be reshaped

The class arrived in MTEX's shape. The classdef already held only properties, getters and
the constructor; every method was already its own file; the helpers were already in
`private/`. That is the `@parentGrainReconstructor` layout exactly, and no file was moved or
split to achieve it. The methods already mutate in place and return the job, which is the
same idiom.

This is the strongest positive finding, and it is not a coincidence: the add-on adopted the
handle-class-guiding-a-process pattern *from* MTEX.

### 6. Fallback coupling — the copy decision, and what it cost

`@pairShifts` and `remapShifted` were **copied**, not moved, because `@trueEbsd` declares
`fitError = pairShifts.empty` as a property default and MATLAB resolves that at class-load
time. Moving it would mean the add-on's fallback fails to load whenever MTEX is not on the
spike branch — pointing at its own property block, saying nothing about the real cause — and
the fallback's entire value is being unconditional.

Verified: with MTEX checked back to plain `develop`, the add-on's `tests_wccoSmall` passes
and returns its whole reference block unchanged. The fallback does not depend on the
experiment.

The cost is that the shared files are frozen. Their four error ids still read `trueEbsd:`
rather than `MTEX:trueEbsd:`, because namespacing them would trade a checkable invariant
(the two copies `diff` clean) for a cosmetic one. On a merge the copies become moves and
that resolves itself; while the fallback exists, it does not.

### 7. The API MTEX would commit to — **condition 3**

Six public methods (`pixelSizeMatch`, `calcDistortion`, `undistort`, `setOptions`,
`display`, the constructor) and seven properties. One divergence is a real design question
rather than a detail:

**MTEX passes options as `varargin` through `get_option`/`check_option`. `@trueEbsd2` uses a
per-map struct array set through `setOptions`.** That is not laziness — the settings are
per-map and per-fit-stage, they are lengths in the sequence's `scanUnit` so they survive
`pixelSizeMatch`, and most default to `'auto'` and are *measured* rather than defaulted. A
`varargin` list cannot carry per-map values without becoming a cell array of cell arrays.
But it is a second options idiom in a repository that has one, and adopting it should be a
decision rather than a side effect of accepting the class.

The GUI is not part of this. `interfaces/` stays in the add-on, and whether it ever comes is
a separate question. Worth noting that it kept working across the repository boundary with
no changes at all: it constructs a class that now lives in another repository, `isa` still
holds, and MATLAB still resolves `interfaces/private/` against the calling file.

## Corroborating evidence

All four `@trueEbsd2` doc pages in the examples repository (`TrueEBSD/example_*_2.m`)
reference only names that resolve inside MTEX after this move. They run on MTEX alone, and
their install blocks — telling the reader to `addpath` an external toolbox — become false.

## The conditions, restated

1. ~~Remove the IPT dependency~~ — **done**, by deleting `checkOrientation`. What remains is
   `createArray`, two calls, needing R2024a against a declared floor of R2014b.
2. **Convert the 330 lines of body comments**, extracting the measured reasoning into ADRs
   rather than deleting it.
3. **Decide the options idiom** — accept `setOptions` as a second pattern, or reconcile it
   with `get_option`.

And, unchanged by any of this: **whether MTEX wants to own the method.** The spike says the
code fits. It does not say the project should take on the maintenance, and that remains the
author's call.

## Reverting

No stage has an irreversible step. Delete the MTEX branch and `git checkout mtex7-frames` in
the add-on, in that order — the add-on branch is the only thing referencing MTEX's copies.
`develop` was never touched.
