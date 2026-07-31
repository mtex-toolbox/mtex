**** import_wizard ****

1. more beautiful file browser
 -> icons for directories and EBSD files -- DONE
 -> go into directory requires double click, single click only opens the branch -- DONE
 -> keybord cursor navigation -- DONE (arrows move the cursor, Enter opens, Backspace goes up)
 -> better icon for folder up -- DONE (folder icon with up arrow)
 -> when using keybord cursor navigation do not open folder just by moving selection over it -- DONE (branch opens on mouse click only)
 -> order subfolders first, files last -- DONE
 -> folder up icon should have a black arrow instead of a white one -- DONE

2. more beatiful basic information window -- DONE
 -> Extent in µm: i.e.   coordinates: [0,300] x [0,100] µm -- DONE
 -> Extent in pixels, i.e., hex grid: 1000 x 500, dHex = 60 µm
    or square grid: 1000 x 500, dx = 60 µm -- DONE
 -> display vendor if possible -- DONE (metadata field if present, otherwise guessed from the file format)
 -> display creation date -- DONE (metadata date if present, otherwise the file date)

3. more beatiful plotting window 
 -> three tabs IPFX, IPFX, IPFZ instead of the selection box on the right -- DONE
 -> similarly different tabs for what is currently in the MAP tab -- DONE (phase map + one tab per property)
 -> colorize tabs to distinguish, ipf, pole figure and map tabs -- DONE (colored tab labels per category)
 -> when changing Map coordinate system - do not replot map but use setView(newPlottingConvention) 
    this should work for ipf maps and property maps, ODF does not need to be recomputed - is is sufficient to plot the pole figure once again -- DONE
 -> when changing Euler Coordinate System - do not recompute ODF but rotate it -- DONE
 -> in pole figure view the labels for the Miller indices should be right above the square pole figure axes -- DONE
 -> in pole figure view the labels should indicate that they are editable -- DONE (pencil symbol + tooltip)


4. calcDensity with many orientations is slow -- DONE
 -> we should a round to a regular quadrature grid and use FFT (not NFFT) based algorithm
    -- DONE (automatic for more than 10*bandwidth^3 orientations, see SO3FunHarmonic.adjoint 'gridded')

**** round 2 ****

5. no visual guidance that a file needs to be double-clicked (or Enter) to import it -- DONE
 -> single click only selects the node (see FileTreeDoubleClicked ~line 1320,
    keyboard Enter handling ~line 1310); nothing currently signals that a
    second action is required to actually load the file
 -> DONE: ImportStatusLabel below the FileTree (setImportStatus helper),
    idle state shows the hint text with a light-blue background

6. no visual guidance that a file is currently loading -- DONE
 -> importEBSDData (~line 560) calls EBSD.load(...) synchronously with no
    busy/progress indicator; for a large file the UI just appears to hang
    until it's done
 -> DONE: same ImportStatusLabel, switches to an amber "Loading <file>..."
    message (with a forced drawnow so it actually paints before the
    blocking EBSD.load call) then reverts to the idle hint

7. shrinking the window can make the bottom-left (export) buttons disappear -- DONE
 -> LeftLayout's RowHeight is {270, 118, '1x', 210, 80} (~line 124): every
    row except row 3 (flexible '1x', currently unoccupied by anything) is a
    fixed pixel height, 678px total. The export button grid is the last
    fixed row (row 5, 80px, createExportButtonsPanel ~line 267-274), so
    it's the first thing clipped off the bottom when the window gets
    shorter than the fixed total
 -> DONE together with 9 (same fix)

8. redesign the two bottom-left buttons (createExportButtonsPanel ~line 267,
   ExportButtonPushed ~line 1454, ExportScriptButtonPushed ~line 1489) -- DONE
 (a) "Export to Script" -> remove ExportScriptTypeDropDown (currently
     EBSD/ODF/PoleFigure/tensor, used to pick the template file at
     ~line 1496); this app only ever loads EBSD data, so the type should
     just be inferred, not user-picked -- DONE (exportType hardcoded to 'EBSD')
 (b) "Import to workspace" -> replace the modal inputdlg popup asking for
     the variable name (~line 1459) with an inline text field next to the
     button, always visible, not a dialog -- DONE (VariableNameField)

9. the file browser should fill all remaining space on the left -- DONE
 -> ties into 7: FileBrowserPanel is pinned to a fixed 270px (LeftLayout
    row 1), while row 3 - the only flexible '1x' row - currently sits
    empty/unoccupied. FileBrowserPanel should take the flexible row
    instead of a fixed height
 -> DONE: LeftLayout RowHeight is now {'1x', 118, 210, 80} (4 rows, the
    dead row removed), FileBrowserPanel takes the flexible row 1

10. PhaseTable column widths should fit their content (fillPhaseTable
    ~line 697; 9 columns: Plot, Phase, Mineral, Pixel, Symmetry, a, b, c,
    Color - no ColumnWidth is set anywhere, so uitable falls back to its
    default sizing) -- DONE (widths only; the relocation question below is
    still open)
 -> Plot (checkbox) and Color (swatch) columns can be much narrower;
    Phase can probably shrink too -- DONE ({45,55,90,110,75,55,55,55,45})
 -> open question: could the freed-up horizontal space be used to move the
    "Coordinate systems" section (currently CoordinatePanel on the left,
    ~line 216) over next to/above the phase table instead? Not decided,
    just want to explore it -- RESOLVED by item 30 (Coordinate systems
    moved into the top-right corner of RightLayout) - no longer open

