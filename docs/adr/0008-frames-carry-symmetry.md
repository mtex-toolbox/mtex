# A frame may carry a symmetry; objects carry frames

**Status: decided in discussion 2026-08-27/28, not implemented.** ADR 0003's increments
already built the carrier: `geometry/@referenceFrame` exists with `@crystalFrame`,
`@specimenFrame` and `@gridLayout` specialising it, and `vector3d` stores a `framePrivate`.
What no code follows is the *ownership* — the point group still lives on `crystalSymmetry`,
and `phaseItem` is still a root beside the frames. This records the model so that the
increments can be cut against it, and so that nothing is built in the meantime on the
ownership it reverses.

Names given with a file path exist today; everything else is proposed. Counts are of the
live tree, excluding `worktrees/`, `obsolete/`, `old/`, `compatibility/` and `extern/`.

ADR 0003 separated the plotting convention, the reference frame and the symmetry as
*concepts*, but left the symmetry as the *carrier*: a frame reaches the rest of the
toolbox by being held inside a `crystalSymmetry` or a `specimenSymmetry`. Its
"Orientation without symmetry" section names the end state — "storing frames on
`orientation` with groups optional (the clean end state, but it rewrites the most-threaded
property pair in the codebase)" — rejects it as too expensive for that increment, and
adopts instead "the trivial group carrying the frame".

That device is the fake symmetry. `crystalSymmetry(cF)` and `specimenSymmetry(sF)` exist
for no other purpose than to manufacture a group so that a frame has somewhere to live. An
elastic tensor averaged over an ODF carries a triclinic `specimenSymmetry` only to record
that it is in sample coordinates; a deliberately unsymmetrised `S2Fun` carries one for the
same reason; `S2FunHarmonicSym` is a separate class from `S2FunHarmonic` because symmetry
is a property of the wrong object. This ADR takes the step 0003 deferred.

## The model

**1. A frame carries an optional point group; an object carries frames.** `referenceFrame`
becomes abstract and `matlab.mixin.Heterogeneous` — it is `matlab.mixin.Copyable` today — so
that a phase list is a frame array rather than a cell array. Three concrete frames carry a
phase:

| | carries |
| --- | --- |
| `referenceFrame` | name, colour, plotting convention, optional point group, `axes` |
| `crystalFrame` | + cell, alignment, index conventions; `mineral` aliases `name` |
| `specimenFrame` | + named axes — RD/TD/ND, measurement X/Y/Z, geographic |
| `notIndexedFrame` | + nothing |

Name and colour sit on the base because `notIndexedFrame` has both. Nothing outside a frame
holds a group. The cardinality table of ADR 0003 stands, with `Miller` removed from it
(see 6).

This is `phaseItem`'s shape, grown a basis and a group. `geometry/phaseItem.m` is already
`handle & matlab.mixin.Heterogeneous`, already holds `mineral`, `color` and `isIndexed`,
already seals `eq` to `eq@handle`, and already declares `notIndexed` its
`getDefaultScalarElement` — built so that "the CSList of a `phaseList` may hold both". So
`referenceFrame` is not new machinery: `phaseItem` is absorbed into it and `notIndexed` is
re-parented as `notIndexedFrame`. That also answers the note ADR 0003 closes on — phase
identity is not a fourth concept tangled into `crystalSymmetry`, it is the root of the frame
hierarchy. `isIndexed` becomes dependent on the class instead of a stored flag that can
disagree with it.

Dropping `Miller` moves the crystal/specimen distinction down a level rather than removing
it: `vector3d` branches on `isa(frame,'crystalFrame')` for index display, `symmetrise` and
`dspacing`. ADR 0003 already established that kind has to be a class rather than a computed
test — a symmetry built without lattice parameters has the canonical basis, so comparing
alignments alone accepts a crystal/specimen pair.

`axes` is total on the base, returning the canonical triad for the two non-crystal frames.
A frame that answers `.axes` with an error or an absent property is the defect ADR 0003
opens with: `specimenSymmetry` as "a frame with no frame", read through a `try/catch` in
`ensureCS`.

