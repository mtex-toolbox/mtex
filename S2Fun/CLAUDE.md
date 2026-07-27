# S2Fun/

Function-space objects for functions on the 2-sphere — pole figures, spherical texture components, IPF-style directional data. Mirrors the `@SO3Fun` pattern (see `SO3Fun/CLAUDE.md`): an abstract `@S2Fun` base with interchangeable concrete representations — `@S2FunHarmonic` (spherical harmonic coefficients, see `S2KernelFunctions/`), `@S2FunTri` (spherical Delaunay triangulation), `@S2FunHandle`, `@S2FunBingham`, `@S2FunMLS`, `@S2FunHarmonicSym` (harmonic with symmetry baked in), plus `S2FunRBF.m`, `S2FunGrid.m`.

- `antipodal` (grain-exchange / inversion symmetry, `S2Fun.antipodal`) matters a lot here: many EBSD/pole-figure quantities are only defined up to `±v`, and functions/plots need to know whether to treat `v` and `-v` as identical. Check the `antipodal` flag rather than assuming a function is defined on the full sphere.
- `@S2AxisField`/`@S2AxisFieldHarmonic`/`@S2AxisFieldTri` are the antipodal (axis, not vector) analogue of `@S2VectorField` — used for director-type fields (e.g. principal stress/strain axes) where `v` and `-v` are physically indistinguishable.
- `@S2VectorField` (+ `Handle`/`Harmonic`/`Tri`) mirrors `@S2Fun` for vector-valued fields, same pattern as `SO3VectorField`.
- `supportFun.m` computes support-function-style quantities (e.g. for crystal shapes) over `@S2Fun` objects.
