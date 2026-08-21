# S2Fun/

Functions on the 2-sphere — pole figures, spherical components, directional data. Mirrors
the `@SO3Fun` pattern (`SO3Fun/CLAUDE.md`): abstract `@S2Fun` base, interchangeable
representations `@S2FunHarmonic` (`S2KernelFunctions/`), `@S2FunTri`, `@S2FunHandle`,
`@S2FunBingham`, `@S2FunMLS`, `@S2FunHarmonicSym`, plus `S2FunRBF.m`, `S2FunGrid.m`.

- **`antipodal` matters here.** Many EBSD and pole figure quantities are defined only up to
  `±v`. Check the flag rather than assuming the full sphere.
- `@S2VectorField` (+ `Handle`/`Harmonic`/`Tri`) is the vector-valued analogue;
  `@S2AxisField` (+ `Harmonic`/`Tri`) the antipodal one, for director fields such as
  principal stress or strain axes.
- `supportFun.m` computes support-function quantities, e.g. for crystal shapes.

Traps:

- A plain `@S2Fun` carries a `@referenceFrame`, not a symmetry
  (`docs/adr/0003-reference-frame-vs-symmetry.md`). In a crystal frame, extrema and samples
  come back as `Miller`.