**`gridLayout` leaves the hierarchy and holds a frame instead.** A layout is a property of a
grid *with respect to* a frame: which of the frame's basis directions the first array index
advances along, which the second, and with what sign. That is a relation between array
indices and a basis, not a basis — `geometry/@gridLayout/gridLayout.m` says so in its own
help — and it carries no name, colour, group or plotting convention, so specialising the
phase-identity root would put the one non-phase in the phase hierarchy. Naming the frame and
a signed choice of two of its axes is also what makes explicit the signed permutation that
`geometry/@gridLayout/layoutIndex.m` already applies between two layouts.

**`notIndexedFrame` is not the empty frame.** Empty is the joker of rule 7 and unifies with
anything; `notIndexed` unifies with nothing, not being a crystal at all. Keeping it a frame
rather than `[]` also keeps phase identity uniformly on frames, so the mineral name stays in
the register key of rule 2 with no second home for names. It is the natural
`getDefaultScalarElement` for the root — the default frame is no frame.

**A specimen frame needs no provenance and must not be given any.** It has almost nothing
to differ on, so two imports produce identical keys, the register unifies them, and
`[ebsd1, ebsd2]` keeps working — the fragmentation that the crystal side risks does not
arise here, because lattice parameters come from file headers and axis names do not.
Stamping a filename or dataset id onto a specimen frame would split every import. A user
whose two samples are mounted differently says so by naming a frame, and that naming is the
signal. Named instances — `specimenFrame.measurement`, `.rolling`, `.geographic` — make the
measurement-to-rolling relationship an ordinary `orientation` between two specimen frames,
which today is a rotation the user tracks by hand and the toolbox cannot represent at all.

**2. Frame identity is provenance, fixed by interning at construction.** Frames stay
handle classes managed by the register of ADR 0003, and `==` is handle identity. The
register unifies two constructions only on an exact key match — cell, alignment, point
group, mineral name, plotting convention — with a tolerance on the cell drawn from
`mtex_settings`. Anything else differs, and two frames result. **Within one source there is
no unification at all:** a file that lists two phases has two phases whatever their names
and lattices, so the importer must be able to bypass the register lookup. Ferrite and
martensite are two frames that happen to share a cell, not one frame seen twice.

Frames drop `matlab.mixin.Copyable`. A copy is a handle-distinct twin outside the register,
so `==` would call it a different frame while every number in it agrees — the one way to
manufacture the fragmentation rule 2 exists to control. A variant is obtained by
constructing it and letting the register answer.

The tolerance compares the *shape* of the cell — axial ratios and angles — not its size.
Uniform scaling of `a,b,c` scales every reciprocal vector by the inverse and moves no
crystallographic direction, so a literature lattice constant of 2.87 against a measured
2.866 is a shape deviation of zero.

**3. Frames are immutable except for mineral name and colour.** This revisits 0003's
"registered instances stay mutable": with crystal frames interned as well, an in-place
write reaches every dataset sharing the frame, which is the leak family 0003 opens with,
one level up. Name and colour stay mutable because nothing numeric depends on them.

**4. There is no basis class. Relating two frames is itself an orientation.** A new
constructor, `orientation.align(cFa,cFb)`, gives the map whose rotation is the identity —
the two frames taken to coincide — and a parent-to-child relationship is the same object with
a real rotation in it. Relabelling two datasets, a change of alignment and a
Kurdjumov–Sachs relationship are one type with different contents.

**5. `rotation` stays frameless, `orientation < rotation` stays, and `CS`/`SS` become
dependent.** A rotation is an operation within a frame and a point group is a finite
subgroup of a frame's rotations, but the elements of that set need no back-pointer to it: a
nullable frame on `rotation` would check only the code that was already careful, and would
force a concatenation rule on the hottest class in `geometry/` for no return. The two
frames are stored under directional names; `CS` and `SS` are dependent properties resolving
**positionally** to source and target. That is what they already mean — `inv(ori)` swaps
them, so `inv(ori).CS` holds a specimen symmetry today — and resolving them by *type*
instead would answer differently for a misorientation, where both sides are crystal frames.

