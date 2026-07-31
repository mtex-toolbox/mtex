# TensorAnalysis/

Elastic/plastic tensor calculations built on a single generic `@tensor` base class, with physically-typed subclasses (`@stiffnessTensor`, `@complianceTensor`, `@strainTensor`, `@stressTensor`, `@strainRateTensor`, `@curvatureTensor`, `@dislocationDensityTensor`, `@ChristoffelTensor`, `@refractiveIndexTensor`, `@spinTensor`, `@velocityGradientTensor`, `@deformationGradientTensor`) adding physical meaning and unit/rank-specific behavior (e.g. `stiffnessTensor`/`complianceTensor` know they're mutual inverses under Voigt contraction) rather than reimplementing tensor algebra each.

- `EinsteinSum.m` is the core contraction engine (`EinsteinSum(T1, dimT1, T2, dimT2, ...)`, negative indices mark summed dimensions) underlying most tensor products/contractions in this folder and used by higher-level code elsewhere — reach for it instead of writing manual index loops over tensor components.
- `dyad.m` builds tensors as outer (dyadic) products of vectors — the usual way to construct a rank-2+ tensor from `vector3d` inputs rather than assembling a components matrix by hand.
- `SchmidTensor.m` computes the Schmid tensor/factor for slip systems (paired with `@dislocationSystem` in `geometry/`).
- Symmetry constraints (e.g. how many independent components a `stiffnessTensor` has for a given crystal symmetry) are enforced via the attached `crystalSymmetry`, following the same symmetry-threading convention as the rest of the codebase — don't hand-write symmetry reduction for a new tensor type; check whether `@tensor` already handles it generically.
