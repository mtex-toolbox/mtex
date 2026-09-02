# plotting/

Everything funnels through `@mtexFigure`, which owns multi-axis layout, colorbars and
resizing. Build a new plot type on it rather than on raw `figure`/`axes` handles.

- `mtexFigure` owns the axes position, so anything MATLAB glues to the outside of an axes —
  a colorbar, a legend with an `...outside` location — has to be **adopted**, or the two
  fight over the position and the result depends on the number of resize events.
  `private/adoptLegend.m`, `private/adoptColorbars.m`. Both work the same way: `measure`
  reserves a band for it, `solveLayout` positions it explicitly. Legend gap is
  `mtexFig.legendSpacing`, per plot via `'legendSpacing'` or `setMTEXpref`.
- Layout comes from the axes **camera**, not the data: `plotting_tools/axesRatio.m` shapes
  the axes like the shadow the plot box casts on screen. Set the camera *before* `drawNow`, or
  the axes is shaped for the wrong view (see `geometry/@crystalShape/plot.m`).
- **Everything the layout manages is pinned to `Units = 'pixels'`** — the figure, its axes,
  adopted colorbars, adopted legends — at the moment it enters the layout, and nothing ever
  switches it back (`@mtexLayout/measure.m`). Do not save-and-restore units around layout
  code. Read a position, get pixels.
- `@mtexLayout` splits the layout into **measure → solve → apply**. `solveLayout` is pure
  arithmetic — a spec struct in, every position out, no handle either way — which is why
  `tests/core/check_mtexLayout` can test the layout without opening a figure. `measure` is
  the only step that touches graphics properties, and it caches behind a token, so a
  `drawNow` that changes nothing costs one comparison. `apply` writes only positions that
  moved more than half a pixel; that is what keeps `scaleBar`'s `Position` listener from
  firing on every pass.
- `sphericalProjections/` holds the sphere→plane projections (stereographic, equal area,
  equal angle, orthographic, gnomonic); `makeSphericalProjection.m` / `screenProjection.m`
  wire a choice into a plot.
- `ODFSections/` — one class per way of slicing an `SO3Fun`. Add a section type here rather
  than special-casing `SO3Fun/plot`.
- `orientationColorKeys/`, `directionColorKeys/`, `planarColorKeys/` are the single source of
  truth for orientation→colour, for plotting and for programmatic lookups alike.

## Plotting conventions

`plottingConvention.m` sets which direction points east / out of the page. It reprojects
existing data; it recomputes nothing.

A convention belongs to a `@referenceFrame`, never to a data object — `how2plot` is **read
only** on every other class (`docs/adr/0003-reference-frame-vs-symmetry.md`). Exactly three
ways to set it:

```matlab
plot(x,'how2plot','y↑→x')        % this plot
plottingConvention.default(...)   % this session
x.frame = specimenFrame.rolling   % move the data into a frame that carries one
```

Traps:

- **A crystal frame's convention is not the session's.** Anything derived from a
  `@crystalSymmetry` — `fundamentalSector` above all — must carry that symmetry's frame,
  because `sphericalRegion/isUpper`, `restrict2Upper` and `polarCoordinates` read
  `sR.how2plot`. A frame-free sector resolves against the session default, which flips the
  hemisphere and re-lays the IPF colour key: the colour of a fixed orientation then depends
  on `plottingConvention.default`, which it must never do.
- `symmetry` is a **handle** class, so assigning `how2plot` on one can move the whole session.
- `view()` reads the plot box, not the data, so it mirrors on a reversed axis. The 3d
  spherical plots are the only MTEX axes that reverse `XDir`/`YDir`.
- A manual camera makes MATLAB report `TightInset` as `[0 0 0 0]`, which silently kills
  autocropping.
- `plot(...,'3d')` builds no `sphericalPlot`. `annotateFrame` is the shared seam for axes
  annotation across both paths.