**6. `vector3d` carries an optional frame, and `Miller` is dropped as a class.** After the
flip `Miller` adds exactly one field over a framed `vector3d`, and it is one that already
exists as an enumeration: `dispStyle`, of type `MillerConvention`
(`geometry/MillerConvention.m`), whose sign selects the reciprocal or direct basis, whose
magnitude selects three or four indices, and whose `xyz` member is the no-index-basis state
a frameless vector needs. It moves to `vector3d` unchanged. `Miller(h,k,l,cf)` survives as
a constructor function returning a framed `vector3d`.

The cost of the class is paid on every operation that *preserves* Miller-ness — indexing,
`symmetrise`, arithmetic — each of which reruns a subclass constructor on top of the
`vector3d` one and pays subclass dispatch in between. Most of the 25 methods in
`geometry/@Miller/` are overrides that exist to handle the `CS`; with the group reachable
from the frame they have nothing left to add and evaporate rather than migrate.

**7. One join rule, for every class.**

| operands | result frame |
| --- | --- |
| same frame | that frame |
| one side empty | the other |
| siblings — identical but for the point group | the sibling carrying the **intersection** of the groups |
| otherwise | error |

Empty means frame-free and unifies with anything, as in ADR 0003; it resolves against the
default only at render time, where there is no partner to unify with. The joker is not
transitive, so an *array* holds one frame: `[v_A; v_B]` is an error and `[v_A; v_∅]` is
`v_A`. The sibling rule is scoped to frames differing **only** in the group — a frame, its
group-stripped twin, its Laue variant — and deliberately not to "same cell", which would
merge ferrite and martensite.

**8. `transformReferenceFrame` takes a rule as well as a target.** The verb already exists
on `tensor`, `orientation`, `Miller`, `SO3Fun` and the EBSD map classes; what it gains is an
explicit statement of *what is preserved*, because the candidates give different answers
whenever two frames differ in alignment: the picture (`byScreenAlignment`), the
crystallographic direction (`byAxes`), or the components. That is the active/passive
distinction, named at the call site instead of inferred. The rule may also be an explicit
`orientation`, in which case the side it acts on is read off its own frames — a transform
into the source composes on the right, one out of the target on the left. When both stored
frames are the same frame, the default is conjugation, which is the only choice that
preserves the object's kind. A `tolerance` option authorises a transform between frames of
differing shape; it changes no number, it records how much crystallographic infidelity was
accepted, and it defaults to zero.

**9. A group on a frame is metadata for vectors and orientations, and a contract for
functions and tensors.** A direction in a cubic frame need not be cubic-symmetric; a
function whose frame carries a group asserts invariance under it. The pullback of a
specimen-frame function along a single orientation is genuinely not invariant under the
crystal's point group, so an operation that lands in a group-carrying frame would have to
average silently — a different function, chosen by metadata. Instead **such results land in
the group-stripped sibling frame, and `symmetrise` puts the group back explicitly**.
`symmetrise` is then a special case of `transformReferenceFrame` to a frame with a larger
group: free in the shrinking direction, a lossy projection in the growing one, which is
also the rule for a tensor supplied with the Laue group against data carrying the full one.
Metadata governs what is stored: nothing projects a direction's components onto anything.
Whether two of them count as the same is rule 10.

**10. Comparison respects the group; representation does not.** `dot`, `angle`, `eq` and
what is built on them — `unique`, `ismember`, `find` — reduce over the crystal group of
whichever operand carries one, so `Miller(1,0,0,cs) == Miller(0,1,0,cs)` holds for cubic and
`angle(ori1,ori2)` is the misorientation angle. Components stay exactly as constructed, and
`noSymmetry` remains the opt-out at the call site. An operand carries a group so that
comparisons use it; a vector and an orientation answer the same way.

