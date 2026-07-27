# SO3Fun/

Function-space objects representing ODFs (orientation distribution functions) — functions on the rotation group SO(3).

- `@SO3Fun` is the abstract base (`dynOption` mixin): concrete representations — `@SO3FunHarmonic` (Fourier/Wigner-D coefficients), `@SO3FunRBF` (radial basis / kernel functions, see `SO3KernelFunctions/`), `@SO3FunHomochoric`, `@SO3FunBingham`, `@SO3FunCBF`, `@SO3FunSBF`, `@SO3FunMLS`, `@SO3FunHandle` (arbitrary function handle), `@SO3FunComposition` (weighted sum of components) — all share the same abstract interface: evaluation `eval(SO3F, ori)`, arithmetic (`+`, `*`, `conv`), and calculus (gradient, differentiation). Code written against `@SO3Fun` should work unmodified against any concrete representation; don't special-case a subclass unless you're implementing a representation-specific method.
- `CS`/`SS` (crystal/specimen symmetry) are dependent properties aliasing `SRight`/`SLeft` — an ODF is symmetric functions from the *left* under specimen symmetry and from the *right* under crystal symmetry, not the other way round (`@SO3Fun/SO3Fun.m`).
- `symmetrise.m` folds crystal/specimen symmetry into an `@SO3FunHarmonic`'s Fourier coefficients directly (not by resampling and refitting) — this is the fast path for symmetrizing a harmonic ODF and is used internally by most harmonic constructors.
- `@SO3VectorField` and its concrete forms (`Handle`/`Harmonic`/`RBF`) mirror the `@SO3Fun` pattern for vector-valued fields, e.g. the gradient of an ODF (`SO3TangentSpace.m` defines how tangent vectors are represented — left- vs right-tangent matters and is a common source of sign errors when differentiating).
- `doEulerStep.m` implements Euler-angle-space stepping used by some solvers/optimizers over ODFs — check whether an existing `@SO3Fun` operation already does what you need before adding a new numerical routine here.

See also `S2Fun/CLAUDE.md` and `S1Fun/CLAUDE.md` for the same abstract-interface pattern applied to spherical and circular functions, respectively.