11. the generated import script (ExportScriptButtonPushed ~line 1489,
    templates/import/loadEBSDtemplate.m) is not yet functional -- DONE
 -> crystal symmetry: csLines (~line 1534-1562) is joined and substituted
    into `CS = {crystal symmetry};` without ever wrapping it in `{ }` -
    and starts with a stray literal '...'. Result is e.g.
    `CS = crystalSymmetry(...), 'notIndexed', ;` - not a cell array,
    breaks any multi-phase file outright
    -- DONE, and changed shape along the way: CS is now built as
    `[notIndexed('notIndexed',[r,g,b]), crystalSymmetry(...), ...]` (a
    phaseItem array via '[ ]', not a cell array - crystalSymmetry and
    notIndexed share the phaseItem base class) instead of the originally
    planned '{ }' cell array, and notIndexed carries the phase's color
    from the wizard's phase table
 -> Euler correction: applied via a separate post-load
    `rot = rotation.byEuler(...); ebsd = rotate(ebsd,rot,{rotationOption});`
    (~line 1587-1598, loadEBSDtemplate.m lines 35-36), but EulerCorrection
    is actually a proper option of EBSD.load itself
    (EBSD.load(fname,'EulerCorrection',rot) - see EBSD/load.m and how
    mtexdata.m's built-in loaders do it) - a different, likely
    non-equivalent mechanism from rotating the already-loaded data
    after the fact
 -> DONE: template now passes EulerCorrection as an EBSD.load(...) option
 -> found + fixed along the way (not in the original write-up): the
    template also always passed `'interface','wizard'` into EBSD.load
    ('wizard' is a warning-suppression flag the interactive app uses, not
    a real interface name) - EBSD.load's dispatcher didn't recognize it
    and silently fell through to the generic loader instead of
    loadEBSD_ctf, which produced wrong mineral names (unknown1/2/3) and
    dropped the Euler correction entirely. Verified by actually executing
    the generated script, not just reading it. The 'interface' argument
    is now dropped entirely so EBSD.load auto-detects it from the
    extension, same as passing EulerCorrection already made the
    'wizard'-flag warning-suppression redundant

12. the generated script should not be saved to disk, just opened in the
    MATLAB editor -- DONE
 -> currently (~line 1604-1612) it always fopen/fprintf/fclose-writes
    scriptFileName into pwd first and only falls back to
    matlab.desktop.editor.newDocument(str) (unsaved) if fopen fails;
    newDocument should be the normal path, not the fallback
 -> DONE: fopen/fprintf/fclose path removed entirely, always
    matlab.desktop.editor.newDocument(str)

13. [bigger item] interfaces should be able to return just metadata/header
    info without loading the full per-pixel data blocks, so the wizard can
    show a quick preview while browsing/scrolling files, without paying
    full-load cost for every file hovered over
 -> this is a format-parser capability (loadEBSD_ctf.m, loadEBSD_ang.m,
    etc.), not just a wizard UI change - each interface would need a
    header-only / lightweight mode
 -> loadEBSD_ctf.m already reads the header separately from the bulk data
    internally (~line 15), so it's the natural first candidate to
    prototype a header-only path on
 -> currently the wizard's own metadata display (vendor/creation date,
    updateCurrentDataInfo ~line 1134) only runs *after* a full
    EBSD.load(...,'wizard') (importEBSDData ~line 560) - there's no
    lightweight peek today

14. [profiled] replotting pole figures after changing Euler coordinates
    takes surprisingly long
 -> plotPoleFigures (~line 937) is already supposed to avoid a full
    recompute here: per the comment at ~line 960-964, an Euler-correction-
    only change should just rotate the cached ODF (app.PFODF = rotate(...),
    ~line 972) instead of recomputing calcDensity from scratch - this
    was the "DONE" item 3 fix from round 1
 -> PROFILED (Forsterite.ctf test data, 3 pole figures): the item's own
    premise turned out wrong - the ODF caching already works correctly.
    Measured via the MATLAB profiler around a real setEulerCoordinate ->
    plotPoleFigures call (2.52s wall time total):
    - SO3Fun.rotate (the cheap cached-ODF-rotation path) - only 0.11s
      total (4%). calcDensity is NOT being re-triggered; cache invalidation
      is working as designed
    - SO3Fun.plotPDF - 1.81s total across the 3 pole figure axes (72% of
      the total time, ~0.6s per axis) - THIS is the real bottleneck, not
      the ODF step at all. Sub-costs inside it: ContourDataCache.
      getContourLineAndFillData (0.17s/30 calls) + nfsftmex (0.08s/21
      calls) evaluating the contour data, sphericalPlot.sphericalPlot
      (0.48s/12 calls) rebuilding the entire spherical-axes graphics
      scaffold (grid meridians, outline circle, region checks) from
      scratch, vector3d.text (0.29s/9 calls) placing the X/Y/Z direction
      labels, and colornames (0.12s/24 calls) doing repeated non-cached
      color-name-string lookups
    - plotPoleFigures always calls resetAxes + a full plotPDF for every PF
      axis unconditionally (~line 977-1003), regardless of whether the
      change was Euler-only (ODF merely rotated) or a bigger change (new
      phase, new Miller indices) - so even the "cheap" Euler-only path
      still pays for 3 full pole-figure re-renders from scratch every time
 -> root cause is NOT wizard code: it's inherent cost in SO3Fun/plotPDF.m
    and sphericalPlot.m (core MTEX plotting, used far beyond this wizard)
    rebuilding the full spherical-axes scaffold + contour data on every
    call, with no partial-update path for "same axes, same projection,
    just a rotated ODF and/or updated contour values"
 -> NOT IMPLEMENTED - out of scope for the wizard alone: the real fix
    would be a partial-update capability in plotPDF/sphericalPlot (reuse
    the existing axes scaffold, just refresh contour data + labels) - a
    bigger core-plotting change needing its own design decision, not a
    wizard-code fix. Filing as backlog rather than picking an approach
    unprompted, matching the standing "confirm redesign decisions" rule

