# grainSegmenter — open work

Working notes, 2026-07-25. Nothing here is started unless marked otherwise.

## Background: why real data fragments

Measured on the steel1C_1 window (400x400 of `~/mtex/data/1C_1.ctf`, Fe-BCC,
Fe-FCC masked). To avoid circularity the test used *conventional* grains —
`calcGrains` at 10 deg on the raw window, restricted to the 71 grains with
>= 300 px — not the segmenter's own partition.

| quantity | value | in sigma |
|---|---|---|
| sigma, from second differences | 0.329 deg | 1 |
| best CONSTANT fit residual | 1.591 deg | 4.84 |
| best LINEAR fit residual | 1.375 deg | 4.18 |
| same, best 90 % of pixels | 1.084 deg | 3.30 |

The linear term removes only **13 %** of the constant-model SSE, and the
leftover residual has whiteness 0.15 (neighbour correlation ~0.85) — a smooth
spatially correlated field, not noise.

Variogram of the median misorientation inside those grains:

```
 1 px 0.694 | 2 px 0.975 | 4 px 1.399 | 8 px 1.922 | 16 px 2.306 | 24 px 2.403 deg
```

so roughly `0.694 * d^0.35` deg, saturating near 2.4 deg. White noise of sigma
would give a flat 0.465 deg at every lag.

**Conclusion.** It is the ERROR model, not the mean model. `SSE/(2 sigma^2)`
prices everything as i.i.d. noise of 0.329 deg, so a region stays cheap only
while its internal spread is about sigma — and the field passes sigma at 1 px.
Regions stall at the correlation length of the substructure; the observed
median of 6 px is exactly where the variogram reads ~1.7 deg.

Consequence: real curvature (2.4 deg) **exceeds** the 1 deg boundaries the
segmenter resolves on synthetic data, so interior statistics alone cannot
separate a low-angle boundary from curvature on this map.

---

## 1. Open question for Ralf — not work, a decision

On a martensitic map where real intra-grain curvature reaches 2.4 deg, what
counts as a grain?

- sub-2 deg boundaries must still be found → only option B (or E) can
- anything below ~3 deg is one grain → option A suffices and is far cheaper

This selects between the options below.

## 2. Option A — scale-aware noise floor sigma^2(R)

Replace the fixed `sigma^2` in
`L = SSE/(2 sigma^2) + k*log(maxAngle/sigma) + (k/2)*log(n)`
with a `sigma^2(R)` growing with region size along the measured variogram law.

Cheap: region diameter is already free from the existing moment sums
(radius of gyration `sqrt((Kxx+Kyy)/n)`), so merges stay O(1).

**Confidence lowered** after option C was refuted — C inflated the same
denominator by a constant and both failed to fix fragmentation and collapsed
synthetic L2 from ARI 0.99 to 0.60. A is not refuted by that (under A small
regions keep the sharp sigma and hence the merge ranking, only large regions
get slack), but it is this task's burden to show that, not to assume it.

Three problems to solve first:

1. **merge-ordering collapse** — the failure that killed C. Test on synthetic
   L1–L3 first; if ARI drops there, stop.
2. **positive feedback** — bigger region → more tolerance → merges more →
   bigger. Bounded only by variogram saturation; needs an explicit cap and a
   runaway check.
3. at saturation it merges across any boundary below ~2.4 deg. Acceptable only
   if the decision in §1 goes that way.

## 3. Option B — boundary as discontinuity, variogram as null

Reformulate from "does the interior fit a model" to "is the jump across this
interface bigger than the field's own increment at that separation, **and**
coherent along the interface".

Intra-grain curvature produces increments that are locally random in
direction; a real boundary produces one shared misorientation along the whole
interface. That coherence is the only signal that still separates a 1 deg
boundary from 2.4 deg of curvature, so this is the only option that survives
the information limit.

MDL form is natural: 3 parameters for one misorientation shared by a whole
boundary, versus explaining each segment by the continuous field.

Prerequisite: ordered boundary contours — the same prerequisite as the
chain-code morphology term and the grainBoundary segment-ordering idea.
Consider doing those together.

## 4. Option C — constant slack tau — **TESTED AND REFUTED 2026-07-25**

Clean decoupled sweep: sigma inflated by `k` only where it normalises the SSE,
`regionCost` and `outlierCost` restored to their `k = 1` values. (The earlier
sweep recorded in memory as "sigma underestimation ruled out" was confounded —
both cost constants derive from sigma in the constructor.)

steel window, outlier cap allowed to grow with the slack:

