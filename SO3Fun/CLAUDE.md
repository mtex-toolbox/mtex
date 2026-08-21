# SO3Fun/

ODFs — functions on the rotation group SO(3).

- `@SO3Fun` is the abstract base (`dynOption` mixin). Concrete representations —
  `@SO3FunHarmonic` (Wigner-D coefficients), `@SO3FunRBF` (`SO3KernelFunctions/`),
  `@SO3FunHomochoric`, `@SO3FunBingham`, `@SO3FunCBF`, `@SO3FunSBF`, `@SO3FunMLS`,
  `@SO3FunHandle`, `@SO3FunComposition` — share one interface: `eval(SO3F,ori)`, arithmetic
  (`+`, `*`, `conv`), calculus. **Code written against `@SO3Fun` must work against any of
  them**; do not special-case a subclass outside a representation-specific method.
- `CS`/`SS` alias `SRight`/`SLeft`. An ODF is symmetric from the **left** under specimen
  symmetry and from the **right** under crystal symmetry, not the other way round.
- `symmetrise.m` folds symmetry into the Fourier coefficients directly rather than
  resampling and refitting — the fast path, used by most harmonic constructors.
- `@SO3VectorField` (+ `Handle`/`Harmonic`/`RBF`) mirrors the pattern for vector-valued
  fields, e.g. an ODF gradient. `SO3TangentSpace.m` defines the representation — left vs
  right tangent is a standing source of sign errors.
- `doEulerStep.m` is Euler-space stepping for some solvers. Check for an existing `@SO3Fun`
  operation before adding a numerical routine here.

Traps:

- A non-finite node passed to the nfft/nfsft mex makes it write outside its buffers and
  crashes MATLAB. `eval` and `adjoint` substitute a valid node and restore NaN afterwards —
  a new call site into the mex has to do the same.
- The mex interfaces insist on **double**; several importers store rotations in single.

Same pattern on the sphere and the circle: `S2Fun/CLAUDE.md`, `S1Fun/CLAUDE.md`.