15. loading a file by pressing Enter does not work all the time -- DONE
 -> WizardKeyPress (~line 1329) only handles Enter/Backspace when
    app.UIFigure.CurrentObject is empty, the UIFigure itself, the FileTree,
    or a TreeNode (~line 1338-1342) - the comment's premise ("pure keyboard
    navigation leaves CurrentObject empty") only holds right after startup
    or a folder navigation
 -> focus(app.FileTree) is only ever called in two places: once at startup
    (createComponents ~line 151) and once at the end of navigateToFolder
    (~line 451). importEBSDData (the *file* import path) never refocuses
    the tree afterward, and neither does switching plot tabs, editing the
    phase table, or the Import/Export buttons - ExportButtonPushed even
    explicitly calls commandwindow, which steals focus to the Command
    Window. So Enter works right after startup/a folder navigation, then
    silently stops working the moment focus drifts anywhere else, until
    the user manually clicks back into the file tree
 -> DECIDED: invert the guard - block Enter/Backspace only when focus is
    demonstrably in a text input, instead of requiring CurrentObject to
    match an allowlist. No new focus() calls needed at other sites. -- DONE
    (blocks isa(co, EditField/NumericEditField/TextArea/DropDown/Table));
    verified the "allowed" path still imports correctly, and that every
    class checked against matches this app's actual controls exactly, but
    could NOT verify the "blocked" path end-to-end headlessly - focus()
    does not reliably set UIFigure.CurrentObject without a real window
    manager/mouse click in this environment, only genuine interactive use
    can fully confirm the blocking side

16. rename "Import to workspace" -> "Import to variable", and swap the
    order so the button comes first with the variable name field to its
    right (createExportButtonsPanel ~line 275-300: VariableNameField is
    currently column 1, ExportButton column 2 - swap to button then field)
    -- DONE

17. rename "Export to Script" -> "Generate import script"
    (createExportButtonsPanel ~line 305) -- DONE

18. clicking "Import to variable" should change focus to the Workspace
    browser, not the Command Window -- DONE
 -> ExportButtonPushed currently ends with commandwindow (~line 1479);
    swap for workspace (MATLAB's built-in Workspace-browser-focus
    counterpart to commandwindow, confirmed to exist:
    toolbox/matlab/codetools/workspace.m)

19. PhaseTable Mineral column should be 50% wider -- DONE
 -> app.PhaseTable.ColumnWidth is {45, 55, 90, 110, 75, 55, 55, 55, 45}
    (Plot, Phase, Mineral, Pixel, Symmetry, a, b, c, Color); Mineral (3rd,
    currently 90) -> 135 -- DONE together with 20 below (10-column layout:
    {45, 55, 135, 70, 55, 75, 55, 55, 55, 45})

20. PhaseTable: split "Pixel" into two columns "Pixels" and "%"; right-align
    every column's content except "Plot" -- DONE
 -> fillPhaseTable (~line 736): the table is built with 9 columns
    (VariableTypes/VariableNames ~line 743-745) and the Pixel cell is
    currently one combined string `[int2str(numPhases(pId)),' (' ...
    '%)']` (~line 751 area, row assignment) - needs splitting into two
    numeric/string columns instead
 -> alignment is currently one table-wide `addStyle(app.PhaseTable,
    uistyle('HorizontalAlignment','left'))` (~line 738) applied to every
    column with no exception; needs to become right-alignment for every
    column except Plot (a per-column style, not a blanket one)
 -> touches the same table structure as 10 (ColumnWidth, now 10 entries
    instead of 9) and 19 (Mineral width) - do together or re-check both
 -> DECIDED: native numeric columns (Pixels as integer, % as double with
    fixed decimals), not pre-formatted strings - keeps the table's normal
    numeric rendering/sorting, same as a/b/c already do