**A specimen frame's group stays out of vector comparison.** It says something about a
function on the sphere or on SO(3), not about a direction: two vectors in an orthorhombic
specimen frame are equal when their components are, and `v == -v` stays false under a
two-fold sample axis. Specimen symmetry reaches comparison only through `orientation`, whose
reduction runs over both frames' groups already (`geometry/@orientation/dot.m`).

**11. The bracket says whether the group is there.** `MillerConvention.brackets` returns
`(hkl)` for the reciprocal forms and `[uvw]` for the direct ones; a frame carrying a group
selects the family pair the literature uses for this same distinction, `{hkl}` and `<uvw>`,
with `{hkil}` and `<UVTW>` following from the sign. The enumeration does not grow — the bracket
is a function of the convention and of whether the frame has a group — so the group-stripped
sibling of rule 7 prints as `(111)` where its parent prints `{111}`, and the reduction that
`==` and `angle` perform is legible in the output. Concatenation reads in the same notation:
the two are siblings differing only in the group, so rule 7 hands back their intersection
and `[{111}; (111)]` is two `(111)`. The family reading is dropped, and the printed form
says so.

**12. What the three motivating classes get.** `tensor` keeps one frame and loses the
triclinic placeholder for sample coordinates; its own invariance group becomes derivable
rather than conflated with the crystal's, which is what an even-rank tensor's forced
centrosymmetry needs. `S2Fun` carries one frame like `vector3d`, so `S2FunHarmonicSym`
stops being a class and a kernel is honestly frame-free rather than an exception. `SO3Fun`
carries two like `orientation`, so an MDF is a function between two crystal frames without
the `SS`-holds-a-crystal-symmetry misnomer, and the pole figure and inverse pole figure
transforms become one contraction whose result frame follows from the argument's.

**13. `EBSD` carries one specimen frame and one crystal frame per phase.** The specimen
frame rides on `pos`, which is a framed `vector3d`, so `ebsd.SS` is a dependent read of
`ebsd.pos.frame`; the crystal frames are the `CSList` entries indexed by `phaseId`. That is
the reading ADR 0003 says holds "only if per-phase frames are booked under phase identity",
which is exactly what the frame root now is. `CSList` **keeps its name** despite holding
frames: with `phaseId` and `phaseMap` it is 1305 references over 922 lines, and a rename
buys nothing the type does not already say.

## Considered Options

We chose **reversing the ownership** over making the group nullable inside
`crystalSymmetry` and renaming it. The cheap version removes the fake symmetries too, but
it cannot separate a tensor's invariance group from its crystal's, which is the case that
motivated the change.

We chose **frameless rotations** over an optional frame on `rotation`. An optional frame
is permissive where it is absent, so it validates the careful code and misses the rest,
while imposing a concatenation rule and a field on the class every other class is built
from.

We chose **keeping `orientation < rotation`** over making them siblings over `quaternion`.
The honest typing — orientations compose partially, rotations totally — is enforced in the
operators either way, and the sibling split re-homes every inherited method and every
`isa(x,'rotation')` for a distinction the operators already make.

We chose **no basis class** over interning a cell-plus-alignment level beneath the frame.
The basis level makes ferrite and martensite interoperate for free, which is the silent
merge this model exists to prevent; and once relating two frames is an orientation, the
basis has nothing left to express.

We chose **splitting when unsure** over unifying on a lattice match. The two errors are not
symmetric: a false merge of ferrite and martensite is invisible in the phase map and
corrupts everything downstream, while a false split surfaces at the first attempt to
combine and costs one explicit line.