```
      k   regions   median px   p90 px   blanked
    1.0      9265           6       29    11.47 %
    2.0      7041           6       40     5.48 %
    4.0      6223           5       42     3.86 %
```

steel window, cap held fixed (`outlierCost` scaled by `1/k^2`):

```
    2.0      2933          11      111    19.39 %
    4.0      1592           1      237     9.88 %
```

synthetic, cap grows:

```
      k      L2 regions / ARI      L3 regions / ARI
    1.0        32 / 0.9905           33 / 0.9826
    2.0       234 / 0.8699           34 / 0.9506
    4.0       841 / 0.6040         1126 / 0.7739
```

1. **Does not fix the fragmentation.** 16x more variance tolerance moves the
   median region from 6 px to 5 px. Mean size does grow (13 → 19 px), so large
   regions grow while small ones stay stuck — growth is asymmetric.
2. **Actively destroys what worked.** Note the direction: MORE tolerance gives
   MORE regions. `SSE/(2 sigma^2)` is not merely a threshold, it is what
   *ranks* candidate merges. Flattening it makes early merges near-arbitrary,
   and Boruvka's irreversibility locks the mistakes in. The "cap fixed"
   variant is worse: at k = 4, median 1 px with p90 237 px — a few huge
   regions plus a field of singletons.

Script: `$CLAUDE_JOB_DIR/tmp/slackSweep.m` (scratch, not in the repo).

## 5. Option D — higher-order mean model — **not recommended**

Recorded so it is not re-proposed from scratch. The linear term removes only
13 % of the constant-model SSE, and the residual has whiteness 0.15. The field
is a spatially correlated random field, not a polynomial trend, so higher
order terms should buy even less than the linear one did.

Revisit only if a measurement contradicts the 13 % figure.

## 6. EBSDGrainBenchmark blind spot — correlated-field grains

Not one of the options, but none of them can be *judged* without it.

`EBSDGrainBenchmark` generates grains that are exactly constant or exactly
linear plus exactly i.i.d. noise — the same model `grainSegmenter` assumes. It
is therefore incapable of detecting model misspecification by construction,
which is why it scores ARI 0.99 while real data fragments to a median region
of 6 px. The 0.99 validates the optimiser, not the model.

Add a generator mode superimposing a spatially correlated orientation field on
each grain, matched to the measured variogram (`~0.694 * d^0.35` deg,
saturating ~2.4 deg at lag ~24 px, on a 0.15 um step). Then re-lock baselines
in `check_grainBenchmark` and use the new level to judge A/B/E.

## 7. Option E — adopt FMC's two structural ideas

Found while documenting `EBSDAnalysis/grainBoundaryCriteria/gbcFMC.m`. FMC
already solves, in a different form, both problems that killed option C and
threaten option A.

1. **Scale-free coupling.** `FMC_Coarsen/part7BiasWeights` rescales the
   coupling between two aggregates by
   `exp(-cmaha*(|misorientation| - sqrt(Qvar))/sqrt(Qvar))`, where `Qvar` is
   each aggregate's *own* accumulated orientation variance. There is no
   threshold angle anywhere in the algorithm. This is option A's scale-aware
   tolerance, except the scale is measured per aggregate from the data rather
   than predicted from a fitted variogram law — strictly better: no exponent
   to fit, and it adapts to locally varying substructure.
2. **Deferred, reversible decisions.** Coarsening never commits a merge.
   `FMC_interpret` sorts every aggregate at every scale by saliency (external
   coupling / internal coupling) and assigns pixels to the most salient
   aggregate whose interpolated membership reaches `beta`. A bad aggregation
   at one scale can be overruled by a better one at another — exactly what
   `grainSegmenter`'s greedy Boruvka mutual-best merging cannot do.

Work: benchmark FMC on the steel1C_1 window and the synthetic levels against
`grainSegmenter`, then decide whether to (a) port saliency-ranked hierarchy
cutting into `grainSegmenter` in place of irreversible merging, (b) keep MDL
but defer the cut, or (c) improve FMC itself and use it.

Caveat before benchmarking: FMC's aggregate statistics carry no positions, so
a smoothly deformed grain and a noisy one with the same spread are
indistinguishable to it — it will likely have its own trouble with the 2.4 deg
curvature. `grainSegmenter`'s linear model is the better half there. The two
look complementary rather than competing. (This is reasoning from the source;
FMC has *not* been benchmarked on this map.)

Smaller FMC defects are listed in the "Possible improvements" block now
inlined in `gbcFMC.m`; the most substantive is that `part6InterpWeights`
accumulates aggregate mean and variance with a sequential online update inside
an explicit loop, which is both the runtime bottleneck and a source of
order-dependence in the result.
