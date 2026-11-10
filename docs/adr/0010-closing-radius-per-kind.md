# The closing radius of a notIndexed region is a property of its kind

**Status: decided and implemented 2026-11-09.** `EBSD/calcGrains` options `'alphaPore'`,
`'alphaPocket'`, `'alphaCrack'` and `'kinds'`, `EBSD/classifyNotIndexed`, `kindOfParts` in
`EBSD/private/spatialDecompositionGrid.m`. The measurements behind it are in
`docs/notindexed-classification.md`.

## Context

`calcGrains` fills the notIndexed regions of a map by a morphological closing with a disk
of radius `alpha`, so every region narrower than `2*alpha` pixels disappears into the
grains around it and every wider region keeps its core. The closing reads the width of a
region and nothing else. The regions of a real map are of different kinds, and each kind
wants a different treatment: a speck of a few pixels belongs to the grains around it, a
pore inside one grain is part of that grain, a pocket between several grains is a
notIndexed grain of its own, a crack cuts grains into pieces that may be one grain, and a
void at the edge of the map is outside all grains. The one value that bridges a crack
also absorbs every pore and pocket narrower than it.

## Decision

1. **The kinds are read off the parts the closing with `alpha` leaves open.** Those parts
   are the opening of the notIndexed mask by the disk of radius `alpha`, so they come for
   free from the base closing, and the base closing is never undone. A part is a crack when
   its Feret diameter squared is at least five times its area and at least half of its
   boundary cells touch grains rather than notIndexed cells - a crack is walled by grains
   on both sides, a strip of plucked rim along a void is not - a void when it touches the
   raster outside the convex hull of the indexed pixels, a pore when at least 85 percent
   of its rim is held by pixels the boundary criterion connects, and a pocket otherwise;
   crack before void before pore before pocket. The closing cuts a crack where it narrows,
   so what lies between two crack parts is part of the crack: the parts and the connected
   pieces of filled cells are the nodes of a graph with a contact as an edge, and pruning
   the leaves that are no crack part leaves the nodes between crack parts - the filled
   necks and the widenings on the crack's path, but not a pocket hanging off it by a
   thread of notIndexed cells.
2. **Each kind closes with a radius of its own**, `'alphaPore'`, `'alphaPocket'` and
   `'alphaCrack'`, in pixels like `alpha`. On the cells of a kind its radius replaces
   `alpha`: a radius below `alpha` reopens the cells the base closing filled, `0` leaves
   the kind entirely open, and `inf` fills it whole. Voids keep `alpha`. On the
   `'delaunay'` path the kind's radius is a circumradius bound like `alpha` is.
3. **Pores are filled and cracks are left open by default**, `'alphaPore'` is `inf` and
   `'alphaCrack'` is `0`; `'alphaPocket'` defaults to `alpha`. The pixels of a pore have
   one owner, so filling it guesses nothing. A crack is a fracture, and the common question
   is the grains on either side of it; where it narrows below `2*alpha` the base closing
   would join them, so the crack cells it filled are reopened. Filling a pocket places the
   boundaries between its grains by distance, and bridging a crack merges grains across it;
   both are decisions the user takes.
4. **The classification is public.** `classifyNotIndexed` returns the kind of every pixel
   and a table of the parts, computed by the code `calcGrains` runs, and `'kinds'` hands a
   classification back, edited or not. A part takes the mode of the kinds of its pixels.
5. **The two thresholds stay in the code.** The crack threshold rests on one crack. Until
   more maps say otherwise, `'kinds'` is the way to correct a kind.

## Consequences

- Results change on every map with a pore wider than `2*alpha` or a crack narrower than
  it: peridotite at 10 degree and minPixel 5 goes from 575 to 570 grains and from 41 to
  34 notIndexed grains. `'alphaPore',0` restores the pores as notIndexed grains,
  `'alphaCrack',alpha` the closing of the narrow crack cells.
- `'alpha',0` no longer leaves every notIndexed pixel a grain of its own. A region enclosed
  by one grain is a pore and belongs to that grain whatever `alpha` is; `'alpha',0,
  'alphaPore',0` is the raw map.
- The classification runs on every call, 0.02 to 0.06 s on peridotite, forsterite and the
  2.5 million pixel steel map.
- On peridotite the crack pieces have 30 and 34 percent of their boundary against
  notIndexed cells, the strip of plucked rim at the bottom right edge 63 percent, the voids
  50 to 83 percent; pockets and pores spread from 0.3 to 0.75 and are not separated by this
  measure, so it only sharpens the crack rule. A pocket on a bridged crack stays a pocket
  although the bridging encloses it; that is corrected through `'kinds'`.

## Alternatives

- **Two passes with a fill mask**, classifying before any closing: the thin arms of a
  wide region are then parts of their own and the kinds come out wrong at the necks.
- **Post-processing only**, `merge(grains,'inclusions')` after the reconstruction: it
  reads what encloses a region and not its kind, so it takes pockets inside deformed
  grains and cannot bridge a crack.
- **One vector `'alpha',[speck pore pocket crack]`**: shorter to type and impossible to
  read back; a name per kind documents itself.
