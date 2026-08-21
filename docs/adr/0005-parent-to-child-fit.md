# Fitting the parent to child orientation relationship

`calcParent2Child` estimates a parent-to-child orientation relationship `p2c` from a list
of child-to-child misorientations. The implementation is an iteration that everyone agrees
works and nobody could write down: there was no objective function anywhere in the file, the
damping factor and the `alpha = (alpha + 0.1) * 2` backtracking were folklore, and until
`a15b1ecf2` the answer depended on the row order of the input. On `mtexdata martensite` two
plausible answers sit 1.3 degree apart in `p2c` and 4.5 degree apart in the habit plane
derived from it.

This document names the objective, identifies the iteration as a classical algorithm, states
what breaks its convergence guarantee, and records how to reach the global optimum. It is
the reference for the comments that are deliberately *not* in
`geometry/misorientation/calcParent2Child.m`.

## Notation

`G_p` and `G_c` are the proper point groups of the parent and the child phase, of order
`n_p` and `n_c` — 24 and 24 for the fcc/bcc case. `p` is the sought orientation
relationship, `p2c` in the code. Distances are the disorientation distance between child
misorientations,

    d(m, c) = min over g, h in G_c of  angle(g m h, c)

with `angle(x,y) = 2 arccos |<x,y>|` the geodesic distance on SO(3).

## The model: the variant set is a conjugate of the parent group

The child variants of `p` are `p S_k` for `S_k` in `G_p`, deduplicated modulo `G_c`
(`geometry/@orientation/variants.m`). Two child grains grown from one parent in variants `i`
and `j` are therefore related by `(p S_i)(p S_j)^-1`, so the set of predicted child-to-child
misorientations is

    M(p) = { c_k(p) := p S_k^-1 p^-1 : S_k in G_p }

the conjugate of the parent point group by `p`. This is the line `c2c = p2c *
inv(p2c.variants)`.

Three consequences follow immediately and none of them is obvious from the code.

**Conjugation preserves the rotation angle.** `c_k(p)` is a rotation by the angle of `S_k`
about the axis `p a_k`. Only the *axes* of the variant set move with `p`; the angles are
fixed by the parent group. Fitting an orientation relationship is a Wahba-type problem of
rotating the parent's symmetry axes onto the observed misorientation axes.

**The identity variant carries no information.** `S_1 = id` gives `c_1(p) = id` for every
`p`. It contributes a constant to any objective, and an observation assigned to it produces a
vote (see below) equal to the current iterate — a pull toward wherever the iteration already
is. It must be excluded from the fit, and near-identity misorientations treated as outliers.

**The search domain is the misorientation fundamental zone of the phase pair.** The objective
is invariant under `p -> q p s` for `q` in `G_c` and `s` in `G_p`: on the right because
`s G_p s^-1 = G_p`, on the left because `q c_k(p) q^-1` is the same double coset. So the
domain is `G_c \ SO(3) / G_p`, of volume `8 pi^2 / (n_p n_c)`, which is 0.1371 rad^3 for
cubic to cubic. Three dimensions and a small volume is what makes exhaustive search
realistic.

## The objective

For observed misorientations `m_1 ... m_N` define the residual

    omega_i(p) = min over k of d(m_i, c_k(p))

Not every neighbouring grain pair comes from a common parent, so the fit has to be robust.
MTEX uses a **fixed-count trimmed loss**: with keep-fraction `q` (the `quantile` option,
default 0.9) and `h = ceil(q N)`,

    F(p) = sum over the h smallest of  r_i(p),      r_i = 1 - cos omega_i

The chordal residual `1 - cos omega` rather than `omega` itself is not cosmetic; it is what
makes the update step below an exact minimiser, and with it the whole convergence argument.

`F` is a genuine function of `p` alone. The quantile is a functional of `p`'s own residual
distribution, so iterates *are* comparable — the objective does not move under the algorithm.
A fixed *threshold* instead of a fixed count is a different matter: it makes the number of
retained observations depend on `p`, so the mean over them can be lowered by discarding
points, and it is not an objective at all. The correct fixed-threshold form is the truncated
loss `sum_i min(r_i, tau)`, in which outliers contribute `tau` rather than being deleted.

Two equivalent-in-spirit formulations are worth naming because they suggest different
algorithms:

| form | objective | classical name |
| --- | --- | --- |
| trimmed | `min_p F(p)` | trimmed k-means, LTS |
| truncated | `min_p sum_i min(r_i(p), tau)` | redescending M-estimator |
| kernel | `max_p sum_k MDF(c_k(p))` | mixture model, matched filter |

