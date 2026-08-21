# TensorAnalysis/

One generic `@tensor` base with physically typed subclasses (`@stiffnessTensor`,
`@complianceTensor`, `@strainTensor`, `@stressTensor`, `@strainRateTensor`,
`@curvatureTensor`, `@dislocationDensityTensor`, `@ChristoffelTensor`,
`@refractiveIndexTensor`, `@spinTensor`, `@velocityGradientTensor`,
`@deformationGradientTensor`) that add physical meaning, not their own tensor algebra.

- `EinsteinSum(T1,dimT1,T2,dimT2,...)` is the contraction engine, negative indices mark
  summed dimensions. Use it instead of index loops over components.
- `dyad.m` builds a rank-2+ tensor from `vector3d` inputs — the usual construction, rather
  than assembling a components matrix.
- `SchmidTensor.m` computes the Schmid tensor and factor (paired with
  `geometry/@dislocationSystem`).
- Symmetry constraints, e.g. the number of independent components of a `stiffnessTensor`,
  come from the attached `crystalSymmetry`. Check whether `@tensor` already handles it
  generically before hand-writing reduction for a new type.

Traps:

- A tensor built from crystal data is in crystal coordinates and keeps that symmetry — the
  session default must not overwrite it. That is the route `slipSystem/deformationTensor`
  takes into `calcTaylor`.
- A tensor resolves the session default in its **constructor**, not in a property default: a
  property default expression is evaluated once when the class is loaded and would freeze
  whichever frame was current then.
