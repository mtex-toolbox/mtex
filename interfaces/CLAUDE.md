# interfaces/

File format import/export for EBSD, pole figure, ODF, orientation and grain data.

- `loadData(fname,type,...)` is the entry point. It delegates to
  `interfaces/tools/check_interfaces.m`, which tries every installed `load<Type>_*.m` in
  turn. **A new format is a new `load<Type>_<format>.m` file** — there is no registry.
- Loaders sit directly under `interfaces/`, shared helpers (header parsing, Euler
  corrections, grid assertions) under `interfaces/tools/`.
- Export mirrors import: `exportEBSD_ang.m`, `exportEBSD_ctf.m` and `exportEBSD_h5.m` sit
  next to their loaders, dispatched by extension from `EBSD/export.m`. The old
  `@EBSD/export_*.m` are wrappers. Shared helpers are in `interfaces/private/`.
- `loadEBSD_dream3d.m` and `loadEBSD_xnovo.m` are **WIP, not functional** — a failure there
  is not a regression.
- `functionSignatures.json` drives tab-completion for public loaders. Keep it in sync.

Rules:

- **An exporter undoes the Euler correction its loader applies** — `eulerCorrectionRotation`
  for the EDAX settings, a 180° z rotation for `.ctf` — or the file re-imports turned. Same
  for the header: write back what the loader put in `ebsd.opt.header`, not zeros. See
  `docs/adr/0001-ebsd-opt-header.md`.
- `exportEBSD_h5` copies the source file and writes into the copy, driven by the record
  `loadEBSD_h5` leaves in `ebsd.opt.h5`. Only `'standalone'` writes from scratch.
- `h5write` cannot write a compound data set nor a fixed-length string (EDAX `MaterialName`
  is 21 chars, Bruker `Name` 17). The low-level `H5D.write` paths are what make `.edaxh5`
  and phase renaming work — without them the value silently stays as the file had it.

Traps:

- Phase column conventions are opposite: EDAX numbers phases from 1 with 0 = notIndexed,
  EMSphInx from 0 with 255 = notIndexed. An EMSphInx `.ang` carries no vendor marker.
- `fgetl` stops at a lone CR and `txt2mat` does not, so a vendor file with mixed line
  endings loses a row silently. Prefer `txt2mat` for the data block.

`hdf5_config/` and `import_wizard/` are HDF5 configuration and the interactive import, not
the scripted path.