The third is the literal transcription of the informal description of what the function does
— find a `p2c` such that a large fraction of the observed misorientations lie close to some
c2c variant. With `MDF` the kernel density of the observations at halfwidth `psi`, the sum
counts, softly, how many observations sit within `psi` of a variant, and as `psi` goes to
zero it becomes the inlier count. It is the cheap surrogate used for the global search.

## The algorithm is a trimmed fixed-point iteration

Given `p^t`:

    assign        k(i) = argmin_k d(m_i, c_k(p^t)),  omega_i = d(m_i, c_k(i)(p^t))
    concentrate   I = the h indices with the smallest omega_i
    vote          v_i = project2FundamentalRegion(m_i, c_k(i)(p^t)) * p^t S_k(i)   for i in I
    update        p^(t+1) = chordal mean of the v_i
                          = principal eigenvector of sum_i v_i v_i^T

The vote is exact rather than heuristic. By right-invariance of the metric,
`d(m_i, c_k(p)) = angle(m_i p S_k, p)`, because `c_k(p) (p S_k) = p S_k^-1 p^-1 p S_k = p`.
An observation *together with an assumed variant* is a direct measurement of `p`: if the
observation were noise-free, `v_i` would equal `p` exactly. The update is the chordal mean of
those measurements, which is what `quaternion/mean.m` returns — the principal eigenvector of
the accumulated outer product, maximising `sum cos^2(omega/2)`, i.e. minimising `sum r_i`.

The projection matters and is not decoration: it selects the symmetric representative of
`m_i` closest to `c_k(p^t)`, which is what makes `angle(v_i, p^t)` equal the residual
`omega_i` rather than some larger symmetric equivalent of it.

**This is a fixed-point iteration, not a descent step.** The tempting reading — trimmed
k-means, so Lloyd's monotonicity argument applies — is wrong, and the reason is worth being
precise about. `v_i` depends on `p^t`, because `p` appears inside the vote. Minimising
`sum (1 - cos angle(v_i, p))` over `p` with the votes frozen at `p^t` is therefore not
minimising the objective `F`; it is one step of the fixed-point map

    T(p) = chordal mean over i in I of  ( mtilde_i p S_k(i) )

whose fixed point is the sought relationship. `F` need not decrease at every step, and that
is why the original implementation carries a backtracking safeguard. The safeguard is
sound; what was wrong with it is documented below.

## Why it converges, and how fast

Linearise around a solution. Put `p = p* exp(xi)` and suppose `m_i` is noise-free, so
`mtilde_i = c_k(p*) = p* S_k^-1 p*^-1`. Then

    v_i = c_k(p*) p* exp(xi) S_k = p* S_k^-1 exp(xi) S_k = p* exp( R_k^T xi )

where `R_k` is the rotation matrix of `S_k`, since conjugation of the exponential is the
adjoint action. Averaging,

    T(p* exp(xi)) = p* exp( A xi ) + O(||xi||^2),      A = sum_k w_k R_k^T

with `w_k` the fraction of the retained observations assigned to variant `k`. So `A` is the
**error propagation matrix of the iteration**, and everything about local convergence follows
from it.

**It never diverges.** `A` is a convex combination of orthogonal matrices, so `||A|| <= 1`.
The iteration is non-expansive whatever the data.

**It stalls only on a degenerate assignment.** `A xi = xi` requires `R_k^T xi = xi` for every
variant with `w_k > 0`, i.e. `xi` a common rotation axis of all populated variants. Two
populated variants with non-parallel axes already give a spectral radius below one. The
degenerate case is real: an assignment concentrated on one variant leaves the component of
the error along its axis untouched.

**Well-spread variants make it converge in essentially one step.** If all `n_p` variants are
equally populated then `A = (1/n_p) sum_{S in G_p} R_S^T = 0` **exactly**, because the
three-dimensional vector representation of the cubic rotation group contains no copy of the
trivial representation — its character sums to `3 + 8(0) + 3(-1) + 6(1) + 6(-1) = 0` over the
group. This is the answer to the question that prompted this document: the iteration works
because a martensitic map populates many variants, and at that point the fixed-point map is
locally a contraction with rate near zero.

**The identity variant is the one thing that spoils this.** `c_1(p) = id` for every `p`, so
observations assigned to it contribute a constant to `F` — they carry no information about
`p` at all — while their votes contribute `w_1 I` to `A`, i.e. pure damping that pushes the
spectral radius toward one, plus a bias. They are exactly the near-identity misorientations,
which are the same-variant neighbours rather than the variant pairs the model is about. The
identity variant is dropped from the candidate set. With it dropped and the remaining
variants evenly populated, `A = -I/(n_p - 1)`, a rate of `1/23` for cubic — still one step for
practical purposes.