We chose **comparison reducing over the group** over naming it at the call site —
`dot(v1,v2,v1.sym)`, with `dot(v1,v2)` the plain inner product. The explicit form reads well
for a direction, where both answers are meaningful and `noSymmetry` is passed at some 100
call sites to get the plain one. It has no counterpart for an orientation, whose reduction
runs over a *pair* of groups switched independently by `noSym1`/`noSym2` and, across phases,
over a product set belonging to neither operand (`geometry/@orientation/dot.m`) — there is no
single group to hand over. Splitting `dot(v1,v2)` from `angle(ori1,ori2)` for a uniformity
only the vector side can have costs more than the ambiguity it removes.

We chose **stripping the group and requiring `symmetrise`** over symmetrising implicitly
whenever the target frame carries a group. The implicit form makes one expression mean two
mathematically different things depending on frame metadata.

We chose **the intersection rule** over erroring on any group mismatch. The invariance of a
sum is the intersection of the invariances — a theorem, not a heuristic — so refusing it
would be declining arithmetic that is provably correct.

We chose **a heterogeneous frame array** over a cell array for the phase list. Measured on
R2024b: a method dispatches across such an array only if it is `Sealed` on the root, and
`eq` does not come free — inherited unmodified from `handle` it still fails, because
`handle.eq` is not sealed, so `list == list` errors while `list(1) == list(2)` works. The
sealed surface is nonetheless small — `eq`, `ne`, `char`/`display`, phase lookup — while
everything called on a scalar frame stays overridable; `{list.mineral}` works. And sealing
`eq` to handle identity is what `phaseItem` already does today, which under this model
*removes* the two-meanings-of-`==` defect ADR 0003 records rather than creating it.

We chose **absorbing `phaseItem` into `referenceFrame`** over keeping phase identity as its
own concept beside the frame. ADR 0003 leaves it open on the grounds that it is "the one
data-side handle that is legitimately identity-semantic" — which under this model is true of
every frame, so they are one class rather than two.

We chose **`gridLayout` holding a frame** over keeping it a `referenceFrame` subclass. The
inheritance supplies its 1x3 basis and `axesNames` and costs the root its meaning: rule 1
makes `referenceFrame` the phase-identity root with `notIndexedFrame` as its default scalar
element, and a layout has no identity to register, never enters a `CSList`, and would be the
one subclass whose default element is something it can never be.

We chose **`notIndexedFrame` as a third concrete frame** over an empty slot in the phase
list. Empty already means "unifies with anything", which is the opposite of what an
unindexed phase needs, and a frame is what lets its name and colour live where every other
phase's do.

We chose **dropping `Miller`** over keeping it as a thin subclass. Keeping it is
defensible: the invariant "`Miller` ⟺ crystal frame" is enforceable once there is no public
frame setter, since the only entries are the constructor and `transformReferenceFrame`,
both of which can return the right class. It loses on cost — subclass construction and
dispatch on every Miller-preserving operation — for a distinction the frame already makes.

## Consequences

- `ori.CS = cs` keeps working and gains a warning naming `transformReferenceFrame`: it is
  the one silent relabelling left, and the warning must say which invariant the silent form
  picks (the components) and fire once per call site, not once per call.
- `isa(x,'Miller')` goes silently **false**, in 54 places in this tree plus user scripts and
  third-party code. A replacement predicate has to ship in the same release for the note to
  point at.
- Every `dot`, `angle`, `dot_outer` and `angle_outer` call that reaches a group-carrying
  operand without a `noSym*` flag has to say on the line that the symmetry is intended. The
  opt-out marks itself, so the silent reduction is the one load-bearing state nothing on the
  line records — and it reads identically where it is right and where it is an oversight.
  There are 456 such calls in all, over 190 files, 34 of them already flagged; the pass
  starts by establishing how many reach a group at all, most taking a plain `vector3d` or
  `quaternion` where the question does not arise and no comment is owed.
- `gridLayout` stops being a `referenceFrame` and holds one: 116 occurrences over about
  fifteen files, concentrated in `EBSDAnalysis/@EBSD/gridify.m`, `@mapImage`, `@EBSDsquare`,
  `@EBSDhex/transformReferenceFrame.m` and `geometry/@orientation/byScreenAlignment.m`, plus
  three `check_*` files. Its three methods stay; what moves is where `basis` and `axesNames`
  come from.
