# Spherical discrepancies

`discrepancy(a,b,...)` accepts two scalar `S2Fun` densities, two `vector3d`
point sets, or a mixed pair in either order. Point weights are normalized
independently; in a mixed pair their total mass is the function's integral.
Functions must have equal integrals and are not normalized automatically.
Antipodal points represent explicit half-weight copies at both signs.
An even reference density does not remove odd moments of directed points.

## Definitions and API

Write `nu = mu - eta`, `C(m,t) = {x: m.x >= t}`, and let `sigma` be surface
area divided by `4*pi`. The standard conventions implemented here are:

- `D_cap = sup_(m,t) |nu(C(m,t))|`.
- `D_2^2 = integral_-1^1 integral_S2 |nu(C(m,t))|^2 d sigma(m) dt`.
- `E_L^2 = sum_(l=1)^L sum_(k=-l)^l |nu_hat(l,k)|^2`.

The height integral is **dt**, not dt/2. In angular radius it is
`sin(r) dr`. Fourier coefficients use MTEX's area-orthonormal convention,
so the uniform probability density has coefficient `1/sqrt(4*pi)`.

```matlab
[d,info] = discrepancy(f,v,'metric','D_cap','numCenters',4097, ...
  'numHeights',513,'bandwidth',32);
d2 = discrepancy(f,v,'metric','D_2','bandwidth',32);
e = discrepancy(f,v,'metric','L2','bandwidth',32);
eSquared = discrepancy(f,v,'metric','L2','bandwidth',32,'squared');
d = discrepancy(v,w,'weights',c,'weights2',q,'metric','D_2');
```

The default is now `D_2`. All three return distances; `squared` requests
squares. `E_L` is an alias for `L2`. Bandwidth controls the projection of
functions and the truncation in E_L. For harmonic functions it defaults to
the largest input function bandwidth, and nonharmonic functions contribute
128. Point/point E_L defaults to 128. In D_2 and D_cap, point measures remain
atomic at every bandwidth. Thus comparing a constant function with points
at bandwidth zero still detects nonuniformity with both cap metrics.

A projected nonharmonic density need not stay nonnegative. The computation
then describes that signed projection; increase bandwidth and check
convergence when interpreting the answer as a probability discrepancy.
Original function masses are restored after projection.

### D_2: no truncation of the point measure

Stolarsky's identity gives

`D_2^2(nu) = -1/4 integral integral ||x-y|| dnu(x) dnu(y)`.

The implementation evaluates atomic terms in blocks, with O(N^2) work
and O(N) temporary storage (fixed block size). Continuous and cross terms
use harmonic weights `4*pi/((2*l-1)*(2*l+1)*(2*l+3))`. The result is exact
up to floating-point/transformation error when input densities are harmonic
and their bandwidth is retained. `info.isExact` describes whether function
projection loses information. For nonharmonic densities it is false.

### D_cap: approximate global search

The implementation searches a Fibonacci grid of centers (2049 requested
by default), the six coordinate directions, and both signs of all point
supports. Alternatively, supply `centers`, a `vector3d` list. For each
center it checks a uniform height grid (257 by default), every atomic
projection, and both sides of each jump. Coincident projections are grouped
before summing weights. Harmonic cap integrals use the Funk-Hecke formula;
point masses are never smoothed into a density.

The result is a **lower-bound approximation for the represented measures**,
not a certified global maximum. `info.isExact` is always false. `info.center`,
`height`, `closed` and `signedDifference` describe the best cap or its
one-sided limit. For nonharmonic functions, projection error also applies,
so this is not a guaranteed bound for the original unprojected density.

Refine both center and height grids to assess stability. A single stable
result is not a rigorous error certificate. Supplying nested center lists
and height grids gives nondecreasing estimates for a fixed representation.
Searching points against points exhausts all heights for each chosen
center, but it still does not exhaust all possible center directions.

Exact maximum cap discrepancy is possible for finite points against the
uniform density using cap enumeration; this is a different, more expensive
algorithm. It does not directly solve arbitrary density comparisons. No
exact enumeration or global error certificate is implemented here.

### Migration from the old objective

`metric='kernel'` preserves the old **squared**, bandlimited optimization
objective, including its special antipodal-density convention. Without
that odd-degree projection it equals `4*D_2(Pi_L nu)^2`, not `D_cap` and not
necessarily four times the full atomic D_2 squared. `optimalSample` still
minimizes this historical objective. The previous experiments now request
`kernel` explicitly; their recorded statistics and powers are unchanged.
Earlier experimental `metric='D_cap'` calls must use `kernel` to reproduce
those numbers. Earlier squared `L2` calls must add `squared`.