Measured on `mtexdata martensite` (`'angle',3*degree,'minPixel',2,'alpha',12`, 24773 c2c
pairs), at the fitted relationship: `|sum_{S in G} R_S| = 2e-15` and `|sum_{S ~= id} R_S| = 1`
exactly as predicted; the variant occupancies run from 1.5 to 12 per cent, giving
`rho(A) = 0.215`; and the undamped iteration converges to machine precision in 13 steps with
an asymptotic error ratio of 0.17 to 0.25 — the predicted rate. The identity variant draws
**zero** observations on this data, because the caller already drops pairs below 5 degree, so
excluding it is insurance rather than a fix here. It matters for any caller that does not
apply that cut.

## What the implementation must get right

**One objective, one sample.** The backtracking test has to compare the same functional the
step targets, evaluated on the same observations. The original compares a mean *geodesic*
angle while the update minimises the *chordal* loss, so a good step can be scored as an
increase; and when the list exceeds 50000 it redraws `discreteSample` inside the loop, so
successive misfits are computed on different data and the comparison is noise. Subsample
once, outside the loop.

**Reset the damping.** In the original, `alpha` only ever grows — `alpha = (alpha + 0.1) * 2`
on rejection, never restored on acceptance — so one bad step leaves the method permanently
over-damped. A backtracking line search resets its step length after an accepted step.

**Anchor the fundamental-region projection.** The chordal mean must project the votes around
the current iterate, not around whichever vote happens to be first in the list; otherwise the
answer depends on the row order of the input. This is what `'q0'` does and what `a15b1ecf2`
fixed. For the same reason the trimming cuts on the residual *value* at the `h`-th order
statistic rather than on rank: ties at the boundary would otherwise resolve by input order.

**Subsampling is where reproducibility still ends.** Above `maxSample` (50000) the fit runs
on a random draw, so two calls on the same list give different answers — measured at up to
0.4 degree with `maxSample` forced to 500. Drawing once instead of once per iteration makes
the *iteration* consistent, but not two separate calls. There is no fix that is both
deterministic and independent of row order, since any deterministic subsample of an unordered
list must read the order; raise `maxSample` when it matters.

**Fixed count, not fixed threshold.** See above: a `p`-dependent number of retained
observations is not an objective.

An upgrade that would restore guaranteed descent is available if wanted: minimise the
majorant `Q(p) = sum_{i in I} (1 - cos angle(mtilde_i, c_k(i)(p)))` — which touches `F` at
`p^t` and dominates it elsewhere — by Gauss-Newton in the tangent space. The linearised
residual is `e_i - (R_k(i)^T - I) xi`, so the step is a 3x3 normal-equation solve whose
matrix `sum_i (R_k - I)(R_k^T - I)` is singular under exactly the degenerate assignment
identified above. With an Armijo condition this gives monotone descent and, as a by-product,
the Hessian.

**The method is local either way, and on real data that decides the answer.** An exhaustive
3 degree scan of the fundamental zone on martensite (2844 points, 129 s) finds a best
relationship at a mean disorientation of **3.15 degree**. Started from Kurdjumov-Sachs — the
guess the documentation and the reconstructor default to — the iteration instead converges to
a different stationary point at **3.34 degree**, **1.44 degree away**. Nishiyama-Wassermann,
Pitsch and Greninger-Trojano all reach the good basin; Bain converges to 4.24 degree, 7.5
degree away. So the starting orientation, not the data, picks the answer, and the most
commonly used starting orientation picks the worse one. Through the reconstructor this is
visible in `calcGBFit`: the quartiles improve from 1.59 / 2.20 / 3.27 degree to
1.41 / 1.96 / 2.62 degree.

This is why `'global'` exists. Before `a15b1ecf2` the row order of the input picked the basin
as well; that is fixed, and the fit now reproduces to 2e-06 degree under permutation. What
remains is a plateau of about 0.09 degree: different starting points inside the *same* basin
stop at points that far apart, because the trimmed objective is flat there at the level of
the trim set changing membership. That is an order of magnitude below the basin gap and is
not worth chasing.

## Reaching the global minimum

The domain is compact, three-dimensional and small, so global search is affordable. Three
methods, in increasing cost and increasing rigour.