- Applying a literature tensor to measured data becomes an explicit
  `transformReferenceFrame` call. Because the tolerance measures shape, the cubic case
  needs no tolerance argument and cannot fail; only a genuinely different cell shape does.
- `transformReferenceFrame` has one meaning and wildly different costs: a matrix multiply
  for a vector, a Wigner-D transformation of every coefficient for a harmonic ODF, and a
  re-expansion in a different symmetry-adapted basis when the groups differ. Coefficients
  stay symmetry-adapted and the frames are fixed at construction, so this is inherent.
- The register acquires a second tolerance question distinct from the first: *are these the
  same frame* (identity, tight) versus *how different may they be to reinterpret one as the
  other* (permission, per call, and legitimately larger).
- Two frames that print identically can be distinct, because the mineral name is in the key
  and mutable. The state is reachable by renaming one of them, and the display is exactly
  what someone would use to diagnose a failed join.
- Sealing has to be designed in rather than retrofitted, and the gap will not show up in a
  synthetic test: an unsealed method works on a phase list of crystal frames only, and
  breaks the moment the dataset carries an unindexed phase — which most real ones do. The
  failure is data-dependent but not rare.
- `list.mineral` returns the *first* name silently instead of erroring; `{list.mineral}` is
  the working form. Sealed accessors are the fix where it matters.
- `eqTol` and `sim` (`geometry/phaseItem.m`) are absorbed into the register door rather than
  migrated. Both are `Sealed`, and both document the same defect in their own help — for
  arrays they exit as soon as any pair matches by identity and return the raw identity
  comparison for every element, so the result "is not reliable per-index". They disappear
  with the question they answer, and the tolerance mismatch ADR 0003 records — `ensureCS` at
  1e-1 on the alignment matrix against `eqTolPair`'s 5e-2 on the axes — collapses to one
  tolerance in one place.
- `[ebsd1, ebsd2]` from two files whose headers disagree in the last digit of a lattice
  constant keeps working: uniform scaling is a shape deviation of zero, so the register
  returns one frame. What splits is a difference in cell *shape* — an axial ratio or an
  angle moving in the third digit — and that yields **two phases with the same name** where
  `sim` merges them today. That is split-when-unsure landing on a common operation, loud
  rather than silent, which is the intent — and the concatenation warns: naming both frames,
  saying how their shapes differ, and pointing at `transformReferenceFrame`.

## Open

1. Loading old `.mat` files. ADR 0003 already flags it: `loadobj` currently *repairs* an
   empty convention into the shared default, and under the register it must re-intern
   non-empty frames instead — but "in an existing `.mat` the two senses of empty are
   indistinguishable", and this model adds a third state, `notIndexedFrame`, that older
   files encode as a `notIndexed` phaseItem. The migration needs a deliberate answer.
2. The deprecation path for `crystalSymmetry`/`specimenSymmetry`: how long they stay, and
   whether they warn.
3. Colour in the register key, so that importing one phase from two files with different
   vendor colours splits it, or out of the key and therefore shared across every dataset
   over that frame.
4. Whether the `transformReferenceFrame` rule is always required, or omittable when every
   candidate rule agrees.
5. `from`/`to` versus `source`/`target` for the stored frame names.
6. Whether `cross` propagates the index basis crystallographically — two directions giving
   a plane normal, two normals giving the zone axis.
7. Brackets on input. `geometry/@Miller/private/s2v.m` reads `(hkl)`, `[uvw]` and the zone
   forms by testing for `[` alone, so `<100>` parses as a plane normal today and the family
   brackets carry no meaning. Whether `{111}` and `(111)` against one frame select the
   parent and its group-stripped sibling, or the bracket is decorative on input and only the
   frame decides, is open. The first makes the sibling reachable by notation, which is
   otherwise the one part of rule 7 with no user-facing door.