## Weighting E_L for testing

The optional `degreeWeights` are **energy weights**:

`E_(L,w)^2 = sum_l w_l sum_k |nu_hat(l,k)|^2`.

Pass L+1 nonnegative finite values (including the unused degree-zero value)
or a function handle evaluated at `(0:L)'`. Equal weights within each
degree preserve invariance under a common rotation of the two measures.

```matlab
% Heat weights: smooth suppression beyond an angular scale sqrt(tau).
tau = 0.01;
e = discrepancy(f,v,'metric','L2','bandwidth',32, ...
  'degreeWeights',@(l) exp(-tau*l.*(l+1)));

% Mild negative-Sobolev weighting.
s = 0.5;
e = discrepancy(f,v,'metric','L2','bandwidth',32, ...
  'degreeWeights',@(l) (1+l.*(l+1)).^(-s));

% A band of degrees that is affected by the proposed deformation.
e = discrepancy(f,v,'metric','L2','bandwidth',32, ...
  'degreeWeights',@(l) double(l>=4 & l<=16));
```

Useful choices are flat weights with a cutoff, heat weights, mild Sobolev
weights, and a band-pass chosen from the anticipated alternative. The cap
weights fall as l^-3 and strongly favor coarse structure. For the smiley
rotation/smoothing alternatives, start with flat cutoffs and heat tapers
around the degrees where the target changes; band-pass weights can avoid
paying noise from unaffected low degrees. These are candidates to benchmark,
not a claim that one scheme is always most powerful.

There are 2*l+1 coefficients in degree l. Under the uniform IID null, each
real orthonormal nonconstant coefficient has variance 1/(4*pi*n). Thus
`w_l=1/(2*l+1)` equalizes the *expected null energy per degree*, while
`w_l=1/sqrt(2*l+1)` approximately equalizes its *variance* in the Gaussian
limit. Neither is automatically power optimal. A nonuniform null has a
nontrivial coefficient covariance, including correlations across degrees.
Regularized covariance whitening is a matrix weighting and is not covered
by this scalar-per-degree option.

Choose weights/cutoffs in advance or on independent training data. If
selecting among several statistics using the test sample, repeat that
selection inside the Monte Carlo/permutation calibration; calibrating each
candidate separately at 5% and rejecting on their maximum inflates size.

## Validation and references

`tests/core/check_optimalSample.m` checks analytic D_2 and D_cap values,
continuous/discrete cross terms, tied atomic jumps, rotation and argument
symmetry, axial measures, weights, scaling, bandwidth behavior and legacy
optimization regression cases.

- [Brauchart and Dick: A simple Proof of Stolarsky's Invariance Principle](https://arxiv.org/abs/1101.4448)
- [Heitsch and Henrion: An enumerative formula for the spherical cap discrepancy](https://arxiv.org/abs/2012.10303)
- [Gretton et al.: A Kernel Two-Sample Test](https://www.jmlr.org/papers/volume13/gretton12a/gretton12a.pdf)

### Development smoke results (2026-09-09)

The focused discrepancy/optimalSample suite passed in 8.65 s. For a
reproducible `rng(7); v=vector3d.rand(100,1)` comparison with uniform density,
D_2 was 0.051397933. Cap searches gave:

| Requested Fibonacci centers | D_cap estimate | Seconds |
|---:|---:|---:|
| 129 | 0.125264287 | 0.034 |
| 513 | 0.132501497 | 0.033 |
| 2049 | 0.135223618 | 0.109 |
| 8193 | 0.135403376 | 0.469 |
| 32769 | 0.135360385 | 1.385 |

The center grids are not nested, so estimates need not increase monotonically.
Coordinate axes and both signs of point supports are added to these counts.

For the bandwidth-16 projection of `(abs(S2Fun.smiley)+0.1)`, normalized to
integral one, versus its 5-degree X rotation, D_2 was 0.009851975 and E_16
was 0.075674325. With 129 height samples, the D_cap estimates were
0.020167784, 0.020335543 and 0.020333993 for 129, 513 and 2049 requested
centers (0.05--0.14 s). This checks practical evaluation and search stability;
it is not a new statistical-power benchmark or a global accuracy certificate.
