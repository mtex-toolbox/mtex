# The gbcFMC default parameters, and the measurements they rest on

`gbcFMC` is the one grain boundary criterion in MTEX with a whole cluster of tunable
constants rather than a single threshold — `cmaha`, `cmaha0`, `quatmax`, `alpha`,
`minPixel`, `maxDelta`, `gammaW`, plus `kappa` and the outlier radius band inside
`FMC_Coarsen`. None of them has a value that follows from the algorithm; every one was
picked by sweeping it against the synthetic benchmark (`tests/lib/EBSDGrainBenchmark.m`,
scored by `tests/lib/scoreGrainBenchmark.m`) and against a few real maps. The numbers
below are what those sweeps produced. They lived in the source as comment blocks until
`96115a5f7` reduced every comment to one line; they are recorded here so the reasoning
survives without a parameter table sitting on top of a one-line property default.

Reproduce any of them with `check_grainBenchmark` / `check_grainReconstructionBenchmark`
(the `slow` tier), at the stated `gbcFMC` settings. "ARI" is the adjusted Rand index
against the generator's ground truth partition; "minDetected" is the smallest boundary
misorientation, in degree, the reconstruction still resolves.

## What the parameters are

**`cmaha = 3`** — Mahalanobis sharpness of the coarse level rebias. In
`part7BiasWeights` the coupling between two aggregates is multiplied by
`exp(-cmaha*(|misorientation| - sqrt(Qvar))/sqrt(Qvar))`, so misorientations within one
standard deviation of the aggregates' internal spread are left essentially untouched and
larger ones are suppressed. Larger `cmaha` means stricter separation and more boundaries.

**`cmaha0 = 0.05`** — decay constant of the *initial* edge weight,
`w = exp(-cmaha0*delta)` with `delta` the neighbour misorientation in degree. Used at the
finest level only, where no variance estimate exists yet, so it is one of the two places a
fixed angular scale enters the algorithm at all: 0.05 per degree puts the weight at 1/e at
20 degree.

**`alpha = 0.2`** — seed selection aggressiveness in `part1CoarseSeeds`. A node becomes a
coarse seed unless its accumulated weight to the seeds already chosen reaches `alpha`
times its total weight to all neighbours. Larger `alpha` makes it harder to be represented
by existing seeds, so more seeds are created and the hierarchy coarsens more slowly.

**`quatmax = 5`** — *ceiling* on the outlier radius, in degree, not the radius itself. A
fine node is folded into an aggregate's statistics only if it lies within that aggregate's
outlier radius of its mean; otherwise its interpolation weight is zeroed, which is what
keeps a misindexed pixel out of `Qvar` and hence out of the rebias. `quatmax` also sets
the floor, at 0.4 of itself, so widening it widens the whole band the adaptive radius
lives in.

**`minPixel = 1`** — smallest region FMC leaves standing; smaller ones are eaten from the
rim inwards by whichever full sized neighbour touches them, in `FMC_interpret`. Single
pixel regions are always absorbed, so 1 and 2 mean the same thing. Note this **absorbs**
where `calcGrains`' own `minPixel` **deletes** — that one runs an extra segmentation pass
and marks undersized pixels notIndexed, throwing their orientations away. Because
`gbcFMC` answers true to `handlesMinPixel`, `calcGrains` skips that pass and hands the
value here instead, so

```matlab
calcGrains(ebsd,'fmc',3.8,'minPixel',5)
calcGrains(ebsd,gbcFMC(3.8),'minPixel',5)
calcGrains(ebsd,gbcFMC(3.8,'minPixel',5))
```

all mean the same thing and all run the clustering exactly once.

## `gammaW = 10`, lowered from 25

Inverse edge dilution strength, in `part0EdgeDilution`: an edge is deleted when its weight
falls below the node's mean neighbour weight divided by `gammaW`, at *both* endpoints.
Note the direction — a **larger** `gammaW` lowers that threshold and therefore dilutes
**less**.

At 25 the threshold sat at about 0.04 of a typical intra-grain weight, while a 60 degree
twin boundary carries `exp(-0.05*60) = 0.0498`, just above it. Twins therefore survived
dilution and aggregates coarsened straight through them, which is how a single grain came
to contain 60 degree internal steps. Measured over five benchmark realisations per level:

| | `gammaW` 25 | 10 | 5 |
| --- | --- | --- | --- |
| benchmark level 1 (ARI) | 0.9923 | 0.9922 | 0.9799 |
| benchmark level 2 (ARI) | 0.9761 | 0.9916 | 0.9873 |
| benchmark level 3 (ARI) | 0.9449 | 0.9559 | 0.9715 |
| level 1 / 2 minDetected | 1.0 / 1.6 | 1.0 / 1.0 | 1.6 / 1.2 |
| ebsd2 unsplit boundary lines | 12 | 10 | 6 |
| forsterite grains | 2102 | 2372 | 2814 |

10 beats 25 on every level at once and detects the 1 degree boundaries on level 2 that 25
missed. 5 splits more twins still, but starts losing the 1 degree boundaries on level 1 —
which is the capability this criterion exists for. Use 5 when twins matter more than low
angle boundaries. Changed 2026-07-25.

## `maxDelta = inf`, i.e. off by default

Hard ceiling on the misorientation an edge may carry, in degree. Above it the coupling is
set to zero rather than merely reduced, so the neighbourhood graph is disconnected there
and no aggregate can span it. This is the only construct in the algorithm that a boundary
cannot survive, and the other place a fixed angular scale would enter — which is why it is
off unless asked for.