21. [bigger item] add a treeview of ebsd.opt in the empty space to the right
    of the PhaseTable; selecting an image node there shows it in the Images
    tab; remove the Images tab's dropdown (ImagesDropDown) since selection
    moves to the new tree -- DONE
 -> DECIDED: the full opt structure (all fields, all types), with only
    image-shaped nodes actionable - a general ebsd.opt browser, not just
    an image picker -- DONE (populateOptNode: image-shaped fields ->
    actionable Image leaf, scalar structs -> Folder branch (recurses),
    everything else -> informational Field leaf with a short value
    preview, e.g. "someScalar: 42")
 -> DONE: RightLayout is now ColumnWidth={'2x','1x'} (PhaseTable | OptTree
    in row 1), TabGroup spans both columns in row 2
 -> DONE: ImagesDropDown removed; OptTreeSelectionChanged (new callback,
    OptTree's SelectionChangedFcn) sets app.SelectedImagePath (new
    property, replaces ImagePaths) and switches to the Images tab when an
    Image-type node is selected, no-ops for Folder/Field nodes; plotImages
    reads app.SelectedImagePath instead of the old dropdown
 -> Images tab is dimmed (TabColors.Disabled) when no image field exists
    anywhere in the tree, colored otherwise - same idea as before, now
    computed by populateOptNode returning whether its subtree had an image
 -> verified with a synthetic ebsd.opt (image field, nested struct with a
    second image 2 levels deep, plain scalar/text fields): tree structure,
    node types, image selection + tab switch + render, and that selecting
    a non-image node leaves SelectedImagePath untouched - all correct

22. the basic file info panel (CurrentData) should be a two-column
    label/value matrix instead of free-form text lines, for readability
    -- DONE
 -> DECIDED: a 2-column uitable (Label | Value), consistent with
    PhaseTable's style. gridInfoLabel's sentence becomes one row with
    label "Grid" and the whole sentence as its value, not decomposed
    further. -- DONE (CurrentData is now matlab.ui.control.Table, property
    type changed; updateCurrentDataInfo builds Property/Value row pairs)

23. [bigger item] clicking a phase's Symmetry cell should open a separate
    dialog to edit it: point group (dropdown), axis lengths a/b/c, angles
    alpha/beta/gamma, and the coordinate system alignment
 -> hook point: PhaseTableCellSelection (~line 1439) already does exactly
    this pattern for the Color column - hardcoded to
    `event.Indices(2) ~= 9` (~line 1440), opens uisetcolor, then writes
    back to app.ebsd.CSList(row).color (~line 1449). Symmetry is currently
    column 5 and not editable at all - extend with the same
    open-dialog-then-write-back shape
 -> point group list: symmetry.pointGroups (geometry/@symmetry/symmetry.m
    ~line 35, backed by pointGroupList.m) already enumerates every valid
    point group symbol (Hermann-Mauguin notation) - existing data source
    for the dropdown, no need to hand-maintain a list
 -> coordinate system alignment: crystalSymmetry's constructor already
    documents this as a real, distinct option (X||a*,Z||c vs X||a,Z||c*
    etc., see geometry/@crystalSymmetry/crystalSymmetry.m ~line 18-19) -
    matters for lower-symmetry point groups (monoclinic/triclinic), same
    as the 'X||a*, Y||b*, Z||c' setting already shown for Diopside in the
    phase table's "Crystal reference frame" info
 -> new dialog itself does not exist yet - a separate uifigure (modal) or
    similar, not decided/designed

24. in the generated script, rename the variable "CS" to "csList" -- DONE
 -> pure template text change, templates/import/loadEBSDtemplate.m lines
    10 (`CS = {crystal symmetry};`) and 32 (`EBSD.load(fname,CS,...)`) -
    the wizard code's markup substitution doesn't reference the variable
    name itself, only the template text does
 -> DONE (loadEBSDtemplate.m now uses csList throughout)

25. generated script's notIndexed(...) call should only pass the name
    argument 'notIndexed' when the mineral name has actually been
    changed away from that default (ExportScriptButtonPushed's crystal
    symmetry loop, the isNotIndexed branch, currently always emits
    `notIndexed('notIndexed', [r,g,b])`) -- DONE
 -> confirmed already correct on a related point raised in the same
    breath: notIndexed(name,color) - geometry/notIndexed.m - only takes
    those two positional args, no axis lengths, and the current code
    never passes a/b/c for the notIndexed case, so nothing to change there
 -> real constraint: notIndexed(name,color) is positional-only (nargin>=1
    unconditionally sets mineral=name), so there's no way to supply color
    alone without a name arg in front of it. The only two cases where
    'notIndexed' can genuinely be dropped:
    - name AND color both default -> `notIndexed()`, no args
    - name default, color customized -> name is still unavoidable
      positionally, i.e. still `notIndexed('notIndexed', color)`
    - name customized -> `notIndexed(name, color)` (name shown either way)
    So in practice this only saves the argument in the fully-default case;
    making the middle case shorter too would need notIndexed.m's own
    constructor changed to accept color standalone (e.g. name-value pairs)
    - a separate, small change to geometry/notIndexed.m itself, not just
    the wizard, if that's wanted too
 -> DONE: `notIndexed()` (both default), `notIndexed('notIndexed',[r,g,b])`
    (color only), `notIndexed(name,[r,g,b])` (name customized)
 -> found + fixed a real bug uncovered while testing this: isNotIndexed
    was detected by mineral *name* equal to 'notIndexed', so renaming a
    notIndexed phase (exactly what this item enables) made the phase
    silently misdetected as an indexed phase, fell into the
    crystalSymmetry try/catch, failed, and landed in that branch's own
    `notIndexed('notIndexed')` fallback - discarding the rename entirely.
    Fixed to detect by class (`isa(cs,'notIndexed')`) instead of by name.

