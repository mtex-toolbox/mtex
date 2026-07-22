**** import_wizzard3 ****

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
    just want to explore it -- still open, not done

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

14. [needs profiling] replotting pole figures after changing Euler
    coordinates takes surprisingly long
 -> plotPoleFigures (~line 856) is already supposed to avoid a full
    recompute here: per the comment at ~line 879-883, an Euler-correction-
    only change should just rotate the cached ODF (app.PFODF = rotate(...),
    ~line 890-892) instead of recomputing calcDensity from scratch - this
    was the "DONE" item 3 fix from round 1
 -> since it's still slow, candidate suspects to check by actually
    profiling: (a) is odfKey/cache invalidation (~line 885-889) really
    skipping calcDensity here, or is something making it look like a
    cache miss; (b) is SO3Fun rotate() itself the bottleneck; (c) is it
    the per-axis pole figure redraw (resetAxes + plot, ~line 896 onward,
    x3 or more axes) rather than the ODF step at all

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