What it is for is twins: `exp(-cmaha0*60) = 0.0498` is a small coupling but not a zero
one, and on `ebsd2` that was enough for aggregates to coarsen through Sigma3 twin
boundaries. Measured on `ebsd2` (`'A1'`, `minPixel` 1, `cmaha` 0.25), against benchmark
level 2 over five realisations:

| | `maxDelta` Inf | 30 | 20 | 15 | 10 |
| --- | --- | --- | --- | --- | --- |
| internal steps > 10 deg | 166 | 145 | 94 | 98 | 126 |
| of those > 40 deg | 83 | 68 | 41 | 44 | 62 |
| unsplit boundary lines | 10 | 11 | 5 | 6 | 10 |
| benchmark L2 (ARI) | 0.9916 | 0.9863 | 0.9854 | 0.9866 | 0.9867 |
| benchmark L2 minDetected | 1.0 | 1.2 | 1.4 | 1.2 | 1.2 |

It is **not** monotone — 10 is no better than no ceiling at all — because a tighter
ceiling strands more pixels, which then have to be adopted somewhere. 15 to 20 degree, the
usual high angle boundary convention, measures best.

The cost is on the low angle boundaries, which is what this criterion exists to find:
level 2 stops detecting all the 1 degree boundaries. Real maps gain grains too — forsterite
2372 → 2464, EMSphinx 2211 → 2410 (that pair measured with all phases in one graph, i.e.
before `doEvaluate` split them). Worth it on twinned material, not in general, hence the
default.

Of what remains at 15 degree, most is not a failure: for 5 of the 9 affected grains,
cutting *every* edge above 15 degree inside them still leaves one connected piece, because
the sharp boundary does not fully cross the grain and the two sides join around its end.
No segmentation can split those.

## `kappa = 4` and the adaptive outlier radius

In `FMC_Coarsen` the outlier radius of an aggregate is `kappa` standard deviations of its
own spread, held inside the band `[0.4*quatmax, quatmax]`. A hard radius would put a fixed
angular scale back into an algorithm whose point is not to have one; letting the radius
follow the spread all the way down is worse still. So `quatmax` sets the band and the
spread picks the value inside it.

The floor is load-bearing. The radius exists to keep *misindexed* pixels out of the
statistics, and those are tens of degrees away — it must never become so tight that
ordinary intra-grain variation is thrown out with them. Tying it to the measured noise
alone does exactly that on clean data: on `data/EBSD/EMSphinx.h5` the noise is 0.11 degree,
the radius collapsed to 0.75 degree, and the map shattered into 11846 grains where a
5 degree radius gives 1563. The floor costs nothing on the synthetic benchmark, whose noise
is high enough that it never binds:

| floor | 1 deg | 2 deg | 3 deg | 5 deg |
| --- | --- | --- | --- | --- |
| EMSphinx grains | 3281 | 2136 | 1882 | 1563 |
| benchmark level 1 (ARI) | 0.9887 | 0.9887 | 0.9889 | 0.9667 |

The EMSphinx column was measured with all three phases in one graph, i.e. before
`doEvaluate` started clustering each phase on its own; the numbers shifted with that
(1563 → 1293 at the 5 degree floor), the ordering did not.

`kappa = 4` was measured over five benchmark realisations per level, where it beat 3, 6 and
a fixed 5 degree radius (0.9875 ± 0.0013 on level 1, against 0.969 ± 0.017 for the fixed
radius). Note that the benchmark's level 3 carries a 5 degree gradient — exactly the old
`quatmax` — so part of what the adaptive radius fixed there was that coincidence. The floor
is what keeps it honest on data the benchmark does not resemble.

## Considered Options

We chose to **derive the angular scales from the data** wherever possible rather than fix
them: the outlier radius from each aggregate's own spread, the noise `sigma` from the
neighbour misorientations (`FMC_MTEX`, median of `|del|^2` against
`2*2.366*sigma^2`, the median so that boundary pairs and misindexed pixels stay out of the
estimate). `cmaha0` and `maxDelta` are the two deliberate exceptions, and `maxDelta` is off
by default for that reason.

We rejected **deriving `cmaha0` from the measured noise** — a decay length of so many
sigma. It splits twins on `ebsd2` (12 unsplit boundary lines down to 6) but costs the
benchmark (level 3, 0.945 → 0.914), because a short decay makes the weights inside a grain
vary and the low angle boundaries harder to see. Diluting harder, i.e. `gammaW`, buys the
same thing for free.

We rejected **a fixed outlier radius**, both because it reintroduces a fixed angular scale
and because it left the result on a knife edge — see the EMSphinx row above.

## Consequences

- The defaults are tuned for the capability this criterion exists for: detecting low angle
  boundaries down to about 1 degree. Twinned material is the known trade-off, and is served
  by `maxDelta` 15..20 and `gammaW` 5 rather than by a change of default.
- The benchmark is the arbiter for any future change to these numbers, and it has three
  levels for a reason — several of the parameters above are non-monotone, or improve one
  level while costing another. A sweep on one level is not evidence.
- These measurements pre-date `doEvaluate` clustering each phase separately. Absolute grain
  counts on multi-phase maps (EMSphinx, forsterite) have shifted since; the orderings held.
- `verbose` stays off by default: `calcGrains` is silent for every other criterion, and a
  criterion that narrates itself is unusable inside a parameter sweep or the benchmark.
