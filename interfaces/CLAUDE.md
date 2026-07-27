# interfaces/

File format import/export for EBSD, pole figure, ODF, orientation, and grain data.

- `loadData.m` is the format-agnostic entry point (`loadData(fname, type, ...)`); it never guesses a parser itself — it delegates to `interfaces/tools/check_interfaces.m`, which auto-detects the right loader by trying each installed `load<Type>_*.m` in turn (via `dir([mtex_path '/interfaces/load' type '_*.m'])`) and checking which one accepts the file. Adding a new format means adding a new `load<Type>_<format>.m` file with the right naming convention — there is no separate registry to update.
- Format-specific loaders (`loadEBSD_ang.m`, `loadEBSD_ctf.m`, `loadEBSD_h5.m`, `loadEBSD_osc.m`, `loadEBSD_crc.m`, `loadEBSD_generic.m`, `loadODF_*`, `loadOrientation_*`, `loadGrains_Dream3d.m`, `loadGrainSet_hdf5.m`, `loadNeperTess.m`, …) each live directly under `interfaces/`; shared low-level helpers (header parsing, Euler angle corrections, grid assertions) live in `interfaces/tools/`.
- `loadEBSD_dream3d.m` and `loadEBSD_xnovo.m` are **known-WIP, not yet functional** — a failure there is not a regression to chase down.
- `hdf5_config/` and `import_wizard/` support format-specific HDF5 configuration and (legacy) interactive import — not the primary code path for scripted loading.
- `functionSignatures.json` drives MATLAB tab-completion/argument validation for public loaders; keep it in sync when changing a public loader's signature.
