# Separate reference frame from symmetry; let the frame supply the plotting convention

MTEX conflates three concepts that belong apart: the **plotting convention** (how a
frame appears on screen), the **reference frame** (crystal frame, measurement frame,
rolling frame RD/TD/ND, geological frame), and the **symmetry** (the point group data is
invariant under). `crystalSymmetry` is four things in one object: a reference frame
(`axes`, `geometry/@crystalSymmetry/crystalSymmetry.m:96`, plus the `X‖a*, Z‖c`
alignment), a symmetry (`id`/`rot` on `@symmetry`), a screen convention (`how2plot`),
and a phase identity (`mineral`/`color`/`isIndexed` via `phaseItem`). `specimenSymmetry`
is the mirror failure — a frame with no frame: it has `id` and `how2plot` but no `axes`
property at all, so `geometry/@symmetry/ensureCS.m:10-17` reads `.axes` inside a
`try/catch`, and nothing in the toolbox represents "rolling frame" versus "measurement
frame" except a rotation the user tracks by hand.

The cost is paid in a recurring bug family, not in theory. A convention stored on a
shared `symmetry` handle silently repoints the frame of every other object holding that
symmetry; it has been fixed in `grain2d`/`grain3d`, `tensor` and `S2Fun`, and it is
still live today: `geometry/@orientation/map.m:55-56` does `ori.CS =
specimenSymmetry.default; ori.CS.how2plot = ...` and `:63` writes `ori.SS.how2plot`
through the class-default singleton — lines introduced by commit `a20c992ee`, itself a
how2plot fix. Same shape at `PoleFigureAnalysis/@PoleFigure/PoleFigure.m:112`. The
conflation generates bugs faster than point fixes remove them. Around it cluster the
secondary symptoms: `==` has two contradictory meanings (`geometry/@symmetry/eq.m`
compares point-group ids, but `phaseItem` seals `eq` to pure handle identity,
`geometry/phaseItem.m:15-22`, and sealed wins — so `copy(cs) == cs` is false while
`copy(ss) == ss` is true); `EBSDAnalysis/specimenSymmetryFor.m` exists only to
manufacture a *symmetry* because something needs a place to hang a *convention*; frame
changes live on the symmetry (`geometry/@crystalSymmetry/transformationMatrix.m`), so
`ensureCS` must guess whether two crystal symmetries differ by symmetry or merely by
alignment — at 1e-1 on the alignment matrix (`ensureCS.m:23`) against `eqTolPair`'s 5e-2
on the same axes (`phaseItem.m:161`); and `phaseItem/sim` already documents the missing
distinction in prose ("does not require the crystal reference frame alignments to
coincide", `geometry/phaseItem.m:48-52`). The convention is even consumed as frame data,
not screen data: the import wizard computes Euler corrections from `how2plot.rot`
(`interfaces/import_wizard/import_wizard.m:1331`).

The target model is half built already. Most `how2plot` properties are *dependent*,
delegating to a contained `vector3d` (`EBSD`→`pos`, the grain/boundary/triple-point
classes→`allV`, `PoleFigure`→`allR{1}`); only `vector3d`, `symmetry`, `mapPlot` and
`S1Fun` actually store one. `vector3d` is the de facto frame carrier — this decision
names that structure and finishes it, rather than inventing a new one.

## The model

1. **A `referenceFrame` type** carries *identity* (a name: measurement, rolling,
   geological, or a crystal's), *basis*, and the *default plotting convention*.
   `crystalFrame` and `specimenFrame` specialise it.

2. **It is introduced alongside; symmetry delegates.** `crystalSymmetry` and
   `specimenSymmetry` keep their public API and forward `axes`/`how2plot` to a frame
   they hold. Non-breaking, so both concepts become nameable without touching the most
   load-bearing class in MTEX. (MATLAB forbids mixing handle and value superclasses, so
   as long as `crystalSymmetry < symmetry & phaseItem`, `symmetry` — and with it
   `specimenSymmetry`, which has no identity semantics of its own — stays a handle
   class; delegation is unaffected, since a handle class can hold any property.)

3. **The specimen frame names its axes.** RD/TD/ND, geological and measurement frames
   become named instances, so moving between them is an explicit, checkable operation.

4. **Frame membership is a property with per-class cardinality, not a class split.**
   The `rotation`/`orientation` split works only because those are already two classes;
   a `vector3d` or an `S2Fun` legitimately occurs both with and without a frame. One
   optional property, constrained per class (table illustrative, not exhaustive):

   | constraint | classes |
   |---|---|
   | never has a frame | `rotation`, `quaternion` |
   | may have one — empty allowed | `vector3d`, `S2Fun`, `tensor` |
   | must have one | `Miller`, `grain2d` |
   | must have two | `orientation`, `SO3Fun`, `PoleFigure` |

   Precedent: `Miller.CSprivate` can be `[]` in the machinery and the constructor merely
   asserts otherwise (`geometry/@Miller/Miller.m:87`); `vector3d` has no such assert.
   **Empty means "frame-free", never "the default frame"** — that distinction is what
   makes "follows whatever the default becomes" expressible at all. Known rough edges:
   `EBSD` holds one specimen frame (via `pos`) plus a crystal frame per phase in
   `CSList`, which reads as "one" only if per-phase frames are booked under phase
   identity; `S1Fun` stores a convention (`S1Fun/@S1Fun/S1Fun.m:13`) its own `plot.m:38`
   never reads — the resolution is to drop the property, not to manufacture a frame;
   `fibre`, `slipSystem`, `dislocationSystem`, `crystalShape` are unclassified.

   Propagation: frame-free ⊕ framed → the result adopts the frame
   (`geometry/@vector3d/rotate.m:70` already does this ad hoc for the convention); same
   frame ⊕ same frame → fine; different frames → the `ensureCS` path, transform when
   compatible, error otherwise; frame-free results resolve a convention against the
   default at render time, not at construction time.

5. **The frame supplies the *default* convention; a plot call may override it at render
   time.** The override is part of the model, not an escape hatch: a map and a pole
   figure of the same specimen frame may legitimately differ on screen, and the tree
   already works this way (`plotting/mapPlot.m:51` accepts a per-plot convention; the
   regression test of `d676275ab` asserts one shared frame carrying two conventions at
   once). What the decision removes is data classes each storing a convention of their
   own as the primary answer.

6. **Frames, symmetries and conventions remain handle classes, managed by a central
   register, under one rule.** A session holds only a few of these — two to four frames,
   symmetries, conventions — and users treat them as *entities*: "the forsterite phase",
   "the way I plot". Mutation propagating is what the user means (`cs.color = 'red'`
   recolors the phase everywhere), and a survey of every `classdef` shows MTEX already
   splits cleanly into value-semantic data and handle-semantic machinery, with exactly
   three data-side exceptions — `phaseItem`, `symmetry`, `plottingConvention` — which is
   precisely where every leak occurred. The register fixes the exceptions without
   changing their semantics:

   - it *interns* the session's instances: construction and import reuse the registered
     instance instead of proliferating near-copies, and `loadobj` re-interns, closing
     the save/load identity hole (two separately saved datasets currently load as
     different handles for "the same" phase);
   - entities are edited through their register handle — `plotx2east` (which is
     literally `how2plot = plottingConvention.default; how2plot.east = xvector;`) keeps
     working verbatim;
   - **data-level setters store or fork, never write through to a registered
     instance.** Every leak in the family was one *anonymous* instance
     (`specimenSymmetry.default`) serving as both shared entity and scratch pad; named,
     few, register-owned entities make a write-through findable and the rule statable.
   - registered instances stay mutable; a fork-first lock was rejected because it breaks
     `plotx2east`'s current form. Revisit only if the leak family recurs.

   The register generalizes machinery that already exists in embryo:
   `plottingConvention/matchDefault` (`plotting/plottingConvention.m:308`) is a
   one-entry register interning against the anonymous entry "the default";
   `specimenSymmetryFor` becomes a register lookup; and the `how2plotPrivate`
   properties of `d676275ab` are the prototype of "store, don't write through". All
   three are absorbed, not deleted.

## Considered Options

We chose **one optional frame property with per-class cardinality** over separate
classes for framed and unframed data (a `framedVector3d` beside `vector3d`). Doubling
the class count to encode one optional property is worse than the conflation it removes;
the cardinality constraints give the same guarantees.

We chose **introducing the frame alongside, with symmetry delegating,** over stripping
`symmetry` down to the group in one move. The strip is the cleaner end state but breaks
every holder of a symmetry in the same commit; delegation makes both concepts nameable
immediately and leaves the strip available later.

We chose **frame-supplies-default with per-plot override** over the frame owning the
convention outright. Outright ownership would force a tensor plotted off its phase's
frame to carry a private frame instance differing only in convention, re-importing the
`copy(cs) == cs` identity problem one level down.

We chose **handle entities plus a central register** over value semantics for frames and
conventions, which an interim draft recommended. Value semantics makes aliasing bugs
impossible but makes divergence between related datasets the default: `calcGrains(ebsd)`
would snapshot the symmetry, so a later edit to `ebsd.CSList{2}` would silently no
longer reach the grains — which today cannot happen. Since sessions hold only a handful
of entity-like frames, the aliasing-safety is bought instead by the register plus the
never-write-through rule, at the cost of that rule being convention rather than
mechanics.

We chose to **leave the convention on no data class as primary storage** over the
pre-2026 status quo, in which anonymous shared handles plus `matchDefault` did the same
job implicitly and produced the bug family this ADR opens with.

## Consequences

- This ADR changes no code. No `referenceFrame` class exists yet; the `how2plotPrivate`
  properties on `tensor`/`S2Fun` are interim prototypes of the store-don't-write-through
  rule, not the target design.
- `plottingConvention.default` *is* `specimenSymmetry.default.how2plot`
  (`plotting/plottingConvention.m:331-348` routes through the `specimenSymmetry`
  singleton). The prerequisite for any code step is moving both defaults into the
  register, so "the default" is a named entity rather than a property of a singleton
  symmetry.
- Deliberate reliance on shared handles is preserved by design: `specimenSymmetryFor`'s
  same-object guarantee, `matchDefault` (used in import at
  `interfaces/loadEBSD_ang.m:187`), and the documented in-place default workflow
  (`plottingConvention.m:16-17`) keep working verbatim; the register formalizes them.
- `loadobj` inverts its duty: `geometry/@vector3d/vector3d.m:350` and
  `S2Fun/@S2FunHarmonic/S2FunHarmonic.m:144` currently *repair* an empty convention into
  the shared default; under the register they re-intern non-empty frames instead, while
  empty must survive as "frame-free". In an existing `.mat` the two senses of empty are
  indistinguishable, so that migration needs a deliberate answer.
- Interning needs an equality notion at the register door, so the `eqTol` tolerance
  question resurfaces — at one door, instead of scattered through `ensureCS` call sites.
  The register is global state: parallel workers do not share it and tests need a reset.
- `plottingConvention` is a *value* class since 2026-08-14 (commit `3237eb638`); the
  paragraph below records why that had to wait for the register and for data-class
  frame membership, and what carries the coupling now.
  Before those two steps, value semantics would have broken the default-follows
  workflow three ways:
  `plotx2east` mutates the default in place; `matchDefault` and the import loaders alias
  the default handle; and `vector3d`'s class default (`geometry/@vector3d/vector3d.m:48`,
  evaluated once at class init) would freeze the init-time convention into every plain
  `vector3d` for the whole session. Once data classes hold a frame — or empty for
  "follow the default" — the frame is the shared handle *entity* and the convention it
  carries can be a plain value: `plotx2east` then edits the default frame through its
  register handle and every holder of that frame follows, while write-through leaks at
  the convention level become structurally impossible rather than test-guarded (the
  freezing `copy` in `newSphericalPlot` also becomes automatic). This refines the
  Considered Options above: value semantics was rejected for frames and conventions
  *wholesale*; the end state is value conventions inside handle frames.
- ~~Open problem~~ resolved 2026-08-15 by the "orientation without symmetry" section
  below: a plain data object expressed in a *crystal* frame — a `vector3d` or `S2Fun`
  whose frame is a `crystalFrame`, e.g. the deliberately unsymmetrised GBND — becomes
  a `Miller` via `crystalSymmetry(cF)`, the trivial group carrying the frame. Extrema
  and sampling (`S2Fun/min`/`max`, `discreteSample`, `optimalSample`) return such a
  `Miller`: hkl in the right basis, honestly unsymmetrised. The once-considered back
  reference from `crystalFrame` to its point group was not needed.
- The `phaseItem` sealed-`eq` problem is *not* resolved here. Phase identity is a fourth
  concept tangled into `crystalSymmetry`; it is the one data-side handle that is
  legitimately identity-semantic, and it deserves its own decision.

## Orientation without symmetry (2026-08-15)

An orientation is a coordinate transform between two reference frames; the symmetry
groups are optional decoration on top. The CS/SS slots therefore sometimes need to hold
only a frame — the equivariant side of an `SO3TangentVector`'s reference orientation,
the symmetry-free side of a quadrature grid, a function deliberately built
`'noSymmetry'`. **Decided: the symmetry-free state is represented as the trivial group
carrying the frame** — the shape `stripSym` (`geometry/@symmetry/symmetry.m`) already
produces, made first-class. Two rejected alternatives: bare `referenceFrame`s directly
in the CS/SS slots (every reader of `ori.CS` would have to branch or wrap — in MATLAB
the wrapping cost lands on hundreds of read sites instead of one construction site), and
storing frames on `orientation` with groups optional (the clean end state, but it
rewrites the most-threaded property pair in the codebase; everything below is a subset
of it and keeps it reachable).

Three consequences, all implemented on `feature/referenceFrame`:

1. **Absence is empty, never fabricated.** The historical idiom — `extractSym`
   (`tools/option_tools/extractSym.m`) fabricating a session-framed `specimenSymmetry`
   as fallback, consumers testing `id==1` for "nothing given" — conflates a
   *deliberately passed* triclinic symmetry with an absent one, and the fabricated
   sentinel carries the live session frame, which is exactly how results silently swap
   a data frame for the session's. `extractSym(list,'empty')` returns `[]` for absent
   slots; consumers guard with `isempty`, so a passed trivial symmetry survives with
   its frame. A fabricated default remains correct in exactly one place: constructors
   of objects that genuinely have nothing to inherit from (a bare function handle, a
   bare rotation) — there "absent" really does mean "the session default".

2. **Frames convert to trivial symmetries.** `crystalSymmetry(cF)` /
   `specimenSymmetry(sF)` construct the trivial group on a given frame, adopting the
   handle (never copying, never writing to it — it may be shared). This supplies the
   missing half of the crystalFrame→Miller open problem above: the basis was always in
   the frame, only the demand for a group blocked the construction.

3. **A tangent vector's own frame is derived, not stored.** `SO3TangentVector` keeps
   its symmetry pair (`hiddenCS`/`hiddenSS`) — the pair must be stored because both
   groups reappear depending on the representation: one side is an *invariance* of the
   reference orientation (a left tangent vector is identical at `R` and `R*c`, so CS
   stays on `rot`), the other an *equivariance* (the left vector at `s*R` is `s` applied
   to the vector at `R`, so SS cannot reduce the reference without transforming the
   vector — `get.rot` presents it as `stripSym`). But the vector *as a vector* is expressed
   in exactly one frame: the specimen frame for left vectors, the crystal frame for
   right ones. `getFrame` derives it from the corresponding side
   (`geometry/@SO3TangentVector/SO3TangentVector.m`), `setFrame` errors — the `Miller`
   pattern. In the cardinality table `SO3TangentVector` joins `Miller` as "must have
   one, derived from a symmetry it holds".

4. **Compatibility checks compare frames, not groups.** `ensureSym` (the gate of
   `orientation/times`/`mtimes`) routes the `ori*ori` inner check through `fitFrame`:
   aligned crystal frames pass — *also when the point groups differ* — a compatible
   transition is absorbed, and a wrong-sided combination now errors where it used to
   warn; for `ori*Miller` and friends the `fitFrame` gate inside `rotate` decides
   alone, since transforming in both places would transform twice. The
   `rot`-respects-symmetry warnings stay: a bare rotation factor is a genuine group
   question. `ensureCompatibleSymmetries` (SO3Fun arithmetic/conv/eval) decides by
   frame handle first — registered symmetries share their frame handle, and
   `stripSym` stand-ins keep it, so handle identity alone certifies compatibility;
   duplicates not yet interned fall back to aligned frames carrying the same Laue
   class. The Laue comparison survives only in that fallback and where the group is
   the actual subject (`orientation/dot`'s misorientation branches, deliberately
   untouched).