26. generated script's plottingConvention(...) call should use the named
    direction constants (xvector, -xvector, yvector, -yvector, zvector,
    -zvector) instead of vector3d([...]) with explicit numeric components
    - and should never need to write out a z-value at all -- DONE
 -> ExportScriptButtonPushed ~line 1655-1656:
    `replaceMarkup('{zAxisDirection}', sprintf('vector3d(%s)',
    mat2str(double(mapObj.outOfScreen))));` and the same for
    {xAxisDirection}/mapObj.east
 -> mapObj.outOfScreen and mapObj.east are always exactly one of the six
    principal directions (the CoordinateSystems constant table only ever
    builds plottingConvention from ±xvector/±yvector/±zvector), so a
    small helper that checks which component is ±1 and returns the
    matching name (with a leading '-' if negative) covers every case -
    named constants never expose a numeric z-component either way, which
    covers the second ask too
 -> DONE: new `vectorLiteral` nested helper in ExportScriptButtonPushed,
    falls back to `vector3d(...)` for the (never actually hit) non-
    principal-direction case

27. generated script: define EulerCorrection as its own variable before
    the EBSD.load call (not inline in the call's argument list), and
    build it with rotation.map(...) instead of rotation.byEuler(phi1,
    Phi,phi2), to make explicit how the map coordinate system's axes
    rotate into the Euler coordinate system's axes -- DONE
 -> rotation.map(u1,v1,u2,v2) (geometry/@rotation/map.m) builds exactly
    this: the rotation mapping u1->v1 and u2->v2 - the right primitive
    for "map axis X corresponds to Euler axis X, map axis Z corresponds
    to Euler axis Z" instead of an opaque Euler-angle triple
 -> the app already computes EulerCorrection the same way conceptually:
    applyCurrentCoordinateState (~line 1092) does
    `newCorr = mapRot * inv(eulerRot)` from
    app.CoordinateSystems.how2plot(idx).rot for the map and Euler
    dropdown selections - whoever implements this needs to verify which
    rotation.map(u1,v1,u2,v2) vector pairing (map's east/outOfScreen vs.
    Euler's east/outOfScreen, and in which u/v order) reproduces that
    exact formula, not just assume a direction
 -> currently only mapObj = app.CoordinateSystems.how2plot(mapIdx) is
    captured for script generation (~line 1654, feeds
    {zAxisDirection}/{xAxisDirection} per item 26); the analogous object
    for the Euler dropdown's selection isn't captured yet and would be
    needed too (app.CoordinateSystems.how2plot(app.EulerCoordinatesDropDown.ValueIndex))
 -> phi1/Phi/phi2 markup tokens (~line 1682-1690) and the template's
    rotation.byEuler({phi1},{Phi},{phi2}) go away entirely, replaced by
    this new EulerCorrection variable + rotation.map(...) call
 -> DONE: `EulerCorrection = rotation.map(eulerObj.east, mapObj.east,
    eulerObj.outOfScreen, mapObj.outOfScreen)`, verified numerically to
    exactly reproduce the app's own `mapRot * inv(eulerRot)` formula
    across all tested map/euler combinations, and verified end-to-end by
    executing the generated script and comparing the resulting
    EulerCorrection angle

28. include a first sanity-check plot in the generated script: an IPF-Z
    map of the dominant (indexed) phase -- DONE
 -> mirrors the app's own default view after import - see importEBSDData
    (~line 592, `app.TabGroup.SelectedTab = app.IPFTabs(3)` = IPF Z) and
    dominantEnabledPhase (~line 1011ish) for how the app picks the
    dominant indexed phase; the script should end with the equivalent of
    plot(ebsd(dominantPhase), ebsd(dominantPhase).orientations) so running
    the script immediately shows something instead of just variables
 -> DONE: dominant phase read straight from the phase table's own Plot
    checkbox column (the same one fillPhaseTable pre-checks for the
    largest indexed phase), not re-derived; template's final section
    plots `plot(ebsd('{dominantMineral}'),ebsd('{dominantMineral}').orientations)`
 -> verified end-to-end: generated script executed in a fresh session,
    produced the expected IPF colorkey message and no errors

29. [profiled, DONE] app startup is slow (measured 22.4s wall
    clock in this environment) - fix: build tab content
    (axes) lazily on first selection instead of all upfront
 -> profiled via MATLAB's profiler around import_wizard construction.
    Breakdown:
    - WebView/canvas-engine one-time bootstrap (HTMLCanvasPlugin,
      Channel.open, webwindow.*): ~5-8s - likely unavoidable MATLAB App
      Designer infrastructure (Chromium-based renderer spin-up)
    - createTabs/createPlotTab: 3.94s / 3.52s total, building all 8
      uiaxes upfront (Map, IPF x3, PF x3, Images) - ~0.88s per axes,
      paid whether or not the user ever visits that tab. This is the
      real, repeated, avoidable cost - NOT PFTabSizeChanged (the
      function literally named "resizing"), which is trivial
      (0.0016s total) despite the "axes resizing" description
    - two forced-sync points show large *total* (not self) time:
      setImportStatus's unconditional drawnow (~line ~596, 7.41s total)
      and the startup focus(app.FileTree) call (createComponents ~line
      150, 4.07s total) - both likely pull forward deferred rendering
      work early rather than costing that much themselves
 -> tension with existing intent: createComponents has a comment
    explaining the current eager-build choice - built right away so the
    "substantial one-time renderer boot cost... happens asynchronously
    while the user is still browsing for a file" instead of delaying the
    first plot. The 22.4s measured total suggests that overlap isn't
    buying much in practice (or the user waits for it regardless)
 -> DECIDED: switch to lazy-on-select tab construction - build a tab's
    axes the first time it's actually selected, not all 8 upfront in
    createTabs/createPlotTab. Implementation needs care: every function
    that currently assumes app.MapAxes/IPFAxes/PFAxes/ImagesAxes already
    exist (updatePlot, plotPoleFigures, plotImages, resetAxes, and the
    other places that write directly to these axes handles) must either
    trigger the lazy build first or be called only after
    TabSelectionChanged has ensured the selected tab's axes exist
 -> DONE: tab CONTAINERS (uitab + titles/colors + cheap uicontrols like
    the PF tab's Miller fields) still get built eagerly in createTabs -
    only the uiaxes(...) calls themselves are deferred, into a new
    `ensureTabAxesBuilt(app, tab)` that lazily builds axes into a stored
    "parent" gridlayout (new MapAxesParent/IPFAxesParent/ImagesAxesParent
    properties; PFAxes reuses the existing PFGrid). Called once, at the
    top of updatePlot - the single place every tab switch funnels through,
    both interactive (TabSelectionChanged) and programmatic
    (importEBSDData/OptTreeSelectionChanged both call updatePlot right
    after setting TabGroup.SelectedTab)
 -> found + handled a hard dependency along the way: populateMapTabs
    (called after every import) assumes app.MapAxes(1) - the Phase Map
    tab's axes - already exists, regardless of whether the user ever
    visited that tab. Since the default post-import view is IPF Z, not
    Phase Map, this would otherwise index into an empty array and error.
    Fixed by calling ensureTabAxesBuilt(app, app.MapTabs(1)) explicitly
    at the top of populateMapTabs, forcing that one group built whenever
    a file is (re-)imported, same as IPF gets forced by the default-view
    switch - so in the common "import and look at the default view" flow,
    Map(1) and IPF(3) axes still get built right away, but Pole Figures
    (3) and Images (1) stay genuinely deferred until visited. The net
    effect asked for is achieved either way: none of the 8 axes are built
    during pure app construction/startup anymore, only from import
    onward, since createTabs/createImagesTab no longer create any uiaxes
    themselves
 -> also handled: createImagesTab recreates the Images tab (and used to
    eagerly rebuild its axes) on every import to keep it last in the tab
    order - now it also explicitly clears app.ImagesAxes to empty each
    time, since the old handle becomes invalid once the old tab is
    deleted and would otherwise look like "already built" to
    ensureTabAxesBuilt's isempty check
 -> per-property map tabs (populateMapTabs, appended after import, one
    per ebsd property) were intentionally left eager (still use the
    original createPlotTab, unchanged) - they're never part of the
    startup cost this item was about, so deferring them further wasn't
    worth the added complexity
 -> verified: constructed the app and confirmed MapAxes/IPFAxes/PFAxes/
    ImagesAxes are all unbuilt before any import; imported real data and
    confirmed IPF axes (the default view) are built while Pole
    Figures/Images stay unbuilt; switched to each of Phase Map/Pole
    Figures/Images and confirmed each builds its axes on that switch and
    plots correctly; re-imported a second file and cycled through every
    resulting map tab with no errors. Construction wall time dropped from
    the previously profiled 22.4s to 14.66s in this environment (not
    directly comparable run-to-run, but consistent with removing the
    eager 8-axes-upfront cost from the startup path)

30. move "Coordinate systems" into the top-right area, fixed width and
    height (not flexible) -- DONE
 -> DECIDED (placement): the top row of RightLayout becomes three
    columns instead of two - PhaseTable (fixed width, left), OptTree
    (flexible width, middle), CoordinatePanel (fixed width, right).
    PhaseTable's width also changes from flexible ('2x') to fixed as
    part of this - currently createRightPanel (~line 316) has
    RightLayout ColumnWidth={'2x','1x'} with PhaseTable in column 1 and
    OptTree in column 2; becomes 3 columns with CoordinatePanel moved
    out of LeftLayout (currently row 3, see createCoordinateControls
    ~line 213) into the new column 3
 -> CoordinatePanel's own internal CoordinateLayout currently has
    RowHeight={22,30,'1x'} (~line 224) - the 3rd row (MapImage/EulerImage
    icons) is flexible; making the whole panel a fixed height too means
    this inner row needs a fixed height instead of '1x'
 -> LeftLayout loses a row once CoordinatePanel moves out (currently
    {'1x', 118, 210, 80} for FileBrowserPanel/CurrentData/CoordinatePanel/
    buttonGrid, ~line 122) - becomes 3 rows, and row indices for
    CurrentData/buttonGrid need renumbering accordingly
 -> DONE: RightLayout ColumnWidth is now {665,'1x',300} (PhaseTable fixed
    to fit its own 10 column widths, OptTree flexible, CoordinatePanel
    fixed); TabGroup now spans columns [1 3]; CoordinateLayout's image row
    changed from '1x' to a fixed 120; LeftLayout is now 3 rows
    {'1x', 118, 80} with createCoordinateControls's call moved after
    createRightPanel (it now builds into RightLayout, which must exist
    first) and CurrentData/buttonGrid renumbered to rows 2/3
 -> verified: constructed the app, imported real data, and confirmed every
    Layout.Row/Column and RowHeight/ColumnWidth matches the above, that
    CoordinatePanel is no longer a LeftLayout child, and that the
    coordinate dropdowns still function after the move

**** round 4 ****

31. in the PhaseTable, the "Plot" column header should not get the
    editable-marker pencil mark -- DONE
 -> fillPhaseTable (~line 817-824): every column whose ColumnEditable is
    true gets ' ✎' appended to its header text, to hint that double-
    clicking a cell there does something. Plot (column 1,
    ColumnEditable=true, ~line 780ish) is a checkbox, not a text/value
    cell to double-click - its editability is already obvious from being
    a checkbox, so the pencil is redundant noise there specifically
 -> fix: exclude column 1 from `editableCols` before appending the marker
    (Mineral, the other editable column, keeps its pencil)
 -> DONE, together with item 36 (Color also needed adding, not excluding)
    - final header row verified: Plot, Phase, Mineral ✎, Pixels, %,
    Symmetry, a, b, c, Color ✎

32. in the PhaseTable, the Phase column's integers should be centered
    (currently right-aligned) -- DONE
 -> fillPhaseTable ~line 779: `addStyle(app.PhaseTable,
    uistyle('HorizontalAlignment', 'right'), 'column', 2:10)` blanket
    right-aligns every column except Plot, including Phase (column 2,
    the small phaseMap integer id) - needs its own
    'HorizontalAlignment','center' style instead of the shared right-align
    one
 -> DONE: split into `addStyle(...,'center'...,'column',2)` +
    `addStyle(...,'right'...,'column',3:10)`

33. [REVISED, DONE] the file property table (CurrentData) in the left panel
    should grow only a little (not 150% larger as originally asked - that
    part is superseded), and its rows should become:
    File, Grid (Property column literally says "Square Grid" or
    "Hex Grid" depending on which it is, Value is the pixel dimensions),
    Resolution (new, separate row - the dx/dHex step size, split out of
    the combined grid sentence), Vendor, File size (new row, not
    currently shown at all), Created (date)
 -> current updateCurrentDataInfo (~line 1212-1238) rows are: File,
    Coordinates (spatial extent in scanUnit), Grid (one combined sentence
    from gridInfoLabel, ~line 1246, e.g. "Hex grid: 1000 x 500 pixel,
    dHex = 60 µm" - prefix/dims/resolution all smushed into one Value
    string), Vendor, Created
 -> fix shape: split gridInfoLabel's single sentence into two rows -
    Property="Square Grid"/"Hex Grid" (the prefix, dynamic per grid type)
    with Value = "<nx> x <ny> pixel", and a separate Property="Resolution"
    row with Value = the existing stepTxt (dHex=.../dx=...,dy=...)
 -> new: a "File size" row - not computed anywhere currently; straight
    forward via `dir(char(app.LoadedFilePath)).bytes`, human-formatted
    (e.g. KB/MB)
 -> DECIDED: the existing "Coordinates" row (spatial extent) stays as-is,
    alongside the new/split rows - it just wasn't restated in the row
    list, not meant for removal. Final row order: File, Coordinates,
    Grid, Resolution, Vendor, File size, Created
 -> DECIDED: CurrentData's LeftLayout row height goes from 118px to 160px
    (row 2 of {'1x',118,80} -> {'1x',160,80})
 -> DONE: gridInfoLabel split into a `gridInfo` function returning
    [gridLabel, dimsTxt, resolutionTxt] separately; new fileSizeLabel
    helper (dir(...).bytes, human-formatted KB/MB/GB); verified end-to-end
    on Forsterite.ctf - row order File/Coordinates/Square Grid ("732 x 336
    pixel")/Resolution ("dx = 50 µm")/Vendor/File size ("13.3 MB")/Created,
    exactly as decided

34. [WITHDRAWN] ebsd.opt's "header" field should stay in the OptTree
    (upper-middle treeview) - NOT moved to the CurrentData property table
    as originally asked in this same round. No change needed here;
    superseded by this revision.

35. generated script: if a phase's symmetry is cubic, orthorhombic,
    trigonal, tetragonal or hexagonal, the crystalSymmetry(...) call
    should not specify the angles argument -- DONE
 -> confirmed via geometry/@crystalSymmetry/crystalSymmetry.m ~line 154-
    162: when the angles argument is omitted, the constructor defaults to
    `lattice.defaultAngles` (geometry/latticeType.m ~line 18-27) - exactly
    [90,90,90] for cubic/orthorhombic/tetragonal and [90,90,120] for
    trigonal/hexagonal, i.e. precisely the angles the wizard would
    otherwise have written out explicitly for these 5 systems. cs.lattice
    (geometry/@symmetry/symmetry.m ~line 76) exposes this as a
    latticeType enum on any crystalSymmetry
 -> monoclinic/triclinic must keep explicit angles - their angles vary
    per material (e.g. Diopside's beta=105.6 in the current test data) and
    are not implied by the point group, unlike the other 5
 -> fix: in ExportScriptButtonPushed's crystalSymmetry-rendering branch
    (~line 1642-1650), only include the `[%.1f, %.1f, %.1f]` angle
    argument when `~ismember(cs.lattice, [latticeType.cubic,
    latticeType.orthorhombic, latticeType.trigonal, latticeType.tetragonal,
    latticeType.hexagonal])`
 -> DONE: verified end-to-end on Forsterite.ctf - Forsterite/Enstatite
    (mmm/orthorhombic) and Silicon (m-3m/cubic) correctly omit the angle
    argument; Diopside (12/m1/monoclinic, beta=105.6) correctly keeps
    `[90.0, 105.6, 90.0]`

36. the PhaseTable's Color column should also get the pencil
    editable-marker in its header, and be made slightly wider to fit it
    -- DONE
 -> the Color column (10th, ColumnWidth 45px) is edited by clicking the
    swatch cell, handled in PhaseTableCellSelection (~line 1439-ish,
    intercepts clicks on column 10 and opens uisetcolor) - not through
    normal cell editing, so ColumnEditable(10) is false and the pencil-
    marking loop in fillPhaseTable (~line 821-823, driven by
    `find(app.PhaseTable.ColumnEditable)`) never marks it, even though
    it's just as "click to edit" as Mineral or Plot
 -> fix: add column 10 to the set of columns that get the pencil suffix
    (can't just flip ColumnEditable(10) to true, since that would turn on
    uitable's own in-place text editing for the color swatch cell, which
    isn't wanted - the marker and the ColumnEditable flag need to be
    decoupled for this one column)
 -> widen PhaseTable.ColumnWidth's 10th entry (currently 45, same as Plot)
    enough to fit "Color ✎" without clipping - Plot's header has no text
    so it can stay narrow, Color's can't
 -> DONE: editableCols now `union(setdiff(find(ColumnEditable),1), 10)`;
    Color's ColumnWidth 45 -> 60

37. [bug fix, DONE] optValuePreview (OptTree leaf-node preview text)
    crashed when an ebsd.opt field was a small non-scalar numeric array
    (e.g. a 2x1 BoundingBoxSize vector)
 -> root cause: `txt = ['[' strjoin(string(size(value)),'x') ' '
    class(value) ']']` (~line 807) mixed char literals with a string
    scalar (strjoin on a string array returns string, not char) inside
    `[...]` - MATLAB's `[...]` concatenation promotes ALL operands to a
    string ARRAY (one element per operand) whenever any operand is a
    string, rather than concatenating into a single string. So this
    produced a 1x5 string array instead of "[2x1 single]"; the caller's
    `[field ': ' optValuePreview(...)]` (populateOptNode ~line 793)
    compounded it further into a 1x7 string array, which uitreenode's
    Text property rejects, erroring populateOptNode/populateImagesSelector
    outright for any ebsd.opt struct containing such a field
 -> fix: replaced the `[...]` concatenation with `sprintf('[%s %s]', ...)`,
    which coerces string arguments to char correctly
 -> improvement (suggested alongside the fix): small vectors (<=10
    elements) now show their actual values instead of just a size/class
    placeholder - `num2str(value(:)')`, transposing a column vector to a
    row first so it reads left-to-right in the tree like everything else.
    Larger vectors and non-vector matrices still fall back to the
    `[MxN class]` placeholder
 -> verified: the exact reported case (2x1 single) now renders as
    "BoundingBoxSize: 20.3787       15.284" with no error; also checked
    scalar, row vector, 20-element vector (falls back correctly), 3x4
    matrix (falls back correctly), and logical vector

38. [DONE] the CurrentData "Resolution" row should be renamed "Step Size"
    and show the plain step size value, no "dx = "/"dHex = " label
 -> gridInfo (~line 1326): resolutionTxt was built as `['dHex = '
    xnum2str(dHex) ' ' u]` / `['dx = ' xnum2str(dx) ' ' u]` /
    `['dx = ' xnum2str(dx) ', dy = ' xnum2str(dy) ' ' u]`
 -> DONE: labels dropped - now just `[xnum2str(dHex) ' ' u]` /
    `[xnum2str(dx) ' ' u]`; the dx~=dy case (non-square pixel spacing)
    renders as `[xnum2str(dx) ' x ' xnum2str(dy) ' ' u]` (e.g. "60 x 80
    µm"), matching the "<nx> x <ny> pixel" style already used for the
    Grid row's dimensions rather than reintroducing dx/dy labels; row's
    Property renamed 'Resolution' -> 'Step Size' in updateCurrentDataInfo

39. [DONE] the generated script's Z-Values section can be removed
    entirely
 -> templates/import/loadEBSDtemplate.m had a "%% Z-Values" section
    (`Z = {Z-values};`) and passed `{Z}` as an EBSD.load(...) argument;
    ExportScriptButtonPushed had two corresponding replaceMarkup calls
 -> DONE: removed the "%% Z-Values" heading + Z assignment from the
    template, removed the {Z} argument from the EBSD.load(...) call
    (now `EBSD.load(fname,csList,{options}, ...)`), and removed both
    replaceMarkup('{Z-values}',...)/replaceMarkup('{Z}',...) calls from
    ExportScriptButtonPushed; verified the generated script still
    executes correctly (EBSD.load, sanity plot) with no Z-related tokens
    left over

40. [DONE] the CurrentData (file property) table needed more height -
    with 7 rows (after item 33/38), about 1.5 rows were being clipped at
    the 160px set for item 33
 -> LeftLayout row 2 (CurrentData's row) bumped 160px -> 210px; verified
    the table's actual rendered Position height matches 210px with all 7
    rows (File/Coordinates/Grid/Step Size/Vendor/File size/Created)