**Direct grid search — this is what `'global'` does.** An `equispacedSO3Grid` over the
fundamental zone has about `vol / delta^3` points: 612 at 5 degree, 1237 at 4 degree, 2844 at
3 degree. Scoring one point against a 3000-pair subsample costs 45 ms, so the whole zone is
covered in 30 to 130 s. The scan only has to *rank basins*, which a subsample does perfectly
well; the strongest well-separated candidates are then fitted exactly and compared on the
full data with the same trimmed objective the iteration uses. Measured end to end on
martensite: 63 s at 5 degree, 88 s at 4 degree, both landing on the same optimum.

**Kernel surrogate — tried, and it does not rank.** Building the misorientation density once
and evaluating `sum over k of MDF(c_k(p))` is enormously cheaper: 65412 evaluations over a
3 degree grid in 0.2 s, against 129 s for the exact scan. But the ranking is poor — on
martensite the top-ranked grid point polishes to 4.37 degree while the fourth polishes to
3.15. The reason is structural, not a tuning problem: `sum_k MDF(c_k(p))` is the *linear*
mixture score, so it is dominated by the pairs that fit extremely well, and a relationship
that fits a few pairs superbly outranks one that fits everything decently. The fix is the
logarithm — `sum_i log sum_k psi(m_i, c_k(p))` — which is per-observation and costs the same
as the exact scan, so the surrogate buys nothing. It survives only as a candidate *generator*:
feeding its top 300 grid points to the exact score found the same optimum in 11 s instead of
129 s. Recorded here so nobody re-derives it.

**Lipschitz certificate.** `F` is Lipschitz with an explicit constant. For `p -> p exp(xi)`,

    d(c_k(p exp(xi)), c_k(p)) = ||(R_k^T - I) xi|| + O(||xi||^2) <= 2 sin(theta_k / 2) ||xi||

since the singular values of `R^T - I` for a rotation by `theta` are `0, 2 sin(theta/2),
2 sin(theta/2)`. The disorientation distance is 1-Lipschitz in its argument, `min` over `k`
preserves the constant and so does a trimmed mean, so

    Lip(F) <= L := max_k 2 sin(theta_k / 2) <= 2

attained by the 180 degree variants, and zero for the identity variant — a third confirmation
that it carries nothing. Evaluating `F` on a `delta`-net with best value `F*` therefore
certifies `min F >= F* - L delta / 2`; a 0.25 degree net separates the two martensite
candidates. A Piyavskii-Shubert or DIRECT branch and bound on the three-dimensional box
reaches the same certificate with far fewer evaluations. This proves global optimality and is
the right tool for a one-off validation study, not for every call.

What `calcParent2Child(...,'global')` actually does is the first of the three: scan an
`equispacedSO3Grid` over the fundamental zone at `searchResolution` (4 degree by default),
scoring each point against a 3000-pair subsample; keep the best `numLocal` candidates that
are more than one grid spacing apart, so the same basin is not fitted five times; run the
iteration from each; and pick the winner by **one** functional on **all** observations — the
same trimmed chordal misfit the iteration itself descends. The starting orientation becomes
one more candidate rather than the thing that decides the answer. The Lipschitz certificate
is not run per call; it is the tool for a one-off validation study.

## Alternatives considered

**Soft assignment (EM with a uniform background).** Responsibilities instead of `argmin` over
variants, plus an explicit outlier component in place of the trimming. It removes the
non-differentiability at the Voronoi walls of the variant partition — where a large fraction
of observations sit when the current misfit is 3 to 4 degree — and it subsumes the trimming
rather than replacing it. Note that Jensen alone does not buy monotonicity here: the M-step
inherits the same difficulty as the update above, since `p` appears conjugated inside
`c_k(p)`, so the weighted mean of votes is again a fixed point rather than an exact
maximiser. Monotone EM needs the Gauss-Newton M-step. Deferred as the larger rewrite; it is
the natural next step.

**Truncated loss instead of fixed-count trimming.** Makes the `threshold` option into a real
objective and gives the user a parameter in degrees rather than a fraction. Both are
supported — `quantile` sets the count, `threshold` caps the residual — but the default is the
fixed count, which needs no new constant.

**Better starting orientations.** Explicitly not the answer. Any scheme whose robustness
comes from being handed a good `p2c0` has only moved the problem. Hence `'global'`.

**Making `'global'` the default.** Not yet. It is 20 times slower than a single fit — 88 s
against 4.8 s on martensite — and the honest case for it rests on one dataset. The measurement
above says it changes the answer by 1.44 degree there, which is a strong argument; it should
be repeated on more data before the cost is imposed on every caller.

## By-product worth having

At the optimum, the 3x3 Hessian of the smoothed objective in the tangent space gives a
covariance estimate for the fitted relationship — an uncertainty on `p2c`, which MTEX does
not currently report and which the habit planes computed downstream would benefit from.
