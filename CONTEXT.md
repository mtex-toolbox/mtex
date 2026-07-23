# MTEX

MTEX is a MATLAB toolbox for crystallographic texture analysis (EBSD, pole figures, ODF reconstruction, grain boundaries).

## Language

### EBSD data storage

**Property** (`ebsd.prop`):
Per-pixel data, one value per measurement point, indexed and subset in lockstep with the map (e.g. `MAD`, `BC`, `mis2mean`). Backed by `dynProp`; `subSet` truncates these fields when `ebsd(ind)` is evaluated.
_Avoid_: option, attribute, field (when meaning per-pixel data specifically)

**Option** (`ebsd.opt`):
Scan-level (whole-file) data that is not per-pixel and is not resized when `ebsd(ind)` is evaluated. Backed by `dynOption`. Anything that doesn't have exactly one value per measurement point belongs here, not in `prop`.
_Avoid_: property, metadata (when meaning scan-level data specifically)

**Header** (`ebsd.opt.header`):
The scan-level metadata captured from a file's own header/preamble section (instrument settings, operator, acquisition parameters, vendor-specific bookkeeping) — everything in the file that isn't a per-pixel column and isn't already represented by `CSList`/crystal symmetry. Kept in each vendor format's own native shape; there is no normalized field-name schema shared across formats. Phase/symmetry information is excluded even when it appears in the file's header section, since it's already captured by `CSList`.
_Avoid_: metadata, info, cprInfo (legacy name, superseded)

**headerOnly** (import option):
A boolean import option that short-circuits a loader before its expensive per-pixel/binary read, returning an `EBSD` object with empty `pos`/`rotations`/`phaseId` but populated `CSList`/`phaseMap`/`opt.header`. Exists for fast metadata inspection on large scans.
