# MTEX

MTEX is a MATLAB toolbox for crystallographic texture analysis (EBSD, pole figures, ODF reconstruction, grain boundaries).

## Language

### EBSD data storage

**Property** (`ebsd.prop`):
Per-pixel data, one value per measurement point, indexed and subset in lockstep with the map (e.g. `MAD`, `BC`, `mis2mean`). Backed by `dynProp`; `subSet` truncates these fields when `ebsd(ind)` is evaluated.
_Avoid_: option, attribute, field (when meaning per-pixel data specifically)

**Option** (`ebsd.opt`):
Scan-level (whole-file) data that is not per-pixel and is not resized when `ebsd(ind)` is evaluated. Backed by `dynOption`. Anything that doesn't have exactly one value per measurement point belongs here, not in `prop`.
_Avoid_: property, metadata (when meaning scan-level data specifically)

**Header** (`ebsd.opt.header`):
The scan-level metadata captured from a file's own header/preamble section (instrument settings, operator, acquisition parameters, vendor-specific bookkeeping) — everything in the file that isn't a per-pixel column and isn't already represented by `CSList`/crystal symmetry. Kept in each vendor format's own native shape; there is no normalized field-name schema shared across formats. Phase/symmetry information is excluded even when it appears in the file's header section, since it's already captured by `CSList`.
_Avoid_: metadata, info, cprInfo (legacy name, superseded)

**headerOnly** (import option):
A boolean import option that short-circuits a loader before its expensive per-pixel/binary read, returning an `EBSD` object with empty `pos`/`rotations`/`phaseId` but populated `CSList`/`phaseMap`/`opt.header`. Exists for fast metadata inspection on large scans.

### Grain segmentation

**Grain**:
A phase-homogeneous, spatially connected region of EBSD pixels produced by segmentation. A phase change between two neighboring pixels is always a grain boundary — orientation-based segmentation never bridges two different phases into one grain.
_Avoid_: Region, cluster

**notIndexed** (phase):
A degenerate phase value for pixels whose diffraction pattern couldn't be indexed. Like any other phase, a connected notIndexed area can form its own grain — it is not categorically different from an indexed grain, just phase-homogeneous in "no phase." A notIndexed patch too small/thin to stand on its own (governed by the `alpha` closing-width threshold) is absorbed into a neighboring grain instead of becoming its own grain.
_Avoid_: Unindexed, unmeasured, gap (as if it were not a grain)

**Enclosure**:
The relationship where one grain sits entirely inside another. Described from the outside, the containing grain "has a hole"; described from the inside, the contained grain "is an inclusion." These are the same fact viewed from opposite sides, not two separate concepts — a hole is never empty, since even a notIndexed patch there is itself a grain (see notIndexed).
_Avoid_: Treating "hole" and "inclusion" as independent facts that could occur without each other

**Grain boundary**:
A segment between two neighboring EBSD pixels belonging to different grains — the atomic edge from which grain outlines and triple points are derived. Segments are stored in walk order (see Chain), so consecutive segments of the same chain share a vertex.
_Avoid_: GB (as if it names a different concept), edge

**Phase boundary**:
Not a distinct entity — a grain boundary whose two neighboring grains happen to differ in phase. It's a way of querying/filtering grain boundaries, not a structurally different kind of thing.
_Avoid_: Treating as its own class or type

### Grain boundary chains

**Chain**:
A maximal run of grain boundary segments laid end to end, running from one junction to the next and never passing through one. Every segment belongs to exactly one chain, and the two grains a chain separates are the same along its whole length.
_Avoid_: Segment (which is the atomic edge, not the run), boundary line, polyline

**Junction**:
A vertex where the number of meeting boundary segments is anything other than two — the places a chain is not allowed to run through. Purely a matter of how many segments meet, so it includes both the ends of the outer map border and the points where four segments cross.
_Avoid_: Triple point (a junction need not be one, and vice versa), node, corner

**Triple point**:
A junction where exactly three segments meet *and* they separate three distinct real grains. A strict subset of the junctions: a vertex where three segments meet because one of them runs along the edge of the scanned area is a junction but not a triple point.
_Avoid_: Using interchangeably with Junction

**Closed chain**:
A chain that ends where it began, so its vertices form a fillable loop. Usually this is the boundary of a grain enclosed entirely within one other grain (see Enclosure) and has no junction at all, in which case it has no natural first segment and one is chosen by convention; but a chain that leaves a junction and returns to that same junction is closed too.
_Avoid_: Loop, cycle, ring; treating "closed" as the same thing as "junction-free"

### Parent grain reconstruction

**Variant**:
One of the crystallographically-equivalent child orientations predicted from a single parent orientation via a known orientation relationship (OR). The finest-grained classification of a reconstructed child grain relative to its parent.

**Packet**:
A coarse grouping of variants that share the same habit plane — the parent {111} plane a variant's child lattice aligns to. Corresponds to the real martensite-packet microstructure concept (laths nucleated on the same austenite plane).

**Bain group**:
A coarse grouping of variants by their Bain correspondence — which parent {001} cube-axis plane a variant's child lattice aligns to. Independent of, and not nested inside, packet: packet and Bain group are two orthogonal classifications of the same variant, not two levels of one hierarchy.
_Avoid_: Assuming Bain group is a coarser/finer level than packet

**Transform** (reconstruction step):
The first step of parent grain reconstruction: each grain is individually assigned a candidate parent orientation via the orientation relationship, flipping it from child phase to parent phase. Always happens before merging, in both reconstruction algorithms.

**Merge** (reconstruction step):
The second step of parent grain reconstruction: transformed grains that are neighbors and share a compatible parent orientation are combined into a single grain footprint.

**Grain graph** (reconstruction algorithm):
A parent grain reconstruction strategy whose graph has one node per grain and edges for shared grain boundaries — reasons about grain-to-grain compatibility directly.
_Avoid_: Confusing with Variant graph

**Variant graph** (reconstruction algorithm):
A parent grain reconstruction strategy whose graph has one node per (grain, candidate variant) pair, with edges encoding compatibility between candidate variants of neighboring grains — reasons about which variant to commit to before merging.
_Avoid_: Confusing with Grain graph

### Scan grid reconstruction

**Dummy cell**:
A synthetic filler cell added beyond the scanned area's edge to bound the spatial decomposition (Voronoi/grid) at the map boundary. Never a real measurement, never assigned an id, never becomes a grain.
_Avoid_: Ghost cell, edge pixel, hole

**Gap**:
A run of missing measurements within a single scan line (e.g. from filtering a multi-phase scan down to one phase), recovered during grid-index assignment. Distinct from a hole (a real measurement that failed to index) and a dummy cell (no measurement ever attempted there).
_Avoid_: Hole, missing pixel (when meaning specifically an in-line gap)

**Hole**:
A connected notIndexed area within the actually-scanned region — see notIndexed. Distinct from a dummy cell (outside the scanned area entirely) and a gap (missing data within a scan line, resolved before grid reconstruction).

**Local deformation model**:
The correction used when recovering positions for cells with no measurement (holes, dummy ring, gaps) on a scan grid that isn't perfectly rigid: an ideal affine grid is fit first, then the local deviation between real measured positions and that ideal grid is interpolated back in, rather than assuming one global affine transform explains the whole scan.
_Avoid_: Distortion correction (too vague), warping
