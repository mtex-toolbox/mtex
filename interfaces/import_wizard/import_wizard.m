classdef import_wizard < matlab.apps.AppBase
  % An App Designer app that browses a folder, imports the EBSD data it
  % finds and shows the result, so that a file can be checked before any
  % script is written. It generates the import code for the choices made.
  %
  % Syntax
  %   import_wizard
  %
  % See also
  % EBSD/load PoleFigure/load EBSDImport
  %

  properties (Access = public)
    UIFigure                       matlab.ui.Figure
    MainLayout                     matlab.ui.container.GridLayout
    LeftPanel                      matlab.ui.container.Panel
    LeftLayout                     matlab.ui.container.GridLayout
    RightPanel                     matlab.ui.container.Panel
    RightLayout                    matlab.ui.container.GridLayout

    FileBrowserPanel               matlab.ui.container.Panel
    FileBrowserLayout              matlab.ui.container.GridLayout
    UpFolderButton                 matlab.ui.control.Button
    BrowseFolderButton             matlab.ui.control.Button
    CurrentPathLabel               matlab.ui.control.Label
    FileTree                       matlab.ui.container.Tree
    ImportStatusLabel              matlab.ui.control.Label       % hint / loading status below the file tree
    DataSetListLabel               matlab.ui.control.Label
    DataSetList                    matlab.ui.control.ListBox     % everything the selected file offers to import:
                                                                 % its data sets times the recorded / post
                                                                 % processed versions. Selecting one imports it.
    PhaseTable                     matlab.ui.control.Table
    VariableNameField              matlab.ui.control.EditField   % variable name for "Import to variable"
    ExportButton                   matlab.ui.control.Button
    ScriptArea                     matlab.ui.control.TextArea    % the import script, live, see refreshScript


    TabGroup                       matlab.ui.container.TabGroup
    MapTabs                        matlab.ui.container.Tab       % phase map + one tab per property
    MapAxes                        = gobjects(1,0)               % parallel to MapTabs; built lazily, see
                                                                 % ensureTabAxesBuilt - hence a graphics array
                                                                 % with holes rather than a UIAxes array
    IPFTabs                        matlab.ui.container.Tab       % 1x3 array: IPF X / Y / Z
    IPFAxes                        = gobjects(1,0)               % parallel to IPFTabs; each axes is built only
                                                                 % after its own tab is selected
    PFTab                          matlab.ui.container.Tab
    PFGrid                         matlab.ui.container.GridLayout
    PFTitle                        matlab.ui.control.Label       % the phase the pole figures show
    ImagesTab                      matlab.ui.container.Tab
    PFMillerField                  matlab.ui.control.EditField   % 1x3 array
    KeyAxes                        matlab.ui.control.UIAxes      % IPF key of the phase clicked in PhaseTable, see plotKey
    PFAxes                         matlab.ui.control.UIAxes      % 1x3 array; built lazily, see ensureTabAxesBuilt
    ImagesAxes                     matlab.ui.control.UIAxes      % built lazily, see ensureTabAxesBuilt
    OptTree                        matlab.ui.container.Tree      % file info and ebsd.opt, below the file browser

    CoordinateLayout               matlab.ui.container.GridLayout
    MapFrameAxes                   matlab.ui.control.UIAxes  % the two reference frame pictograms,
    EulerFrameAxes                 matlab.ui.control.UIAxes  % drawn by refFrameGeometry like the map's
    SideHolders                    matlab.ui.container.Panel % the cells of KeyAxes and the two pictograms, see ensureSideAxes
    ConventionChooser              matlab.ui.container.Panel % the eight conventions dropped down
    ChooserAxes                    matlab.ui.control.UIAxes  % below a pictogram, see openChooser
  end

  properties (Access = private)
    ebsd
    Color cell = {}
    LastSig struct = struct()   % per-tab render signatures, see invalidateAllSigs
    MapNames cell = {}          % map view names parallel to MapTabs
    FontSize double = 14
    CurrentFolder string = ""
    LoadedFilePath string = "" % Keeps track of the path of the imported EBSD file
    PreviewFilePath string = "" % file the data set list describes - the
                                % selected one, imported or only previewed
    DataSetEntries struct = struct('label',{},'dataSet',{})
                                % one entry per row of DataSetList: which
                                % data set of the file and which version
    SelectedImagePath cell = {} % field-name path of the OptTree's selected image node
    KeyPhase double = []        % the phase KeyAxes shows
    IPFKeys cell = {}           % precomputed ipfColorKey per phase, shared
                                % by the IPF X/Y/Z tabs (they only differ by
                                % the ipfDirection)
    WarmUpTimer = []            % see scheduleWarmUp
    WarmUpStep double = 0       % which warm-up step runs on the next tick
    PFODF = []                  % cached ODF for the pole figure tab
    PFODFKey string = ""        % cache key describing what PFODF was computed from
    PFODFCorr = []              % Euler correction the cached ODF refers to
    PFSystem = ''               % the crystal system the pole figures show, see millersFor
    TypedMillers struct = struct() % the Miller indices typed, per crystal system
    MapIdx double = 1           % the map and Euler conventions, rows of CoordinateSystems
    EulerIdx double = 1
    ChooserFor string = ""      % "map" or "euler", the frame the chooser sets
    ImportTimer = []            % imports the file the selection rests on, see FileTreeSelectionChanged
    Importing logical = false   % an import is running, a resting selection waits
  end

  properties (Constant, Access = private)
    CoordinateSystems = table( ...
      ["y↑→x" "y↓→x" "x↑→y" "x↓→y" "x←↑y" "x←↓y" "y←↑x" "y←↓x"]', ...
      [plottingConvention( zvector,  xvector)
      plottingConvention(-zvector,  xvector)
      plottingConvention(-zvector,  yvector)
      plottingConvention( zvector,  yvector)
      plottingConvention(-zvector, -xvector)
      plottingConvention( zvector, -xvector)
      plottingConvention( zvector, -yvector)
      plottingConvention(-zvector, -yvector)], ...
      'VariableNames', {'Label', 'how2plot'})

    % tab label colors: one color per plot category so that map, IPF,
    % pole figure and image tabs are distinguishable at a glance
    TabColors = struct( ...
      'Maps',     [0.15 0.45 0.85], ...
      'IPF',      [0.20 0.60 0.25], ...
      'PF',       [0.60 0.35 0.75], ...
      'Images',   [0.90 0.45 0.15], ...
      'Disabled', [0.55 0.55 0.55])

    % the Euler frame pictogram, the map frame one takes the theme's foreground
    EulerFrameColor = [0.85 0.10 0.10]
  end

  methods (Access = private)
    function createComponents(app)
      leftWidth = app.leftPanelWidth();

      % come up at the final size, so everything below is laid out only once
      app.UIFigure = uifigure('Visible', 'off', 'Position', screenArea(app));
      app.UIFigure.WindowState = 'maximized';
      app.UIFigure.Name = 'MTEX Import Wizard';
      app.UIFigure.Icon = fullfile(fileparts(mfilename('fullpath')), 'icon.png');
      app.UIFigure.WindowKeyPressFcn = createCallbackFcn(app, @WizardKeyPress, true);

      app.MainLayout = uigridlayout(app.UIFigure, ...
        'ColumnWidth', {leftWidth, '1x'}, ...
        'RowHeight', {'1x'}, ...
        'ColumnSpacing', 12, ...
        'Padding', [12 10 12 12]);

      app.LeftPanel = uipanel(app.MainLayout, 'BorderType', 'none');
      app.LeftPanel.Layout.Row = 1;
      app.LeftPanel.Layout.Column = 1;

      app.LeftLayout = uigridlayout(app.LeftPanel, ...
        'ColumnWidth', {'1x'}, ...
        'RowHeight', {'3x', '2x', 35}, ...
        'RowSpacing', 10, ...
        'Padding', [0 0 0 0]);

      createFileBrowser(app)

      % the file's own rows, then the full ebsd.opt structure (see
      % updateCurrentDataInfo) - selecting an image-shaped field shows it
      % in the Images tab (see OptTreeSelectionChanged)
      app.OptTree = uitree(app.LeftLayout, ...
        'FontSize', app.FontSize - 1, ...
        'SelectionChangedFcn', createCallbackFcn(app, @OptTreeSelectionChanged, true));
      app.OptTree.Layout.Row = 2;
      uitreenode(app.OptTree, 'Text', 'Status: No EBSD data loaded', ...
        'NodeData', struct('Type','Field'));

      app.RightPanel = uipanel(app.MainLayout, 'BorderType', 'none');
      app.RightPanel.Layout.Row = 1;
      app.RightPanel.Layout.Column = 2;

      % everything is built before the window is shown, so that its first
      % paint is the finished layout rather than a series of partial ones
      createRightPanel(app)
      createCoordinateControls(app)
      createExportButtonsPanel(app)
      app.UIFigure.Visible = 'on';
      drawnow

      % start with the keyboard focus on the file browser, so a file can
      % be picked with the arrow keys and loaded with Enter right away
      try focus(app.FileTree); catch, end

      % the rest of what an import needs, once the window is live - see
      % scheduleWarmUp
      scheduleWarmUp(app)
    end

    function createFileBrowser(app)
      % Compact inline file browser (top-left): a uitree showing folders
      % and EBSD files of the current directory, plus a back button and
      % path label for navigation. Single-clicking a folder only expands
      % its branch in place; double-clicking (or pressing Enter) descends
      % into a folder or imports a file, Backspace navigates up. Merely
      % selecting a file (click or arrow keys, see SelectionChangedFcn)
      % triggers a fast headerOnly preview into the info tree below,
      % without touching the actually imported/plotted data set.
      app.FileBrowserPanel = uipanel(app.LeftLayout, 'BorderType', 'line');
      app.FileBrowserPanel.Layout.Row = 1;

      app.FileBrowserLayout = uigridlayout(app.FileBrowserPanel, ...
        'ColumnWidth', {30, 30, '1x'}, ...
        'RowHeight', {24, '1x', 22, 18, 92}, ...
        'ColumnSpacing', 4, ...
        'RowSpacing', 2, ...
        'Padding', [4 4 4 4]);

      app.UpFolderButton = uibutton(app.FileBrowserLayout, 'push', ...
        'Text', char(8593), ... % "↑" fallback if the icon cannot be built
        'Tooltip', 'Up one folder', ...
        'FontWeight', 'bold', ...
        'ButtonPushedFcn', createCallbackFcn(app, @UpFolderButtonPushed, true));
      app.UpFolderButton.Layout.Row = 1;
      app.UpFolderButton.Layout.Column = 1;

      upIcon = treeIconPath(app, 'up');
      if ~isempty(upIcon)
        app.UpFolderButton.Icon = upIcon;
        app.UpFolderButton.Text = '';
      end

      app.BrowseFolderButton = uibutton(app.FileBrowserLayout, 'push', ...
        'Text', char(8230), ...
        'Tooltip', 'Choose a folder', ...
        'FontWeight', 'bold', ...
        'ButtonPushedFcn', createCallbackFcn(app, @BrowseFolderButtonPushed, true));
      app.BrowseFolderButton.Layout.Row = 1;
      app.BrowseFolderButton.Layout.Column = 2;

      folderIcon = treeIconPath(app, 'folder');
      if ~isempty(folderIcon)
        app.BrowseFolderButton.Icon = folderIcon;
        app.BrowseFolderButton.Text = '';
      end

      app.CurrentPathLabel = uilabel(app.FileBrowserLayout, ...
        'Text', '', ...
        'FontSize', app.FontSize - 2, ...
        'Interpreter', 'none');
      app.CurrentPathLabel.Layout.Row = 1;
      app.CurrentPathLabel.Layout.Column = 3;

      app.FileTree = uitree(app.FileBrowserLayout, ...
        'FontSize', app.FontSize - 1, ...
        'ClickedFcn', createCallbackFcn(app, @FileTreeClicked, true), ...
        'NodeExpandedFcn', createCallbackFcn(app, @FileTreeNodeExpanded, true), ...
        'DoubleClickedFcn', createCallbackFcn(app, @FileTreeDoubleClicked, true), ...
        'SelectionChangedFcn', createCallbackFcn(app, @FileTreeSelectionChanged, true));
      app.FileTree.Layout.Row = 2;
      app.FileTree.Layout.Column = [1 3];

      app.ImportStatusLabel = uilabel(app.FileBrowserLayout, ...
        'HorizontalAlignment', 'center', 'FontSize', app.FontSize - 2);
      app.ImportStatusLabel.Layout.Row = 3;
      app.ImportStatusLabel.Layout.Column = [1 3];
      setImportStatus(app, 'idle')

      createDataSetControls(app)

      navigateToFolder(app, pwd)
    end

    function createDataSetControls(app)
      % Everything the file selected in the tree above offers to import,
      % as one list right below it: the data sets of a project file
      % holding several maps, each once for every version the vendor
      % stored - as recorded by the detector and as cleaned up by their
      % software. The list is filled from the headerOnly preview that
      % already runs on selection (see populateDataSetList) and picking a
      % row imports it, no double-click needed.
      app.DataSetListLabel = uilabel(app.FileBrowserLayout, ...
        'Text', 'Data sets', ...
        'FontWeight', 'bold', ...
        'FontSize', app.FontSize - 2);
      app.DataSetListLabel.Layout.Row = 4;
      app.DataSetListLabel.Layout.Column = [1 3];

      app.DataSetList = uilistbox(app.FileBrowserLayout, ...
        'Items', {}, ...
        'Enable', 'off', ...
        'FontSize', app.FontSize - 2, ...
        'Tooltip', 'Select what to import from the file above', ...
        'ValueChangedFcn', createCallbackFcn(app, @DataSetListValueChanged, true));
      app.DataSetList.Layout.Row = 5;
      app.DataSetList.Layout.Column = [1 3];
    end

    function createCoordinateControls(app)
      % the two frames stacked left of the phase table, each a pictogram
      % that opens the chooser of the eight conventions when clicked
      app.CoordinateLayout = uigridlayout(app.RightLayout, ...
        'ColumnWidth', {'1x'}, 'RowHeight', {'1x', '1x'}, ...
        'RowSpacing', 0, 'Padding', [0 0 0 0]);
      app.CoordinateLayout.Layout.Row = 1;
      app.CoordinateLayout.Layout.Column = 1;

      for row = 1:2
        app.SideHolders(row+1) = uipanel(app.CoordinateLayout, 'BorderType', 'none');
        app.SideHolders(row+1).Layout.Row = row;
      end
      app.UIFigure.WindowButtonDownFcn = @(~,~) closeChooserOutside(app);

      % the session convention until a file states one of its own - drawn
      % by warmUp, a text sized before the layout arrives comes out huge
      app.MapIdx = closestCoordinateIndex(app, plottingConvention.default.rot);
      app.EulerIdx = app.MapIdx;
    end

    function ensureSideAxes(app)
      % the IPF key and the two pictograms, built once the window is up -
      % the first uiaxes of a session starts the canvas, which would delay
      % the window by seconds
      if ~isempty(app.KeyAxes), return, end
      app.KeyAxes = uiaxes(app.SideHolders(1), 'Units', 'normalized', 'Position', [0 0 1 0.88]);
      axis(app.KeyAxes, 'off')
      app.MapFrameAxes = pictogramAxes(app, app.SideHolders(2));
      app.MapFrameAxes.ButtonDownFcn = @(~,~) openChooser(app, "map");
      app.EulerFrameAxes = pictogramAxes(app, app.SideHolders(3));
      app.EulerFrameAxes.ButtonDownFcn = @(~,~) openChooser(app, "euler");
      refreshCoordinateFrames(app)
    end

    function ax = pictogramAxes(~, parent)
      % a blank, unsheared canvas filling its parent with the plot box - a
      % grid child cannot, its PositionConstraint stays outerposition
      ax = uiaxes(parent, 'Units', 'normalized', ...
        'PositionConstraint', 'innerposition', 'InnerPosition', [0 0 1 1]);
      axis(ax, 'off', 'equal')
      ax.Toolbar.Visible = 'off';
      ax.PickableParts = 'all';   % an invisible axes takes clicks only so
      disableDefaultInteractivity(ax)
    end

    function createExportButtonsPanel(app)
      % import to a variable of the given name
      buttonGrid = uigridlayout(app.LeftLayout, ...
        'ColumnWidth', {'1x', '1x'}, ...
        'RowHeight', {35}, ...
        'Padding', [0 0 0 0], ...
        'ColumnSpacing', 10);
      buttonGrid.Layout.Row = 3;

      app.ExportButton = uibutton(buttonGrid, 'push', ...
        'ButtonPushedFcn', createCallbackFcn(app, @ExportButtonPushed, true), ...
        'FontWeight', 'bold', ...
        'FontSize', app.FontSize, ...
        'Text', 'Import to variable');
      app.ExportButton.Layout.Row = 1;
      app.ExportButton.Layout.Column = 1;

      app.VariableNameField = uieditfield(buttonGrid, 'text', ...
        'Value', 'ebsd', ...
        'FontSize', app.FontSize, ...
        'Tooltip', 'Variable name for "Import to variable"');
      app.VariableNameField.Layout.Row = 1;
      app.VariableNameField.Layout.Column = 2;
    end

    function createScriptPanel(app)
      % the import script of the choices made, live, with copy, save and
      % open in the editor below it
      g = uigridlayout(app.RightLayout, 'ColumnWidth', {'1x', 60, 60, 60}, ...
        'RowHeight', {'1x', 24}, 'Padding', [0 0 0 0], 'RowSpacing', 4, 'ColumnSpacing', 4);
      g.Layout.Row = 1;
      g.Layout.Column = 3;
      app.ScriptArea = uitextarea(g, 'Editable', 'off', 'FontName', 'Monospaced', ...
        'FontSize', app.FontSize - 3, 'WordWrap', 'off', ...
        'Value', {'% the import script appears here once a file is imported'});
      app.ScriptArea.Layout.Column = [1 4];
      labels = {'copy', 'save…', 'edit'};
      actions = {@copyScript, @saveScript, @editScript};
      for k = 1:3
        b = uibutton(g, 'Text', labels{k}, 'FontSize', app.FontSize - 2, ...
          'ButtonPushedFcn', @(~,~) actions{k}(app));
        b.Layout.Row = 2;
        b.Layout.Column = k + 1;
      end
    end

    function layoutTopRow(app)
      % the phase table at its natural width as long as the script keeps
      % 280 px, scrolling beyond that
      if app.RightPanel.Position(3) < 500, return, end   % the layout has not arrived
      natural = sum([app.PhaseTable.ColumnWidth{:}]) + 4;
      avail = app.RightPanel.Position(3) - 104 - 210 - 3*8 - 280;
      app.RightLayout.ColumnWidth = {104, max(300, min(natural, avail)), '1x', 210};
    end

    function createRightPanel(app)
      % row 1: the two reference frame pictograms stacked (added by
      % createCoordinateControls), PhaseTable, the script, KeyAxes; row 2:
      % TabGroup spanning all columns
      app.RightLayout = uigridlayout(app.RightPanel, ...
        'ColumnWidth', {104, 812, '1x', 210}, ...
        'RowHeight', {208, '1x'}, ...  % two pictograms of 104
        'RowSpacing', 8, ...
        'ColumnSpacing', 8, ...
        'Padding', [0 0 0 0]);

      % the crystal symmetry of a phase is edited here, see PhaseTableCellEdit
      app.PhaseTable = uitable(app.RightLayout, ...
        'ColumnEditable', [true false true false false true ...
                           true true true true true true true], ...
        'RowName', {}, ...
        'CellEditCallback', createCallbackFcn(app, @PhaseTableCellEdit, true), ...
        'CellSelectionCallback', createCallbackFcn(app, @PhaseTableCellSelection, true), ...
        'FontSize', app.FontSize - 1);
      app.PhaseTable.Layout.Row = 1;
      app.PhaseTable.Layout.Column = 2;
      % columns: Plot, Phase, Mineral, Pixels, %, Symmetry, a, b, c,
      % alpha, beta, gamma, Alignment - widths sized to their real content
      app.PhaseTable.ColumnWidth = ...
        {42, 48, 125, 70, 52, 78, 48, 48, 48, 52, 52, 52, 92};

      app.SideHolders(1) = uipanel(app.RightLayout, 'BorderType', 'none');
      app.SideHolders(1).Layout.Row = 1;
      app.SideHolders(1).Layout.Column = 4;

      createScriptPanel(app)
      createTabs(app)
      app.TabGroup.Layout.Column = [1 4];

      app.RightPanel.AutoResizeChildren = 'off';
      app.RightPanel.SizeChangedFcn = @(~,~) layoutTopRow(app);
      layoutTopRow(app)
    end

    function createTabs(app)
      % The plot area is a tab group, one tab and one axes per view, the
      % tab labels colored by category (maps, IPF, pole figures, images).
      % The tabs and their cheap controls are built here, the axes inside
      % each one the first time it is shown, see ensureTabAxesBuilt.
      app.TabGroup = uitabgroup(app.RightLayout, ...
        'SelectionChangedFcn', createCallbackFcn(app, @TabSelectionChanged, true));
      app.TabGroup.Layout.Row = 2;

      % create the tabs in display order, reordering them is slow

      % --- map tabs: the phase map now, one tab per property at import ---
      app.MapTabs = createLazyPlotTab(app, 'Phase Map', app.TabColors.Maps);
      app.MapNames = {'Phase Map'};

      % --- IPF tabs: one tab per direction, Z first -----------------------
      tz = createLazyPlotTab(app, 'IPF Z', app.TabColors.IPF);
      ty = createLazyPlotTab(app, 'IPF Y', app.TabColors.IPF);
      tx = createLazyPlotTab(app, 'IPF X', app.TabColors.IPF);
      app.IPFTabs = [tx, ty, tz];   % index 1/2/3 = direction X/Y/Z
      app.TabGroup.SelectedTab = tz;

      % --- Pole Figures tab: parallel axes, a Miller field above each -----
      app.PFTab = uitab(app.TabGroup, 'Title', 'Pole Figures', ...
        'ForegroundColor', app.TabColors.PF);
      % four rows: the phase, Miller fields, pole figure axes, filler
      gPF = uigridlayout(app.PFTab, ...
        'ColumnWidth', {'1x','1x','1x'}, 'RowHeight', {20, 26, '1x', 1}, ...
        'Padding', [6 6 6 6], 'RowSpacing', 2, 'ColumnSpacing', 6);
      app.PFGrid = gPF;
      app.PFTitle = uilabel(gPF, 'Text', '', 'FontSize', app.FontSize - 1);
      app.PFTitle.Layout.Column = [1 3];
      defaults = {'(100)','(010)','(001)'};
      for i = 1:3
        % the Miller field sits centered above its pole figure
        gField = uigridlayout(gPF, ...
          'ColumnWidth', {'1x', 22, 110, '1x'}, 'RowHeight', {'1x'}, ...
          'Padding', [0 0 0 0], 'ColumnSpacing', 4);
        gField.Layout.Row = 2; gField.Layout.Column = i;

        pencil = uilabel(gField, 'Text', char(9998), ... % "✎"
          'HorizontalAlignment', 'right', 'FontSize', app.FontSize, ...
          'Tooltip', 'Type Miller indices, e.g. (100)');
        pencil.Layout.Row = 1; pencil.Layout.Column = 2;

        app.PFMillerField(i) = uieditfield(gField, 'text', ...
          'Value', defaults{i}, 'HorizontalAlignment', 'center', ...
          'FontSize', app.FontSize, ...
          'Tooltip', 'Type Miller indices, e.g. (100)', ...
          'ValueChangedFcn', createCallbackFcn(app, @PFMillerChanged, true));
        app.PFMillerField(i).Layout.Row = 1; app.PFMillerField(i).Layout.Column = 3;
      end

      app.PFTab.AutoResizeChildren = 'off';
      app.PFTab.SizeChangedFcn = createCallbackFcn(app, @PFTabSizeChanged, true);
      PFTabSizeChanged(app, [])

      % the Images tab is appended by the first import, see populateMapTabs
    end

    function createImagesTab(app)
      % The images tab is always the last one. Since tabs can only be
      % appended (see the comment in createTabs), it is appended after the
      % property map tabs of an imported data set, see populateMapTabs -
      % which is also why it does not exist before the first import. Image
      % selection happens via the OptTree (see
      % OptTreeSelectionChanged), so this tab is just the
      % axes - built lazily, see ensureTabAxesBuilt.
      app.ImagesTab = uitab(app.TabGroup, 'Title', 'Images', ...
        'ForegroundColor', app.TabColors.Images);
      % the old axes died with the previous tab, clear the handle
      app.ImagesAxes = matlab.ui.control.UIAxes.empty;
    end

    function tab = createLazyPlotTab(app, tabTitle, color)
      % An empty tab - the axes inside it is built on demand, see
      % ensureTabAxesBuilt, and is parented to the tab itself.
      %
      % Not through a uigridlayout: a grid child starts at the 400x300
      % default and gets its size only at the next layout pass, so the
      % scale bar, which is laid out in data units, would be placed for the
      % wrong geometry. A normalized axes in the tab is at its full size
      % from the first render, and keeps a Position, see scaleBar.
      tab = uitab(app.TabGroup, 'Title', tabTitle, 'ForegroundColor', color);
    end

    function ax = createTabAxes(~, parent)
      % the axes of a single plot tab - full size from the first render,
      % see createLazyPlotTab
      ax = uiaxes(parent, 'Units', 'normalized', 'Position', [0 0 1 1], 'Visible', 'off');
    end

    function ensureTabAxesBuilt(app, tab)
      % axes are built lazily, the first time their tab is shown - this is
      % the single place that guarantees they exist before any plotting
      % code touches them. Called at the top of updatePlot, which every tab
      % switch funnels through: interactive (TabSelectionChanged) and
      % programmatic (both call updatePlot right after setting
      % TabGroup.SelectedTab, see importEBSDData/OptTreeSelectionChanged).
      % Idempotent - already-built groups are left untouched.
      %
      % The single plot tabs parent their axes straight to the tab, so it
      % is at its final size from the first render and the map is drawn
      % once - see createLazyPlotTab for why a uigridlayout is not used
      % there. The pole figure tab is the exception: its three axes share a
      % real grid with the Miller fields above them, so they do start at
      % the App Designer default 400x300 and only get their size when the
      % grid next runs. Let that happen before anything is drawn into them.
      mapIdx = find(app.MapTabs == tab, 1);
      if ~isempty(mapIdx)
        if numel(app.MapAxes) < mapIdx || ~isgraphics(app.MapAxes(mapIdx))
          app.MapAxes(mapIdx) = createTabAxes(app, app.MapTabs(mapIdx));
          drawnow('nocallbacks')
        end
      elseif ~isempty(app.IPFTabs) && any(tab == app.IPFTabs)
        ipfIdx = find(app.IPFTabs == tab,1);
        if numel(app.IPFAxes) < ipfIdx || ~isgraphics(app.IPFAxes(ipfIdx))
          app.IPFAxes(ipfIdx) = createTabAxes(app,app.IPFTabs(ipfIdx));
          drawnow('nocallbacks')
        end
      elseif ~isempty(app.PFTab) && tab == app.PFTab && isempty(app.PFAxes)
        for i = 1:3
          app.PFAxes(i) = uiaxes(app.PFGrid);
          app.PFAxes(i).Layout.Row = 3; app.PFAxes(i).Layout.Column = i;
        end
        % nocallbacks, the queued click must not re-enter the plotting
        drawnow('nocallbacks')
      elseif ~isempty(app.ImagesTab) && tab == app.ImagesTab && isempty(app.ImagesAxes)
        app.ImagesAxes = createTabAxes(app, app.ImagesTab);
        drawnow('nocallbacks')
      end
    end

    function scheduleWarmUp(app)
      % Do what the first import is certain to need while the user is
      % still looking for a file, instead of on the path from double
      % click to map.
      %
      % Two costs live there, both of them one-time: the axes of the IPF Z
      % and phase map tabs, which every import shows, and the first EBSD
      % map drawn in a session, which loads the plotting stack below it
      % (mapPlot, scaleBar, plotUnitCells, the canvas).
      %
      % A timer rather than a straight call, so the constructor returns
      % and the window is live while this runs. It is cancelled by any
      % real work (see cancelWarmUp): a timer callback fires on any
      % drawnow, and there are drawnows inside the import, so without
      % that this could run in the middle of one.
      %
      % One step per tick rather than all of it in one callback, because
      % MATLAB will not interrupt a callback that is already running: in
      % one blob, a user who double-clicks a file half way through waits
      % out the whole warm-up first. Between two ticks their click is
      % serviced, and the import then cancels whatever is left.
      cancelWarmUp(app)
      app.WarmUpStep = 0;
      app.WarmUpTimer = timer('Name', 'MTEXImportWizardWarmUp', ...
        'StartDelay', 0.3, 'Period', 0.1, ...
        'ExecutionMode', 'fixedSpacing', ...
        'TimerFcn', @(~,~) warmUp(app), ...
        'StopFcn', @(t,~) delete(t));  % so nothing of it outlives the run
      start(app.WarmUpTimer)
    end

    function cancelWarmUp(app)
      if isempty(app.WarmUpTimer) || ~isvalid(app.WarmUpTimer), return, end
      stop(app.WarmUpTimer)   % the StopFcn deletes it
      if isvalid(app.WarmUpTimer), delete(app.WarmUpTimer), end
      app.WarmUpTimer = [];
    end

    function warmUp(app)
      % see scheduleWarmUp - runs once, on an app that has not loaded
      % anything yet. Everything here is allowed to fail silently:
      % nothing in it is required for correctness, it only moves cost off
      % the import path.
      if ~isvalid(app) || isempty(app.UIFigure) || ~isvalid(app.UIFigure) ...
          || ~isempty(app.ebsd)
        cancelWarmUp(app); return
      end

      % the tab group fills the right panel once the layout has arrived,
      % an axes built earlier is resized and redrawn with it - wait 3 s at most
      if abs(app.TabGroup.Position(3) - app.RightPanel.Position(3)) > 1 && ...
          app.WarmUpTimer.TasksExecuted < 30, return, end

      app.WarmUpStep = app.WarmUpStep + 1;
      try
        switch app.WarmUpStep
          case 1
            % the key, the pictograms, and the axes of IPF Z, the view every import shows first
            ensureSideAxes(app)
            ensureTabAxesBuilt(app, app.IPFTabs(3))

          case 2
            % draw a dummy map once, to load and warm up the plotting stack
            ax = app.IPFAxes(3);
            ebsdWarm = EBSD(vector3d([0 1 0 1], [0 0 1 1], zeros(1,4)), ...
              rotation.id(4), ones(4,1), {crystalSymmetry('m-3m')}, struct());
            plot(ebsdWarm, 0.5*ones(4,3), 'parent', ax)
            resetAxes(app, ax)

          case 3
            % and a key once, to warm up the spherical plots
            plot(ipfColorKey(crystalSymmetry('mmm')).dirMap, 'parent', app.KeyAxes, 'resolution', 1.5*degree)
            resetAxes(app, app.KeyAxes)
        end
      catch
      end

      % last step - stop it, which disposes of the timer through its
      % StopFcn (see scheduleWarmUp)
      if app.WarmUpStep >= 3 && ~isempty(app.WarmUpTimer) && ...
          isvalid(app.WarmUpTimer)
        stop(app.WarmUpTimer)
      end
    end

    function navigateToFolder(app, folderPath)
      % Set folderPath as the new browser root and populate its children.
      if ~isfolder(folderPath)
        return
      end

      % the last three folders of the path, all of it in the tooltip
      app.CurrentFolder = string(folderPath);
      parts = split(app.CurrentFolder, filesep);
      parts = parts(parts ~= "");
      crumbs = strjoin(parts(max(1,end-2):end), " / ");
      if numel(parts) > 3, crumbs = "… / " + crumbs; end
      app.CurrentPathLabel.Text = char(crumbs);
      app.CurrentPathLabel.Tooltip = char(app.CurrentFolder);

      delete(app.FileTree.Children)
      populateFolderNode(app, app.FileTree, app.CurrentFolder)

      % keep keyboard focus on the tree so cursor navigation keeps working
      try
        if strcmp(app.UIFigure.Visible, 'on'), focus(app.FileTree); end
      catch
      end
    end

    function populateFolderNode(app, parentNode, folderPath)
      % Add one tree node per subfolder and per matching EBSD file inside
      % folderPath, directly under parentNode. Subfolders get a dummy
      % child so they show an expand arrow and are populated lazily.
      delete(parentNode.Children)

      listing = dir(folderPath);
      names = {listing.name};
      isHidden = startsWith(names, '.');
      listing = listing(~isHidden);
      % subfolders first, files last, each group alphabetically (the
      % second sort is stable, so the alphabetical order is preserved)
      [~, order] = sort(lower(string({listing.name})));
      listing = listing(order);
      [~, order] = sort(~[listing.isdir]);
      listing = listing(order);

      folderIcon = treeIconPath(app, 'folder');
      fileIcon = treeIconPath(app, 'ebsd');

      for k = 1:numel(listing)
        entry = listing(k);
        fullPath = fullfile(folderPath, entry.name);

        if entry.isdir
          % a folder that holds nothing visible is left out
          inside = dir(fullPath);
          if all(startsWith({inside.name}, '.')), continue, end
          folderNode = uitreenode(parentNode, ...
            'Text', entry.name, ...
            'NodeData', struct('Type', 'Folder', 'Path', fullPath));
          if ~isempty(folderIcon), folderNode.Icon = folderIcon; end
          % Dummy child so the node is expandable; replaced on expand.
          uitreenode(folderNode, 'Text', 'Loading...');
        elseif isEBSDFile(app, entry.name)
          fileNode = uitreenode(parentNode, ...
            'Text', [entry.name '   ' fileSizeLabel(app, fullPath)], ...
            'NodeData', struct('Type', 'File', 'Path', fullPath));
          if ~isempty(fileIcon), fileNode.Icon = fileIcon; end
        end
      end
    end

    function pth = treeIconPath(~, kind)
      % Lazily render and cache the 16x16 png icons for the file browser:
      % an amber folder, the same folder with an up arrow for the "up one
      % folder" button and a white page with a tiny colored phase map for
      % EBSD data files. Returns '' if the icon cannot be built. The
      % version suffix invalidates cached icons when the design changes.
      pth = char(fullfile(tempdir, ['mtex_wizard_icon_' kind '_v2.png']));
      if isfile(pth), return; end

      try
        n = 16;
        if strcmp(kind, 'ebsd')
          mask = false(n);
          mask(2:15, 3:14) = true;  % page
          fill = [1 1 1];
          edge = [0.45 0.45 0.45];
        else % folder / up
          mask = false(n);
          mask(6:14, 2:15) = true;  % body
          mask(4:6, 2:8) = true;    % tab
          fill = [0.99 0.80 0.30];
          edge = [0.75 0.55 0.12];
        end

        % fill color inside, edge color on the one pixel wide outline
        inner = mask & circshift(mask,[1 0]) & circshift(mask,[-1 0]) & ...
          circshift(mask,[0 1]) & circshift(mask,[0 -1]);
        img = ones(n, n, 3);
        for c = 1:3
          ch = img(:,:,c);
          ch(mask) = edge(c);
          ch(inner) = fill(c);
          img(:,:,c) = ch;
        end

        switch kind
          case 'ebsd'
            % 2x2 pixel blocks resembling a small EBSD phase map
            colors = [0.85 0.33 0.10; 0.00 0.45 0.74; 0.47 0.67 0.19; 0.93 0.69 0.13];
            ci = 0;
            for r = 5:2:11
              ci = ci + 1; % shift the color cycle from row to row
              for c = 5:2:11
                ci = ci + 1;
                col = colors(mod(ci-1, 4)+1, :);
                img(r:r+1, c:c+1, :) = reshape(col, 1, 1, 3) .* ones(2,2,3);
              end
            end
          case 'up'
            % black up arrow on the folder body
            arrow = false(n);
            arrow(7, 8:9) = true;     % tip
            arrow(8, 7:10) = true;
            arrow(9, 6:11) = true;    % head
            arrow(10:13, 8:9) = true; % shaft
            for c = 1:3
              ch = img(:,:,c);
              ch(arrow) = 0.1;
              img(:,:,c) = ch;
            end
        end

        imwrite(img, pth, 'Alpha', double(mask))
      catch
        pth = '';
      end
    end

    function tf = isEBSDFile(~, fileName)
      [~, ~, ext] = fileparts(fileName);
      ext = erase(ext, '.');

      extensions = getMTEXpref('EBSDExtensions');
      extensions = erase(cellstr(extensions), '.');

      tf = any(strcmpi(ext, extensions));
    end

    function setImportStatus(app, mode, text)
      % the status band below the file tree, colored by its state - idle,
      % loading, loaded or failed - in the light or the dark colors
      arguments
        app
        mode (1,1) string
        text (1,1) string = "Select a file to import it"
      end
      ground = struct('idle', {[219 233 246; 28 50 71]}, 'loading', {[251 229 182; 74 56 16]}, ...
        'loaded', {[216 239 211; 29 59 32]}, 'failed', {[244 199 195; 79 31 31]});
      ink = [26 26 26; 240 240 240];
      dark = 1 + (isprop(app.UIFigure, 'Theme') && ~isempty(app.UIFigure.Theme) && ...
        app.UIFigure.Theme.BaseColorStyle == "dark");
      app.ImportStatusLabel.BackgroundColor = ground.(mode)(dark, :) / 255;
      app.ImportStatusLabel.FontColor = ink(dark, :) / 255;
      app.ImportStatusLabel.Text = char(text);
      app.ImportStatusLabel.Tooltip = char(text);

      % repaint the label before a blocking load, but only once there is a window
      if strcmp(app.UIFigure.Visible, 'on'), drawnow, end
    end

    function opts = importOptions(app, entry)
      % the selected list row as EBSD.load options - a file that offers no
      % choice contributes none, so they never reach a format that does
      % not know them
      if nargin < 2, entry = selectedDataSet(app); end

      % a file of several data sets states even the first one
      opts = {};
      if ~isempty(entry) && numel(app.DataSetEntries) > 1, opts = {'dataSet', entry.dataSet}; end
    end

    function entry = selectedDataSet(app)
      % the list row the user picked, empty when the file offers nothing
      % to choose from
      entry = [];
      idx = app.DataSetList.ValueIndex;
      if isempty(app.DataSetEntries) || isempty(idx) || idx < 1, return, end
      entry = app.DataSetEntries(min(idx, numel(app.DataSetEntries)));
    end

    function populateDataSetList(app, filePath, ebsdPreview)
      % Build the list of everything the file offers. A vendor that stores
      % a map more than once - Oxford writes it as recorded under "EBSD"
      % and as cleaned up under "Data Processing" - reports each version
      % as a data set of its own, so one enumeration names them all.
      %
      % Rows are kept in the order the import reported them, which is the
      % order the config prefers. Setting .Value programmatically does not
      % fire ValueChangedFcn, so nothing here triggers an import.
      entries = struct('label',{},'dataSet',{});

      sets = dataSetNames(app, ebsdPreview);

      if isempty(sets)
        % a format that holds a single, unnamed data set (.ang, .ctf, ...)
        [~, fName, fExt] = fileparts(char(filePath));
        entries(1) = struct('label', [fName fExt], 'dataSet', 1);
      else
        for k = 1:numel(sets)
          entries(end+1) = struct('label', char(sets(k)), 'dataSet', k); %#ok<AGROW>
        end
      end

      app.DataSetEntries = entries;
      app.DataSetList.Items = {entries.label};
      app.DataSetList.Enable = matlab.lang.OnOffSwitchState(~isempty(entries));
      if ~isempty(entries)
        app.DataSetList.ValueIndex = 1;
      end
    end

    function sets = dataSetNames(~, ebsdData)
      % the short data set names an import reported, if any. isa, not
      % isprop: the latter answers per array element, i.e. once per pixel
      % for an imported map, which no scalar test can consume
      sets = strings(1,0);
      if isa(ebsdData, 'EBSD') && isfield(ebsdData.opt, 'dataSets')
        sets = string(ebsdData.opt.dataSets);
      end
    end

    function markLoadedDataSet(app, ebsdData)
      % move the list selection onto the row that was actually imported -
      % it is the one whose options the import used
      entry = selectedDataSet(app);
      if isempty(entry) || ~isa(ebsdData,'EBSD') || ~isfield(ebsdData.opt,'dataSet')
        return
      end
      hit = find([app.DataSetEntries.dataSet] == entry.dataSet, 1);
      if ~isempty(hit), app.DataSetList.ValueIndex = hit; end
    end

    function DataSetListValueChanged(app, ~)
      % picking a row is the import - no double-click needed
      if app.PreviewFilePath == "", return, end
      importEBSDData(app, app.PreviewFilePath)
    end

    function importEBSDData(app, filePath)
      cancelWarmUp(app) % this is the real thing - see scheduleWarmUp
      filePath = char(filePath); % normalize string -> char so fileparts
                                  % and [fileName fileExt] behave predictably
      [~, fName, fExt] = fileparts(filePath);
      fileName = [fName fExt];

      setImportStatus(app, 'loading', "Loading " + fileName + " ...")
      opts = importOptions(app);
      app.Importing = true;
      cleanUp = onCleanup(@() importDone(app)); %#ok<NASGU>
      t = tic;
      try
        % the app says what it found in its own info tree, so a loader
        % writing to the command window would only be talking past it
        ebsdData = EBSD.load(filePath, 'wizard', 'silent', opts{:});
      catch ME
        setImportStatus(app, 'failed', fileName + ": " + ME.message)
        return
      end
      if isempty(ebsdData)
        setImportStatus(app, 'failed', fileName + ": no EBSD data")
        return
      end
      tLoad = toc(t);

      app.ebsd = ebsdData;
      app.LoadedFilePath = string(filePath); % Store file path for the script exporter
      app.PreviewFilePath = app.LoadedFilePath;
      app.PFODFKey = "";
      app.IPFKeys = {};
      app.SelectedImagePath = {};

      markLoadedDataSet(app, ebsdData)

      % --- paint first: the minimum required for the initial IPF Z view
      dropMapTabs(app)             % the only tab deletion, see dropMapTabs
      ensureSideAxes(app)          % when the import came before the warm-up
      invalidateAllSigs(app)
      syncCoordinateControls(app)  % plotIPF reads the coordinate dropdowns
      fillPhaseTable(app)          % ... and the phase selection

      % default view: IPF Z of the (pre-selected) largest phase
      app.TabGroup.SelectedTab = app.IPFTabs(3);
      updatePlot(app, true)
      drawnow                      % first paint

      % --- deferred setup: only appends tabs / updates values, it never
      % deletes or reorders (that would blank the visible plot) ----------
      app.ExportButton.Text = 'Import to variable';
      plotKey(app, dominantEnabledPhase(app, find(app.PhaseTable.Data.Plot)))
      populateMapTabs(app)         % creates the Images tab the info tree dims
      updateCurrentDataInfo(app, app.ebsd, filePath, false)
      setImportStatus(app, 'loaded', sprintf('%s: %d points in %.2g s', ...
        fileName, sum(phaseCounts(app)), tLoad))
    end

    function dropMapTabs(app)
      % Drop the property map tabs and the images tab of a previously
      % loaded data set, so that populateMapTabs is left with nothing but
      % appends. Deleting a tab after an MTEX plot has been drawn can
      % invalidate the uifigure canvas and leave intact graphics objects
      % visually blank, so this has to run before the first paint - see
      % importEBSDData. On a first import there is nothing to delete and it
      % costs nothing.
      delete(app.MapTabs(2:end))
      app.MapTabs = app.MapTabs(1);
      app.MapAxes = app.MapAxes(1:min(1,numel(app.MapAxes)));
      app.MapNames = app.MapNames(1);
      delete(app.ImagesTab)
    end

    function populateMapTabs(app)
      % Append one property map tab per property of the imported data set,
      % then the images tab, which is always the last one. Nothing is
      % deleted here (see dropMapTabs) and existing tabs - in particular
      % the currently visible one - are never touched, so this can run
      % after the first paint.
      %
      % Only the (empty) tabs are built here; the axes follow on first
      % display, see ensureTabAxesBuilt.
      names = getPropertyNames(app);
      app.MapNames = [{'Phase Map'}; names(:)];
      for k = 2:numel(app.MapNames)
        app.MapTabs(k) = createLazyPlotTab(app, app.MapNames{k}, app.TabColors.Maps);
      end

      createImagesTab(app)

      % resize the per-tab render signatures without invalidating the
      % already drawn IPF Z plot
      app.LastSig.Maps = repmat("", 1, max(1, numel(app.MapNames)));
      app.LastSig.Images = "";
    end

    function hasImage = populateOptNode(app, parentNode, s, pathPrefix)
      % recursively add one tree node per field of struct s under
      % parentNode; returns true if this subtree contains any image field
      hasImage = false;
      fields = fieldnames(s);
      for k = 1:numel(fields)
        field = fields{k};
        value = s.(field);
        thisPath = [pathPrefix, {field}];

        if isnumeric(value) && ismatrix(value) && ...
            size(value,1) >= 100 && size(value,2) >= 100
          node = uitreenode(parentNode, 'Text', field, ...
            'NodeData', struct('Type','Image','Path',{thisPath}));
          imgIcon = treeIconPath(app, 'ebsd');
          if ~isempty(imgIcon), node.Icon = imgIcon; end
          hasImage = true;
        elseif isstruct(value) && isscalar(value)
          node = uitreenode(parentNode, 'Text', field, 'NodeData', struct('Type','Folder'));
          childHasImage = populateOptNode(app, node, value, thisPath);
          hasImage = hasImage || childHasImage;
        else
          uitreenode(parentNode, 'Text', [field ': ' optValuePreview(app, value)], ...
            'NodeData', struct('Type','Field'));
        end
      end
    end

    function txt = optValuePreview(~, value)
      % short, safe text preview of a non-image ebsd.opt field's value
      try
        if ischar(value) || (isstring(value) && isscalar(value))
          txt = char(value);
        elseif (isnumeric(value) || islogical(value)) && isscalar(value)
          txt = num2str(value);
        elseif (isnumeric(value) || islogical(value)) && isvector(value) && numel(value) <= 10
          % small enough to show the values, as a row
          txt = num2str(value(:)');
        elseif isnumeric(value) || islogical(value)
          % sprintf, since '[...]' would promote the char scalars to a string array
          txt = sprintf('[%s %s]', strjoin(string(size(value)),'x'), class(value));
        else
          txt = class(value);
        end
      catch
        txt = '';
      end
    end

    function image = resolveOptImage(app, fieldPath)
      % Walk app.ebsd.opt along the stored field-name chain to retrieve
      % the matrix that an 'Image' tree node refers to.
      image = [];
      try
        value = app.ebsd.opt;
        for k = 1:numel(fieldPath)
          value = value.(fieldPath{k});
        end
        if isnumeric(value) && ismatrix(value)
          image = value;
        end
      catch
      end
    end

    function fillPhaseTable(app)

      csList = app.ebsd.CSList;
      numPhases = phaseCounts(app);

      % Symmetry and Alignment are categorical, so they are drawn as dropdowns -
      % the categories have to cover every value a row could take
      pgCats = [{'None'}, {symmetry.pointGroups.Inter}];
      alCats = [{'-'}, {'(custom)'}, alignmentSetups(app)];

      % percent and the lattice parameters are text, the only way to print
      % them to two decimals; Phase is int32, since phaseMap may be negative
      phaseTable = table('size',[0 13],...
        'VariableTypes',{'logical','int32','string','double','string', ...
          'categorical','string','string','string','string','string', ...
          'string','categorical'},...
        'VariableNames',{'Plot'; 'Phase'; 'Mineral'; 'Pixels'; 'Percent'; ...
          'Symmetry'; 'a'; 'b'; 'c'; 'alpha'; 'beta'; 'gamma'; 'Alignment'});

      for pId = 1:length(numPhases)

        cs = csList(pId);
        app.Color{pId} = str2rgb(cs.color);
        if any(isnan(app.Color{pId})), app.Color{pId} = [1 1 1]; end
        mineral = asChar(app, cs.mineral);
        if ~isa(cs,'crystalSymmetry'), mineral = 'NotIndexed'; end
        [pg, abc, abg, al] = phaseCells(app, cs);

        phaseTable(pId, :) = {false, app.ebsd.phaseMap(pId), mineral, ...
           numPhases(pId), fmt2(app, 100*numPhases(pId)/sum(numPhases)), ...
           categorical({pg}, pgCats), ...
           fmt2(app, abc(1)), fmt2(app, abc(2)), fmt2(app, abc(3)), ...
           fmt2(app, abg(1)), fmt2(app, abg(2)), fmt2(app, abg(3)), ...
           categorical({al}, alCats)};
      end

      % show every indexed phase that has pixels
      phaseTable.Plot = [csList.isIndexed].' & numPhases > 0;

      % row by row assignment keeps only the categories those rows use
      phaseTable.Symmetry  = setcats(phaseTable.Symmetry, pgCats);
      phaseTable.Alignment = setcats(phaseTable.Alignment, alCats);

      app.PhaseTable.Data = phaseTable;

      % the display headers
      colNames = phaseTable.Properties.VariableNames;
      colNames{5}  = '%';   % 'Percent' is not a valid display header choice
      colNames{10} = char(945);
      colNames{11} = char(946);
      colNames{12} = char(947);
      colNames{13} = 'Align';
      app.PhaseTable.ColumnName = colNames;

      restylePhaseTable(app)
    end

    function restylePhaseTable(app)
      % all cell styling in one place - it has to be reapplied whenever a
      % lattice changes, because which cells are fixed changes with it

      removeStyle(app.PhaseTable)
      % right align every column - the header follows its column
      addStyle(app.PhaseTable, uistyle('HorizontalAlignment', 'right'), ...
        'column', 1:width(app.PhaseTable.Data))

      % grey out the cells the lattice fixes, uitable disables only whole columns
      fixed = uistyle('FontColor', [0.5 0.5 0.5]);

      for row = 1:numel(app.ebsd.CSList)
        % the Phase cell is the phase color swatch, so the id printed on
        % it needs a font that stays readable on a dark one
        rgb = app.Color{row};
        addStyle(app.PhaseTable, uistyle('BackgroundColor', rgb, ...
          'FontColor', readableOn(app, rgb)), 'cell', [row 2])

        cs = app.ebsd.CSList(row);
        if ~isa(cs,'crystalSymmetry')
          addStyle(app.PhaseTable, fixed, 'cell', [repmat(row,8,1), (6:13).'])
          continue
        end

        % Align (column 13) is never greyed - every lattice has at least
        % six distinct frames to choose between
        free = latticeFreedom(app, cs.id);
        cols = [6+find(~free.len), 9+find(~free.ang)];
        if ~isempty(cols)
          addStyle(app.PhaseTable, fixed, ...
            'cell', [repmat(row,numel(cols),1), cols(:)])
        end
      end
    end

    function updatePlot(app, force)
      % Redraw the currently active tab. Each tab caches its own last
      % signature, so switching tabs or changing inputs only recomputes
      % when something relevant actually changed (or force is true).
      arguments
        app
        force logical = false
      end

      if isempty(app.ebsd), return, end
      refreshScript(app)

      t = app.TabGroup.SelectedTab;
      ensureTabAxesBuilt(app, t)
      mapIdx = find(app.MapTabs == t, 1);
      ipfIdx = find(app.IPFTabs == t, 1);
      if ~isempty(mapIdx)
        plotMaps(app, mapIdx, force)
      elseif ~isempty(ipfIdx)
        plotIPF(app, ipfIdx, force)
      elseif t == app.PFTab
        plotPoleFigures(app, force)
      elseif t == app.ImagesTab
        plotImages(app, force)
      end
    end

    function plotMaps(app, mapIdx, force)
      applyCurrentCoordinateState(app)

      % the maps always show the full data set in the current map coordinates
      sel = app.MapNames{mapIdx};
      sig = strjoin(["maps", string(sel)], '|');
      if ~force && numel(app.LastSig.Maps) >= mapIdx && ...
          sig == app.LastSig.Maps(mapIdx)
        setView(app.ebsd.how2plot, app.MapAxes(mapIdx))
        return
      end
      app.LastSig.Maps(mapIdx) = sig;

      ax = app.MapAxes(mapIdx);
      resetAxes(app, ax)

      if strcmp(sel, 'Phase Map')
        plot(app.ebsd, 'parent', ax, 'wizard')
      else
        plot(app.ebsd, app.ebsd.(sel), 'parent', ax)
        mtexColorMap(ax, 'white2black');
        colorbar(ax)
      end
      setView(app.ebsd.how2plot, ax)
    end

    function plotIPF(app, ipfIdx, force)
      enabledPhaseIds = find(app.PhaseTable.Data.Plot);
      applyCurrentCoordinateState(app)

      % the colors depend on the orientations and thus on the Euler
      % correction; a pure map coordinate change only realigns the view
      dirLabels = {'X','Y','Z'};
      sig = strjoin(["ipf", string(dirLabels{ipfIdx}), ...
        phaseSig(app,enabledPhaseIds), eulerSig(app)], '|');
      if ~force && numel(app.LastSig.IPF) >= ipfIdx && ...
          sig == app.LastSig.IPF(ipfIdx)
        setView(app.ebsd.how2plot, app.IPFAxes(ipfIdx))
        return
      end
      app.LastSig.IPF(ipfIdx) = sig;

      ax = app.IPFAxes(ipfIdx);
      direction = directionVector(app, dirLabels{ipfIdx});

      % color every pixel first and plot the map in one call, subsetting is expensive
      color = NaN(length(app.ebsd), 3);

      % color a not indexed phase with its own color, if one was chosen
      for phaseId = 1:numel(app.ebsd.CSList)
        if isa(app.ebsd.CSList(phaseId), 'crystalSymmetry'), continue; end
        rgb = app.Color{phaseId};
        if numel(rgb) ~= 3 || any(isnan(rgb)) || isequal(rgb(:).', [1 1 1])
          continue
        end
        mask = app.ebsd.phaseId == phaseId;
        color(mask,:) = repmat(rgb(:).', nnz(mask), 1);
      end

      for phaseId = enabledPhaseIds(:)'
        % skip not indexed "phases" - they carry no orientations
        if ~isa(app.ebsd.CSList(phaseId), 'crystalSymmetry'), continue; end
        mask = app.ebsd.phaseId == phaseId;
        if ~any(mask), continue; end
        ipfKey = ipfKeyForPhase(app, phaseId);
        ipfKey.ipfDirection = direction;
        ori = orientation(app.ebsd.rotations(mask), app.ebsd.CSList(phaseId));
        color(mask,:) = ipfKey.orientation2color(ori);
      end

      % a gridded map drawn before only needs its colors replaced
      img = findobj(ax, 'Type', 'image');
      if ~force && isscalar(img) && isequal(size(img.CData, [1 2]), size(app.ebsd))
        img.CData = reshape(color, [size(app.ebsd) 3]);
        img.AlphaData = double(~isnan(img.CData(:,:,1)));
        setView(app.ebsd.how2plot, ax)
        return
      end

      resetAxes(app, ax)
      if all(isnan(color(:)))
        title(ax, 'No phase selected')
        return
      end
      plot(app.ebsd, color, 'parent', ax)
      setView(app.ebsd.how2plot, ax)
    end

    function plotPoleFigures(app, force)
      enabledPhaseIds = find(app.PhaseTable.Data.Plot);
      applyCurrentCoordinateState(app)

      % the Miller indices typed for the crystal system shown, or its defaults
      pid = dominantEnabledPhase(app, enabledPhaseIds);
      if ~isempty(pid)
        app.PFSystem = char(app.ebsd.CSList(pid).lattice);
        m = millersFor(app, app.PFSystem);
        [app.PFMillerField.Value] = m{:};
      end

      % spherical axes cannot change their view, so replot the pole figures
      millers = string({app.PFMillerField.Value});
      sig = strjoin(["pf", strjoin(millers,';'), phaseSig(app,enabledPhaseIds), ...
        eulerSig(app), string(app.MapIdx)], '|');
      if ~force && sig == app.LastSig.PF, return; end
      app.LastSig.PF = sig;

      if isempty(pid)
        for i = 1:numel(app.PFAxes)
          resetAxes(app, app.PFAxes(i))
          title(app.PFAxes(i), 'No indexed phase selected')
        end
        return
      end
      ebsdPhase = app.ebsd(app.ebsd.phaseId == pid);

      % cache the ODF per phase, and rotate it when only the Euler correction changed
      corr = ebsdPhase.EulerCorrection;
      odfKey = "odf|" + string(pid);
      if odfKey ~= app.PFODFKey || isempty(app.PFODF)
        % a preview needs no more than 100k orientations, drawn the same each time
        ori = ebsdPhase.orientations;
        if length(ori) > 1e5, ori = ori(randperm(RandStream('twister','Seed',0), length(ori), 1e5)); end
        app.PFODF = calcDensity(ori);
        app.PFODFKey = odfKey;
        app.PFODFCorr = corr;
      elseif angle(corr * inv(app.PFODFCorr)) > 1e-10 %#ok<MINV>
        app.PFODF = rotate(app.PFODF, corr * inv(app.PFODFCorr)); %#ok<MINV>
        app.PFODFCorr = corr;
      end
      odf = app.PFODF;

      app.PFTitle.Text = [char(ebsdPhase.CS.mineral) ': pole figures'];

      for i = 1:numel(app.PFAxes)
        ax = app.PFAxes(i);
        resetAxes(app, ax)
        try
          h = string2Miller(strtrim(app.PFMillerField(i).Value), ebsdPhase.CS);
        catch
          title(ax, 'invalid Miller'); continue
        end
        % pass the plotting convention explicitly, odf.SS.how2plot is not it
        plotPDF(odf, h, 'parent', ax, 'contourf', 'upper', 'noTitle', ...
          'fontSize', 20, 'TL', 'upper', app.ebsd.how2plot);
        ax.Color = 'none';   % the tab's ground, not the darker axes one
        colorbar(ax, 'southoutside')

        % the Euler axes in the map's frame, named as the Euler pictogram names them
        text(ebsdPhase.EulerCorrection * [xvector,yvector,zvector], eulerAxesNames(app), ...
          'textColor','r','backgroundColor','w','parent',ax,'fontSize',20,'noAntipodal');
      end
    end

    function plotImages(app, force)
      if isempty(app.SelectedImagePath)
        resetAxes(app, app.ImagesAxes)
        title(app.ImagesAxes, 'Select an image in the info tree')
        return
      end

      sig = strjoin(["img", strjoin(string(app.SelectedImagePath),'.')], '|');
      if ~force && sig == app.LastSig.Images, return; end
      app.LastSig.Images = sig;

      ax = app.ImagesAxes;
      resetAxes(app, ax)
      image = resolveOptImage(app, app.SelectedImagePath);
      if isempty(image)
        title(ax, 'Image not found'); return
      end
      imagesc(ax, image)
      colormap(ax, 'gray')
      axis(ax, 'image')   % preserve pixel aspect ratio (no distortion)
      colorbar(ax)
    end

    function resetAxes(~, ax)
      % full reset so a previous MTEX plot leaves no aspect ratio, camera,
      % limits or appdata (mapPlot/sphericalPlot) behind
      % 'reset' restores the factory geometry, not the one the axes was
      % built with - a grid child owns no Position, hence the parent test
      free = ~isa(ax.Parent, 'matlab.ui.container.GridLayout');
      if free, ax.Units = 'normalized'; pos = ax.Position; end
      cla(ax, 'reset')
      rmallappdata(ax)
      ax.Visible = 'off';   % an empty axes shows no box and ticks, a title still shows
      if free, ax.Units = 'normalized'; ax.Position = pos; end
    end

    function s = phaseSig(~, ids)
      s = strjoin(string(ids(:).'), ',');
      if s == "", s = "none"; end
    end

    function s = eulerSig(app)
      % signature of the Euler -> map correction, built from the rotation
      % itself so that a map convention change, which keeps the correction
      % and only moves the Euler index, keeps orientation plots valid
      try
        [a, b, g] = Euler(app.ebsd.EulerCorrection);
        s = strjoin(string(round([a b g]/degree, 3)), '_');
      catch
        s = "none";
      end
    end

    function plotKey(app, phaseId)
      % the IPF key of one phase beside the phase table: the phase clicked
      % there, after an import the dominant one
      app.KeyPhase = phaseId;
      resetAxes(app, app.KeyAxes)
      axis(app.KeyAxes, 'off')
      app.KeyAxes.Toolbar.Visible = 'off';
      disableDefaultInteractivity(app.KeyAxes)
      if isempty(phaseId) || ~isa(app.ebsd.CSList(phaseId), 'crystalSymmetry')
        return
      end

      % the direction map, since plot(key) asks for an mtexFigure and opens one
      key = ipfKeyForPhase(app, phaseId);
      plot(key.dirMap, 'parent', app.KeyAxes, 'resolution', 1.5*degree)
      title(app.KeyAxes, app.ebsd.CSList(phaseId).mineral, ...
        'Interpreter', 'none', 'FontWeight', 'normal')

      % the corner labels hang outside the sector, the limits take them in
      e = vertcat(findobj(app.KeyAxes,'Type','text').Extent);
      app.KeyAxes.XLim = [min([e(:,1); app.KeyAxes.XLim(1)]), max([e(:,1)+e(:,3); app.KeyAxes.XLim(2)])];
      app.KeyAxes.YLim = [min([e(:,2); app.KeyAxes.YLim(1)]), max([e(:,2)+e(:,4); app.KeyAxes.YLim(2)])];
    end

    function key = ipfKeyForPhase(app, phaseId)
      % one precomputed ipfColorKey per phase, shared by the IPF X/Y/Z tabs,
      % which only set its ipfDirection - ipfColorKey is a handle class
      if numel(app.IPFKeys) < phaseId || isempty(app.IPFKeys{phaseId})
        app.IPFKeys{phaseId} = ipfColorKey(app.ebsd.CSList(phaseId));
        app.IPFKeys{phaseId}.precompute;
      end
      key = app.IPFKeys{phaseId};
    end

    function counts = phaseCounts(app)
      % measurements per phase, as a numel(CSList) × 1 column - the NaN
      % phaseId of an empty grid site is padding, not a pixel
      phaseId = app.ebsd.phaseId;
      counts = accumarray(phaseId(~isnan(phaseId)), 1, ...
        [numel(app.ebsd.CSList) 1]);
    end

    function pid = dominantEnabledPhase(app, ids)
      % indexed phase with the most pixels among the enabled ones, or []
      pid = [];
      best = -1;
      counts = phaseCounts(app);
      for k = ids(:)'
        if k >= 1 && k <= numel(app.ebsd.CSList) && ...
            isa(app.ebsd.CSList(k), 'crystalSymmetry') && counts(k) > best
          best = counts(k); pid = k;
        end
      end
    end

    function invalidateAllSigs(app)
      sigs = struct();
      sigs.Maps = repmat("", 1, max(1, numel(app.MapNames)));
      sigs.IPF = ["" "" ""];
      sigs.PF = "";
      sigs.Images = "";
      app.LastSig = sigs;
    end

    function applyCurrentCoordinateState(app)
      % the map convention is the session's, and the map's own where its
      % frame states one - the script passes it to EBSD.load the same way
      pC = app.CoordinateSystems.how2plot(app.MapIdx);
      plottingConvention.default(pC);
      if app.ebsd.how2plot ~= pC
        fr = app.ebsd.frame;
        if isempty(fr), fr = specimenFrame.default; end
        fr = copy(fr);
        fr.how2plot = pC;
        app.ebsd.frame = fr;
      end

      % assigning EulerCorrection rewrites all rotations, so skip the
      % assignment when the correction did not actually change
      newCorr = eulerCorrection(app);
      oldCorr = app.ebsd.EulerCorrection;
      if ~isa(oldCorr, 'quaternion') || isempty(oldCorr) || ...
          angle(newCorr * inv(oldCorr)) > 1e-10 %#ok<MINV>
        app.ebsd.EulerCorrection = newCorr;
      end
    end

    function rot = eulerCorrection(app)
      % the Euler axes onto the map axes - the expression the script writes
      eul = app.CoordinateSystems.how2plot(app.EulerIdx);
      map = app.CoordinateSystems.how2plot(app.MapIdx);
      rot = rotation.map(eul.east, map.east, eul.outOfScreen, map.outOfScreen);
    end

    function syncCoordinateControls(app)
      mapIdx = closestCoordinateIndex(app, app.ebsd.how2plot.rot);

      eulerIdx = mapIdx;
      try
        eulerRot = inv(app.ebsd.EulerCorrection) * app.ebsd.how2plot.rot; %#ok<MINV>
        eulerIdx = closestCoordinateIndex(app, eulerRot);
      catch
      end

      refreshCoordinateFrames(app, mapIdx, eulerIdx)
    end

    function drawCoordinateFrame(app, ax, idx, labels, color, caption)
      % one framed pictogram filling its square axes
      if isempty(ax) || ~isgraphics(ax) || idx < 1 || idx > height(app.CoordinateSystems)
        return
      end
      cla(ax)
      drawPictogram(app, ax, idx, labels, color, [0 0], 100, caption)
      ax.XLim = [-51 51];   % the frame line stays inside
      ax.YLim = [-51 51];
    end

    function drawPictogram(app, ax, idx, names, color, c, H, caption)
      % The frame as pymtex's wizard draws it, in a framed square of side
      % 100 centred at c, in an axes H high: the axis leaving the screen
      % named at the crossing, the two in it as arrows with their names
      % off the heads, the caption dimmed in the quadrant they leave free.
      % The drawing is centred on its ink, not on the crossing.
      LEN = 46; HEAD = 14; LABEL = 18; GAP = 8; WEIGHT = 4.5; PAD = 6;

      % the reference axes on screen - right, up, out of it
      pC = app.CoordinateSystems.how2plot(idx);
      dirs = [vector3d.X, vector3d.Y, vector3d.Z];
      a = [dot(dirs,pC.east,'noAntipodal').', dot(dirs,pC.north,'noAntipodal').', ...
        dot(dirs,pC.outOfScreen,'noAntipodal').'];
      out = find(abs(a(:,3)) > 0.9, 1);

      % half the ink box of a label, and how far it reaches along d
      box = @(str) [0.31*numel(str), 0.36] * LABEL;
      reach = @(b,d) b(1)*abs(d(1)) + b(2)*abs(d(2));

      P = {};                                      % shafts and heads
      T = {[0 0], names{out}, box(names{out})};    % labels: position, text, half box
      for j = setdiff(1:3, out)
        d = a(j,1:2) / norm(a(j,1:2)); n = [-d(2) d(1)] * WEIGHT/2; t = d * LEN;
        s0 = GAP + reach(T{1,3}, d); s1 = LEN - 0.9*HEAD;
        P{end+1} = [d*s0 + n; d*s1 + n; d*s1 - n; d*s0 - n]; %#ok<AGROW>
        phi = atan2(d(2), d(1)) + [-0.36 0.36];
        P{end+1} = [t; t - HEAD*[cos(phi(1)) sin(phi(1))]; t - HEAD*[cos(phi(2)) sin(phi(2))]]; %#ok<AGROW>
        b = box(names{j});
        T(end+1,:) = {t + d*(GAP + reach(b,d)), names{j}, b}; %#ok<AGROW>
      end
      sxy = sum(a(setdiff(1:3,out),1:2), 1);
      T(end+1,:) = {0.78 * LEN * (2*(sxy >= 0) - 1), caption, box(caption)};

      % scale the ink into the square
      xy = [vertcat(P{:}); vertcat(T{:,1}) + vertcat(T{:,3}); vertcat(T{:,1}) - vertcat(T{:,3})];
      lo = min(xy); hi = max(xy);
      k = (100 - 2*PAD) / max(hi - lo);
      at = @(p) c + k * (p - (lo + hi)/2);

      patch(ax, c(1) + 50*[-1 1 1 -1], c(2) + 50*[-1 -1 1 1], 'w', 'FaceColor', 'none', ...
        'EdgeColor', [0.55 0.55 0.55], 'HitTest', 'off')
      for i = 1:numel(P)
        q = at(P{i});
        patch(ax, q(:,1), q(:,2), color, 'EdgeColor', 'none', 'HitTest', 'off')
      end
      % the axes names bold, the caption light and dimmed
      ink = [repmat(color, size(T,1)-1, 1); 0.6*color + 0.4*ax.Color];
      weight = [repmat({'bold'}, size(T,1)-1, 1); {'normal'}];
      for i = 1:size(T,1)
        q = at(T{i,1});
        text(ax, q(1), q(2), T{i,2}, 'Color', ink(i,:), 'FontWeight', weight{i}, ...
          'FontUnits', 'normalized', 'FontSize', k * LABEL / H, ...
          'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'HitTest', 'off')
      end
    end

    function openChooser(app, which)
      % the eight conventions as pictograms, dropped down below the one
      % clicked - a click on one sets it, see pickConvention
      if ~isempty(app.ConventionChooser) && app.ConventionChooser.Visible && app.ChooserFor == which
        app.ConventionChooser.Visible = 'off';
        return
      end
      if isempty(app.ConventionChooser)
        app.ConventionChooser = uipanel(app.UIFigure, 'Visible', 'off');
        app.ChooserAxes = pictogramAxes(app, app.ConventionChooser);
        app.ChooserAxes.ButtonDownFcn = @(~,~) pickConvention(app);
      end
      app.ChooserFor = which;

      if which == "map"
        src = app.MapFrameAxes; names = frameAxesNames(app); idx = app.MapIdx;
        color = src.XColor; caption = 'map';
      else
        src = app.EulerFrameAxes; names = eulerAxesNames(app); idx = app.EulerIdx;
        color = app.EulerFrameColor; caption = 'Euler';
      end

      % four to a row, the one in force on a tinted ground
      ax = app.ChooserAxes;
      cla(ax)
      n = height(app.CoordinateSystems); rows = ceil(n/4);
      for k = 1:n
        c = [100*mod(k-1,4) + 50, -100*floor((k-1)/4) - 50];
        if k == idx
          patch(ax, c(1) + 50*[-1 1 1 -1], c(2) + 50*[-1 -1 1 1], color, ...
            'FaceAlpha', 0.15, 'EdgeColor', 'none', 'HitTest', 'off')
        end
        drawPictogram(app, ax, k, names, color, c, 100*rows, caption)
      end
      ax.XLim = [-1 401];
      ax.YLim = [-100*rows-1 1];

      % below the pictogram clicked, 96 pixels a pictogram
      p = getpixelposition(src.Parent, true);
      sz = 0.96 * [400, 100*rows];
      app.ConventionChooser.Position = [p(1), p(2) - sz(2), sz];
      app.ConventionChooser.Visible = 'on';
    end

    function pickConvention(app)
      % the cell clicked in the chooser, see openChooser
      app.ConventionChooser.Visible = 'off';
      ax = app.ChooserAxes;
      rc = floor([-ax.CurrentPoint(1,2), ax.CurrentPoint(1,1)] / 100);
      k = 4*rc(1) + rc(2) + 1;
      if any(rc < 0) || rc(2) > 3 || k > height(app.CoordinateSystems), return, end

      if app.ChooserFor == "map"
        app.MapIdx = k;
        setMapCoordinates(app)
      else
        app.EulerIdx = k;
        refreshCoordinateFrames(app)
        % IPF maps and pole figures pick up the new Euler correction by signature
        if ~isempty(app.ebsd), updatePlot(app), end
      end
    end

    function closeChooserOutside(app)
      % a click anywhere but the chooser or a pictogram closes it - the
      % pictograms toggle it themselves
      if isempty(app.ConventionChooser) || ~app.ConventionChooser.Visible, return, end
      pt = app.UIFigure.CurrentPoint;
      inside = @(h) all(pt >= h(1:2) & pt <= h(1:2) + h(3:4));
      if ~inside(app.ConventionChooser.Position) && ...
          ~inside(getpixelposition(app.MapFrameAxes, true)) && ...
          ~inside(getpixelposition(app.EulerFrameAxes, true))
        app.ConventionChooser.Visible = 'off';
      end
    end

    function names = frameAxesNames(app)
      % The axes of the frame the map is expressed in. No vendor gives the
      % map a reference system of its own, so this is the frame the data
      % lives in - X/Y/Z generically, RD/TD/ND in a rolling frame, and the
      % very names the map's own indicator carries, see refFrameGeometry.
      names = specimenFrame.default.axesNames;
      try
        if ~isempty(app.ebsd), names = app.ebsd.frame.axesNames; end
      catch
      end
    end

    function names = eulerAxesNames(app)
      % The two vendors that name the Euler reference frame apart from the
      % map. An Oxford file states its Euler angles as the orientation of
      % the crystal CS2 to the sample surface CS1 and carries the labels of
      % CS1 - not those of CS0, which is a sample frame the user may define
      % on top, a rolling system say, related to CS1 by "Specimen
      % Orientation Euler". EDAX labels the Euler axes A1, A2, A3 in its
      % coordinate settings dialog, see EBSDReferenceFrame.
      names = headerAxesNames(app,'SampleSurfaceDirectionLabels');
      if ~isempty(names), return, end

      % a .ctf or .cpr carries no labels, but CS1 is what Oxford calls the
      % frame its Euler angles are stated in either way
      if isVendor(app,'EDAX'), names = {'A1','A2','A3'}; return, end
      if isVendor(app,'Oxford'), names = {'X1','Y1','Z1'}; return, end

      names = frameAxesNames(app);
    end

    function names = headerAxesNames(app,field)
      % the three axis labels an import left in ebsd.opt.header, if any
      names = {};
      try
        v = app.ebsd.opt.header.(field);
        if numel(v) == 3, names = cellstr(string(v(:)).'); end
      catch
      end
    end

    function tf = isVendor(app,name)
      tf = false;
      try
        tf = app.LoadedFilePath ~= "" && ~isempty(app.ebsd) && ...
          contains(vendorLabel(app,app.ebsd,app.LoadedFilePath),name,'IgnoreCase',true);
      catch
      end
    end

    function refreshCoordinateFrames(app, mapIdx, eulerIdx)
      % both pictograms, so that a new file reaches them
      if nargin > 1, app.MapIdx = mapIdx; app.EulerIdx = eulerIdx; end
      drawCoordinateFrame(app, app.MapFrameAxes, app.MapIdx, ...
        frameAxesNames(app), app.MapFrameAxes.XColor, 'map')
      drawCoordinateFrame(app, app.EulerFrameAxes, app.EulerIdx, ...
        eulerAxesNames(app), app.EulerFrameColor, 'Euler')
    end

    function idx = closestCoordinateIndex(app, rot)
      pC = app.CoordinateSystems.how2plot;
      idx = [];

      try
        idx = find(rot == [pC.rot], 1);
      catch
      end

      if isempty(idx)
        try
          [~, idx] = min(angle(rot, [pC.rot]));
        catch
          idx = 1;
        end
      end
    end

    function names = getPropertyNames(app)
      names = {};
      try
        names = fieldnames(app.ebsd.prop);
      catch
      end
    end

    function v = directionVector(~, direction)
      switch upper(char(direction))
        case 'X', v = xvector;
        case 'Y', v = yvector;
        case 'Z', v = zvector;
        otherwise, error('Direction must be X, Y, or Z.')
      end
    end

    function txt = asChar(~, value)
      try
        txt = char(string(value));
      catch
        try
          txt = char(value);
        catch
          txt = '';
        end
      end
    end

    function updateCurrentDataInfo(app, ebsd, filePath, isPreview)
      % basic information about the given data set: file name, spatial
      % extent in scan units, grid type/dimensions, grid resolution and,
      % when they can be determined, the vendor, file size and creation
      % date - as the leading rows of the info tree, followed by one node
      % per field of ebsd.opt, see populateOptNode. The Images tab of an
      % imported data set is dimmed if its opt holds no image.
      %
      % ebsd may be a headerOnly preview (no positions/orientations) as
      % well as a fully imported data set - isPreview only controls the
      % Status row, everything else degrades gracefully via try/catch
      % (e.g. "Coordinates" and grid dimensions need real pixel data and
      % are simply omitted for a preview).
      [~, fName, fExt] = fileparts(char(filePath));
      fileName = [fName fExt];

      if isPreview
        rows = {'Status', 'Preview (not imported)'};
      else
        rows = {'Status', 'Imported'};
      end
      rows(end+1,:) = {'File', asChar(app, fileName)};

      try
        ext = ebsd.extent;
        rows(end+1,:) = {'Coordinates', ['[' xnum2str(ext(1:2), 'delimiter', ',') ...
          '] × [' xnum2str(ext(3:4), 'delimiter', ',') '] ' scanUnitLabel(app, ebsd)]};
      catch
      end

      try
        [gridLabel, dimsTxt, resolutionTxt] = gridInfo(app, ebsd);
        rows(end+1,:) = {gridLabel, dimsTxt};
        rows(end+1,:) = {'Step Size', resolutionTxt};
      catch
      end

      try
        rows(end+1,:) = {'Euler correction', rotationLabel(app, ebsd.EulerCorrection)};
      catch
      end

      vendor = vendorLabel(app, ebsd, filePath);
      if ~isempty(vendor), rows(end+1,:) = {'Vendor', vendor}; end

      fileSize = fileSizeLabel(app, filePath);
      if ~isempty(fileSize), rows(end+1,:) = {'File size', fileSize}; end

      created = creationDateLabel(app, ebsd, filePath);
      if ~isempty(created), rows(end+1,:) = {'Created', created}; end

      delete(app.OptTree.Children)
      for k = 1:size(rows,1)
        uitreenode(app.OptTree, 'Text', [rows{k,1} ': ' rows{k,2}], ...
          'NodeData', struct('Type','Field'));
      end

      try
        s = ebsd.opt;
      catch
        s = struct();
      end
      hasImage = isstruct(s) && isscalar(s) && populateOptNode(app, app.OptTree, s, {});
      if isPreview, return, end
      if hasImage
        app.ImagesTab.ForegroundColor = app.TabColors.Images;
      else
        app.ImagesTab.ForegroundColor = app.TabColors.Disabled;
      end
    end

    function txt = rotationLabel(~, rot)
      % a rotation as its angle about its axis, the axis in integers where
      % it has a lattice direction
      if angle(rot) < 1e-6, txt = 'none'; return, end
      v = rot.axis.xyz;
      v = v / min(abs(v(abs(v) > 1e-6)));
      if all(abs(v - round(v)) < 1e-4), v = round(v); end
      txt = sprintf('%g° about (%s)', round(angle(rot)/degree, 2), strjoin(compose('%g', v), ','));
    end

    function u = scanUnitLabel(~, ebsd)
      u = 'um';
      try u = char(ebsd.scanUnit); catch, end
      if strcmpi(u, 'um'), u = 'µm'; end
    end

    function [gridLabel, dimsTxt, resolutionTxt] = gridInfo(app, ebsd)
      % gridLabel: 'Square Grid' or 'Hex Grid' (used as the row's
      % Property name); dimsTxt: e.g. '1000 × 500 pixel'; resolutionTxt
      % (shown under "Step Size"): the plain step size value, no 'dx ='/
      % 'dHex =' label - e.g. '60 µm' or '60 × 80 µm' when dx and dy differ
      u = scanUnitLabel(app, ebsd);
      [xmin, xmax, ymin, ymax] = extent(ebsd);

      if size(ebsd.unitCell, 1) == 6 % hexagonal grid

        dHex = max(norm(ebsd.unitCell)); % circumradius of the unit cell
        if isa(ebsd, 'EBSDhex')
          dx = ebsd.dx; dy = ebsd.dy;
        elseif max(abs(ebsd.unitCell.x)) < max(abs(ebsd.unitCell.y))
          % row alignment - flat hexagon sides facing left/right
          dx = dHex * sqrt(3); dy = 1.5 * dHex;
        else
          dx = 1.5 * dHex; dy = dHex * sqrt(3);
        end
        gridLabel = 'Hex Grid';
        resolutionTxt = [xnum2str(dHex) ' ' u];

      else % square grid

        dx = max(ebsd.unitCell.x) - min(ebsd.unitCell.x);
        dy = max(ebsd.unitCell.y) - min(ebsd.unitCell.y);
        gridLabel = 'Square Grid';
        if abs(dx - dy) < 1e-4 * max(dx, dy)
          resolutionTxt = [xnum2str(dx) ' ' u];
        else
          resolutionTxt = [xnum2str(dx) ' x ' xnum2str(dy) ' ' u];
        end

      end

      nx = round((xmax - xmin) / dx) + 1;
      ny = round((ymax - ymin) / dy) + 1;
      dimsTxt = [int2str(nx) ' x ' int2str(ny) ' pixel'];
    end

    function txt = fileSizeLabel(~, filePath)
      % human-readable file size (KB/MB/GB) of the given file
      txt = '';
      try
        listing = dir(char(filePath));
        if ~isscalar(listing), return, end
        bytes = listing.bytes;
        units = {'bytes','KB','MB','GB','TB'};
        idx = 1;
        while bytes >= 1024 && idx < numel(units)
          bytes = bytes / 1024;
          idx = idx + 1;
        end
        if idx == 1
          txt = sprintf('%d %s', bytes, units{idx});
        else
          txt = sprintf('%.1f %s', bytes, units{idx});
        end
      catch
      end
    end

    function txt = vendorLabel(app, ebsd, filePath)
      % vendor from the file metadata if present, otherwise a guess based
      % on the file format
      txt = findMetaField(app, ebsd.opt, {'manufacturer', 'vendor'}, 3);
      if ~isempty(txt), return, end

      vendors = struct( ...
        'ang', 'EDAX / TSL', 'osc', 'EDAX / TSL', 'tsl', 'EDAX / TSL', ...
        'oh5', 'EDAX / TSL', 'ctf', 'Oxford Instruments', ...
        'crc', 'Oxford Instruments', 'cpr', 'Oxford Instruments', ...
        'hkl', 'Oxford Instruments', 'h5oina', 'Oxford Instruments', ...
        'dream3d', 'DREAM.3D');
      [~, ~, ext] = fileparts(char(filePath));
      ext = lower(erase(ext, '.'));
      if isfield(vendors, ext), txt = vendors.(ext); end
    end

    function txt = creationDateLabel(app, ebsd, filePath)
      % acquisition date from the file metadata if present, otherwise the
      % file system date
      txt = findMetaField(app, ebsd.opt, {'date'}, 3);
      if isempty(txt)
        listing = dir(char(filePath));
        if isscalar(listing), txt = [listing.date ' (file date)']; end
      end
    end

    function txt = findMetaField(app, s, patterns, depth)
      % search struct s (recursively, up to the given depth) for a text
      % field whose name contains one of the (lowercase) patterns
      txt = '';
      if ~isstruct(s) || ~isscalar(s), return, end

      fields = fieldnames(s);
      for k = 1:numel(fields)
        if contains(lower(fields{k}), patterns)
          value = s.(fields{k});
          if ischar(value) || (isstring(value) && isscalar(value)) || isdatetime(value)
            txt = strtrim(char(string(value)));
            if ~isempty(txt), return, end
          end
        end
      end

      if depth <= 1, return, end
      for k = 1:numel(fields)
        if isstruct(s.(fields{k}))
          txt = findMetaField(app, s.(fields{k}), patterns, depth - 1);
          if ~isempty(txt), return, end
        end
      end
    end

    function updateMineralName(app, row, value)

      app.PhaseTable.Data.Mineral(row) = value;
      app.ebsd.CSList(row).mineral = value;
      if row == app.KeyPhase, app.KeyAxes.Title.String = value; end

    end

    function rebuildPhaseSymmetry(app, row, col)
      % Rebuild the crystalSymmetry of one phase from its table row after
      % an inline edit of the point group, a lattice parameter, an axis
      % angle or the alignment.
      %
      % The row is read as a whole rather than the edited cell applied on
      % its own, because a lattice ties its parameters together and
      % crystalFrame/private/calcAxis asserts on an inconsistent set: a
      % cubic phase must have a = b = c, a hexagonal one a = b and
      % alpha = beta = 90, gamma = 120. uitable can only enable or
      % disable a whole column, so those cells are merely greyed (see
      % restylePhaseTable) and an edit that lands in one is snapped back
      % onto what the lattice forces instead of being rejected.

      cs = app.ebsd.CSList(row);
      data = app.PhaseTable.Data;

      % a notIndexed phase has no lattice, put the row back as it was
      pg = char(data.Symmetry(row));
      if ~isa(cs, 'crystalSymmetry') || strcmp(pg, 'None')
        refreshPhaseRow(app, row); return
      end

      id = find(strcmp({symmetry.pointGroups.Inter}, pg), 1);
      if isempty(id), refreshPhaseRow(app, row); return, end
      free = latticeFreedom(app, id);

      % '-' and '(custom)' are labels describing the current frame, not
      % setups anybody can select
      alStr = char(data.Alignment(row));
      isSetup = any(strcmp(alStr, alignmentSetups(app)));
      if col == 13 && ~isSetup, refreshPhaseRow(app, row); return, end

      % --- snap whatever the (possibly new) lattice fixes ---------------
      % take the lattice from the symmetry and only the edited cell from the table
      abc = cs.abc;
      abg = cs.abg / degree;

      driver = [];
      if col >= 7 && col <= 12
        typed = str2double(data{row, col});
        if isnan(typed) || ~isreal(typed)
          uialert(app.UIFigure, ...
            sprintf('"%s" is not a number.', string(data{row, col})), ...
            'Invalid lattice parameter')
          refreshPhaseRow(app, row); return
        end
        if col <= 9
          % every length tied to a takes the value of the edited cell
          driver = col - 6;
          abc(driver) = typed;
        else
          abg(col - 9) = typed;
        end
      end

      [abc, abg] = snapLattice(app, id, abc, abg, driver);

      % --- the alignment ------------------------------------------------
      if isSetup
        al = strsplit(alStr, ', ');
      else
        % a frame no offered setup reproduces; keep it rather than let an
        % edit of an unrelated cell silently reset it to the default
        al = alignment(cs);
      end

      try
        newCS = crystalSymmetry('PointId', id, abc, abg * degree, ...
          al{:}, 'mineral', asChar(app, data.Mineral(row)));
      catch ME
        uialert(app.UIFigure, ME.message, 'Invalid crystal symmetry')
        refreshPhaseRow(app, row); return
      end

      % keep the phase color - it belongs to the phase, not to its
      % lattice, and is edited through the Phase cell
      if isnumeric(cs.color) && numel(cs.color) == 3 && ~any(isnan(cs.color))
        newCS.color = cs.color;
      end

      installPhaseSymmetry(app, row, newCS)
    end

    function installPhaseSymmetry(app, row, cs)
      % install an edited crystal symmetry and drop everything cached
      % that described the old one

      app.ebsd.CSList(row) = cs;

      % drop the caches that carry the previous symmetry
      if numel(app.IPFKeys) >= row, app.IPFKeys{row} = []; end
      if row == app.KeyPhase, plotKey(app, row), end
      app.PFODF = [];
      app.PFODFKey = "";
      app.PFODFCorr = [];

      refreshPhaseRow(app, row)
      restylePhaseTable(app)   % a new lattice fixes a different set of cells

      invalidateAllSigs(app)
      updatePlot(app, true)
    end

    function refreshPhaseRow(app, row)
      % write one row's symmetry cells back from the crystalSymmetry,
      % which is what makes a rejected or snapped edit visibly revert.
      % Only these cells - a full fillPhaseTable would reset the Plot
      % selection back to the largest phase.

      [pg, abc, abg, al] = phaseCells(app, app.ebsd.CSList(row));
      app.PhaseTable.Data.Symmetry(row)  = pg;
      app.PhaseTable.Data.a(row)         = fmt2(app, abc(1));
      app.PhaseTable.Data.b(row)         = fmt2(app, abc(2));
      app.PhaseTable.Data.c(row)         = fmt2(app, abc(3));
      app.PhaseTable.Data.alpha(row)     = fmt2(app, abg(1));
      app.PhaseTable.Data.beta(row)      = fmt2(app, abg(2));
      app.PhaseTable.Data.gamma(row)     = fmt2(app, abg(3));
      app.PhaseTable.Data.Alignment(row) = al;
    end

    function [pg, abc, abg, al] = phaseCells(app, cs)
      % point group, lattice and alignment of a phase as the table shows
      % them - a notIndexed phase has no lattice, its cells stay blank
      if isa(cs, 'crystalSymmetry')
        pg = asChar(app, cs.pointGroup);
        [abc, abg] = displayLattice(app, cs);
        al = closestSetup(app, cs);
      else
        pg = 'None'; abc = NaN(1,3); abg = NaN(1,3); al = '-';
      end
    end

    function s = fmt2(~, value)
      % a lattice parameter as the table prints it: two decimals, or
      % blank where there is no value at all
      if isempty(value) || isnan(value)
        s = "";
      else
        s = string(sprintf('%.2f', value));
      end
    end

    function rgb = readableOn(~, background)
      % black or white, whichever stays legible on the given background
      % (Rec. 709 luma, the usual threshold for this)
      luma = [0.2126 0.7152 0.0722] * background(:);
      rgb = repmat(double(luma < 0.55), 1, 3);
    end

    function list = alignmentSetups(~)
      % every alignment the Align dropdown offers: X on a direct crystal
      % axis and Z on a reciprocal one, or the other way round, always
      % naming two different letters.
      %
      % These twelve are the pairs of the 36 possible that construct on
      % every lattice, so the dropdown never offers a choice that fails,
      % and between them they reach every distinct frame any lattice has:
      % twelve for triclinic, monoclinic, trigonal and hexagonal, six for
      % the orthogonal ones, where a and a* coincide. Pairs naming two
      % direct axes (X||a, Z||c) only duplicate frames of this list.
      %
      % Naming Y is never needed - fixing X and Z leaves Y to follow.
      %
      % The two setups in practically every data set come first so they
      % are at the top of the dropdown, and so that closestSetup reports
      % them in preference on an orthogonal lattice, where several
      % entries describe the one frame.

      list = {'X||a*, Z||c', ...   % the MTEX default
              'X||a, Z||c*'};      % EDAX / TSL, and the usual hexagonal setting

      direct = {'a','b','c'};
      recip  = {'a*','b*','c*'};
      for i = 1:3
        for j = 1:3
          if i == j, continue, end
          list{end+1} = ['X||' direct{i} ', Z||' recip{j}]; %#ok<AGROW>
          list{end+1} = ['X||' recip{i} ', Z||' direct{j}]; %#ok<AGROW>
        end
      end
      list = unique(list, 'stable');
    end

    function name = closestSetup(app, cs)
      % which of the offered setups reproduces this crystal frame
      %
      % Decided by rebuilding the frame rather than by reading
      % crystalSymmetry/alignment: for a hexagonal lattice c and c*
      % coincide, so alignment() reports Z||c whichever setup was asked
      % for, and a string comparison would match nothing.

      [abc, abg] = snapLattice(app, cs.id, cs.abc, cs.abg / degree);

      setups = alignmentSetups(app);
      for k = 1:numel(setups)
        try
          parts = strsplit(setups{k}, ', ');
          ref = crystalSymmetry('PointId', cs.id, abc, abg * degree, parts{:});
          if max(angle(cs.axes, ref.axes)) < 1e-4 * degree
            name = setups{k}; return
          end
        catch %#ok<CTCH> a setup the lattice cannot express - try the next
        end
      end
      name = '(custom)';
    end

    function [abc, abg] = displayLattice(app, cs)
      % the lattice parameters of a phase as the table should show them,
      % angles in degree
      %
      % cs.abc and cs.abg are recovered from the basis by norm() and acos(),
      % so a hexagonal gamma comes back as 120.00000000000001 and b differs
      % from a in the last digits. Snapping onto what the lattice forces and
      % rounding off that noise shows the numbers the lattice has.

      [abc, abg] = snapLattice(app, cs.id, cs.abc, cs.abg / degree);
      abc = round(abc, 8);
      abg = round(abg, 8);
    end

    function [abc, abg] = snapLattice(app, id, abc, abg, driver)
      % force lattice parameters onto what a point group's lattice allows
      %
      % Exactness is the whole point: calcAxis checks a == b with ==, and
      % lattice parameters read back out of a basis (cs.abc) only agree to
      % about 15 digits, so feeding them straight back in trips "For
      % hexagonal lattices a and b must be equal!". Angles are in degree.
      %
      % driver is the index of the length the user just typed; when it is
      % one of the lengths tied to a, that is the one they all follow.

      free = latticeFreedom(app, id);

      tied = [true, ~free.len(2), ~free.len(3)];
      if nargin < 5 || isempty(driver) || ~tied(driver), driver = 1; end
      abc(tied) = abc(driver);

      defAng = free.lattice.defaultAngles / degree;
      abg(~free.ang) = defAng(~free.ang);
    end

    function free = latticeFreedom(~, id)
      % which lattice parameters, angles and alignments a point group
      % leaves free - the same rules crystalFrame/private/calcAxis
      % asserts on, read out rather than discovered by trial and error

      lat = symmetry.pointGroups(id).lattice;
      free.len = freeLengths(lat);

      % triclinic leaves all three angles free, monoclinic the one about its axis
      free.ang = false(1,3);
      if lat == latticeType.triclinic
        free.ang(:) = true;
      elseif lat == latticeType.monoclinic
        free.ang(floor(double(id)/3)) = true;
      end

      % no free.align - every lattice has at least six distinct frames
      free.lattice = lat;
    end

    function pos = screenArea(~)
      % the primary monitor's work area as a figure Position, i.e. the
      % size a maximized window gets (see createComponents)
      %
      % Not ScreenSize: that spans every monitor of a multi head setup,
      % which would open the wizard across all of them. Row 1 of
      % MonitorPositions is the primary monitor, in the same bottom left
      % origin convention a figure Position uses. The insets are the
      % desktop's own panels and bars.
      pos = get(groot, 'ScreenSize');
      try
        monitors = get(groot, 'MonitorPositions');
        if ~isempty(monitors), pos = monitors(1,:); end
      catch
      end
      try
        gc = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment ...
          .getDefaultScreenDevice.getDefaultConfiguration;
        in = java.awt.Toolkit.getDefaultToolkit.getScreenInsets(gc);
        pos = pos + [in.left, in.bottom, -in.left-in.right, -in.top-in.bottom];
      catch
      end
    end

    function width = leftPanelWidth(app)
      % the file browser and info tree column, scaled with the font size
      width = max(300, ceil(22 * app.FontSize));
    end
  end

  methods (Access = private)
    function FileTreeClicked(app, event)
      % a mouse click on a folder only opens its branch in place -
      % descending into a folder requires a double click or Enter. Only
      % genuine clicks land here, so moving the selection with the cursor
      % keys does not open folders. Expand only branches that were never
      % populated, otherwise a collapse via the chevron would be undone
      % right away by this callback.
      node = event.InteractionInformation.Node;
      if ~isscalar(node) || isempty(node.NodeData) || ...
          ~strcmp(node.NodeData.Type, 'Folder')
        return
      end

      if ~isempty(node.Children) && isempty(node.Children(1).NodeData)
        populateFolderNode(app, node, node.NodeData.Path)
        expand(node)
      end
    end

    function WizardKeyPress(app, event)
      % keyboard navigation for the file browser: arrow keys move the
      % cursor natively, Enter opens the selected entry (import a file /
      % descend into a folder), Backspace navigates one folder up.
      %
      % Block only when the keystroke is demonstrably meant for a
      % text-entry control instead (which needs Enter/Backspace for
      % itself) - not via an allowlist of "known good" CurrentObject
      % values, which silently breaks the moment focus drifts anywhere
      % else (importing a file, switching tabs, editing the phase table,
      % the Import/Export buttons - the latter even steals focus to the
      % Command Window/Workspace outright).
      co = app.UIFigure.CurrentObject;
      if isa(co, 'matlab.ui.control.EditField') || ...
          isa(co, 'matlab.ui.control.NumericEditField') || ...
          isa(co, 'matlab.ui.control.TextArea') || ...
          isa(co, 'matlab.ui.control.ListBox') || ...
          isa(co, 'matlab.ui.control.Table')
        return
      end

      switch event.Key
        case 'escape'
          if ~isempty(app.ConventionChooser), app.ConventionChooser.Visible = 'off'; end
        case {'return', 'enter'}
          node = app.FileTree.SelectedNodes;
          if isscalar(node) && ~isempty(node.NodeData)
            if strcmp(node.NodeData.Type, 'File')
              importEBSDData(app, node.NodeData.Path)
            else
              navigateToFolder(app, node.NodeData.Path)
            end
          end
        case 'backspace'
          UpFolderButtonPushed(app, [])
      end
    end

    function FileTreeDoubleClicked(app, event)
      node = event.InteractionInformation.Node;
      if isempty(node) || isempty(node.NodeData)
        return
      end

      data = node.NodeData;
      switch data.Type
        case 'File'
          importEBSDData(app, data.Path)
        case 'Folder'
          navigateToFolder(app, data.Path)
      end
    end

    function FileTreeSelectionChanged(app, ~)
      % fires on click AND arrow-key navigation, for both files and
      % folders - a file gets a preview
      node = app.FileTree.SelectedNodes;
      if ~isscalar(node) || isempty(node.NodeData) || ~strcmp(node.NodeData.Type, 'File')
        return
      end
      previewEBSDData(app, node.NodeData.Path)

      % a selection that rests half a second imports the file - a large
      % one waits for Enter, since the import blocks the window
      if ~isempty(app.ImportTimer) && isvalid(app.ImportTimer), delete(app.ImportTimer), end
      listing = dir(node.NodeData.Path);
      if listing.bytes > 100e6
        setImportStatus(app, 'idle', "a large file - press Enter to import it")
        return
      end
      app.ImportTimer = timer('StartDelay', 0.5, 'StopFcn', @(t,~) delete(t), ...
        'TimerFcn', @(~,~) importResting(app, node));
      start(app.ImportTimer)
    end

    function importDone(app)
      app.Importing = false;
    end

    function importResting(app, node)
      % the file the selection still rests on, unless it is imported already
      if ~isvalid(app) || app.Importing || ~isvalid(node) || ...
          ~isequal(app.FileTree.SelectedNodes, node) || ...
          node.NodeData.Path == app.LoadedFilePath
        return
      end
      importEBSDData(app, node.NodeData.Path)
    end

    function previewEBSDData(app, filePath)
      % lightweight, non-intrusive preview: a headerOnly load feeds the
      % info tree (app.OptTree) and the list of what the file
      % offers to import, without touching app.ebsd - so browsing around
      % never disturbs the currently plotted data set. Failures are
      % silent (no uialert) since this fires on every arrow-key move, not
      % just a deliberate user action.
      filePath = char(filePath);
      sameFile = strcmp(filePath, char(app.PreviewFilePath));
      app.PreviewFilePath = string(filePath);

      % this is the imported file - show its real info instead of a preview
      if strcmp(filePath, char(app.LoadedFilePath))
        updateCurrentDataInfo(app, app.ebsd, filePath, false)
        if ~sameFile, markLoadedDataSet(app, app.ebsd), end
        return
      end

      try
        % 'silent': do not print an import banner for every file browsed past
        ebsdPreview = EBSD.load(filePath, 'wizard', 'headerOnly', 'silent');
      catch
        % not a recognized/loadable format - leave the tree as is
        app.DataSetEntries(:) = [];
        app.DataSetList.Items = {};
        app.DataSetList.Enable = 'off';
        return
      end

      updateCurrentDataInfo(app, ebsdPreview, filePath, true)
      populateDataSetList(app, filePath, ebsdPreview)
    end

    function FileTreeNodeExpanded(app, event)
      node = event.Node;
      if ~isscalar(node) || isempty(node.NodeData) || ~strcmp(node.NodeData.Type, 'Folder')
        return
      end
      populateFolderNode(app, node, node.NodeData.Path)
    end

    function UpFolderButtonPushed(app, ~)
      parentFolder = fileparts(char(app.CurrentFolder));
      if isempty(parentFolder)
        return
      end
      navigateToFolder(app, parentFolder)
    end

    function BrowseFolderButtonPushed(app, ~)
      % the system folder dialog reaches other drives and network shares
      folder = uigetdir(char(app.CurrentFolder), 'Select the data folder');
      figure(app.UIFigure) % the dialog leaves the wizard behind other windows
      if ischar(folder), navigateToFolder(app, folder), end
    end

    function TabSelectionChanged(app, ~)
      % lazy: only (re)draw the tab the user switched to
      updatePlot(app)
    end

    function PFTabSizeChanged(app, ~)
      % cap the pole figure row at roughly the column width, so the
      % square (axis equal tight) pole figures sit right below their
      % Miller fields instead of being centered in a tall axes
      try
        pos = app.PFTab.Position;
        pad = 6; colSpacing = 6; rowSpacing = 2; titleRow = 20; labelRow = 26;
        colW = (pos(3) - 2*pad - 2*colSpacing) / 3;
        availH = pos(4) - 2*pad - titleRow - labelRow - 3*rowSpacing - 1;
        app.PFGrid.RowHeight = {titleRow, labelRow, max(100, min(ceil(1.1*colW), availH)), '1x'};
      catch
      end
    end

    function PFMillerChanged(app, ~)
      if ~isempty(app.PFSystem), app.TypedMillers.(app.PFSystem) = {app.PFMillerField.Value}; end
      updatePlot(app, true)
    end

    function m = millersFor(app, system)
      % the three Miller indices of a crystal system: those typed for it,
      % else the axes, face and body diagonal of a cube, the c axis and the
      % two a-type planes of a hexagonal or trigonal lattice, c, a and the
      % a diagonal of a tetragonal one, the three axes of the lower systems
      if isfield(app.TypedMillers, system), m = app.TypedMillers.(system); return, end
      switch system
        case 'cubic', m = {'(100)', '(110)', '(111)'};
        case {'hexagonal', 'trigonal'}, m = {'(0001)', '(10-10)', '(11-20)'};
        case 'tetragonal', m = {'(001)', '(100)', '(110)'};
        otherwise, m = {'(100)', '(010)', '(001)'};
      end
    end

    function OptTreeSelectionChanged(app, event)
      node = event.SelectedNodes;
      % the images of a file that is only previewed are not loaded
      if ~isscalar(node) || isempty(node.NodeData) || ~strcmp(node.NodeData.Type,'Image') ...
          || app.PreviewFilePath ~= app.LoadedFilePath
        return
      end
      app.SelectedImagePath = node.NodeData.Path;
      app.TabGroup.SelectedTab = app.ImagesTab;
      updatePlot(app, true)
    end

    function PhaseTableCellEdit(app, event)
      if isempty(event.Indices)
        return
      end

      row = event.Indices(1);
      col = event.Indices(2);

      switch col
        case 1
          % the phase selection is part of the IPF and pole figure signatures
          updatePlot(app)

        case 3
          updateMineralName(app, row, event.NewData)
          invalidateAllSigs(app)
          updatePlot(app, true)

        case {6, 7, 8, 9, 10, 11, 12, 13}
          % point group, lattice parameters, axis angles and alignment
          % all rebuild the same crystalSymmetry from the whole row
          rebuildPhaseSymmetry(app, row, col)
      end
    end

    function PhaseTableCellSelection(app, event)
      % a click on a row shows the IPF key of its phase
      if ~isempty(event.Indices) && ~isequal(event.Indices(1), app.KeyPhase)
        plotKey(app, event.Indices(1))
      end

      % the Phase cell doubles as the phase color swatch - clicking it
      % opens the color picker
      if isempty(event.Indices) || event.Indices(2) ~= 2
        return
      end

      row = event.Indices(1);

      newColor = uisetcolor(app.Color{row}, 'Select phase color');
      if isequal(newColor, 0), return, end

      app.ebsd.CSList(row).color = newColor;
      app.Color{row} = newColor;

      addStyle(app.PhaseTable, uistyle('BackgroundColor', newColor, ...
        'FontColor', readableOn(app, newColor)), 'cell', [row 2])
      invalidateAllSigs(app)
      updatePlot(app, true)
    end

    function setMapCoordinates(app)
      % the Euler convention follows, the orientations stay as they are
      if isempty(app.ebsd), refreshCoordinateFrames(app), return, end
      eulerRot = inv(app.ebsd.EulerCorrection) * app.CoordinateSystems.how2plot(app.MapIdx).rot; %#ok<MINV>
      app.EulerIdx = closestCoordinateIndex(app, eulerRot);
      refreshCoordinateFrames(app)

      % no invalidation, the plotters only realign the view
      updatePlot(app)
    end

    function ExportButtonPushed(app, ~)
      if isempty(app.ebsd)
        return
      end

      varName = strtrim(app.VariableNameField.Value);
      if isempty(varName) || ~isvarname(varName)
        uialert(app.UIFigure, ...
          sprintf('"%s" is not a valid MATLAB variable name.', varName), ...
          'Invalid variable name')
        return
      end

      assignin('base', varName, app.ebsd)
      [~,fname,ext] =  fileparts(app.LoadedFilePath);
      disp(" ");
      disp("EBSD data from " + fname + ext + " imported to variable " + varName)
      disp(" ");
      evalin("base",varName);
      app.ExportButton.Text = ['Imported as ' varName '!'];
      workspace
    end

    function str = importScript(app)
      % the import script of the current choices
      opts = importOptions(app);
      str = buildImportWizardScript(app.ebsd, app.LoadedFilePath, ...
        app.CoordinateSystems.how2plot(app.MapIdx), app.CoordinateSystems.how2plot(app.EulerIdx), ...
        [opts{2:end}], logical(app.PhaseTable.Data.Plot), app.PhaseTable.Data.Mineral);
    end

    function refreshScript(app)
      % the script panel, written only when the text changed, so that its
      % scroll position survives a tab switch
      try
        lines = splitlines(string(importScript(app)));
      catch ME
        lines = "% the script could not be generated: " + ME.message;
      end
      if ~isequal(string(app.ScriptArea.Value), lines), app.ScriptArea.Value = lines; end
    end

    function copyScript(app)
      if isempty(app.ebsd), return, end
      clipboard('copy', importScript(app))
      setImportStatus(app, 'loaded', "the import script is on the clipboard")
    end

    function saveScript(app)
      if isempty(app.ebsd), return, end
      [~, name] = fileparts(app.LoadedFilePath);
      [f, p] = uiputfile('*.m', 'Save the import script', "import_" + matlab.lang.makeValidName(name) + ".m");
      figure(app.UIFigure) % the dialog leaves the wizard behind other windows
      if isequal(f, 0), return, end
      writelines(importScript(app), fullfile(p, f))
      setImportStatus(app, 'loaded', "saved " + f)
    end

    function editScript(app)
      % the wizard comes up maximized, so the new script opens behind it -
      % makeActive is what hands the focus over to the editor
      if isempty(app.ebsd), return, end
      doc = matlab.desktop.editor.newDocument(importScript(app));
      try doc.makeActive, catch, end
    end
  end
  methods (Access = public)
    function app = import_wizard

      if getMTEXpref("generatingHelpMode"), return; end
      if verLessThan('matlab','9.13')
        error('MTEX:import_wizard:release',['The import wizard needs MATLAB ',...
          'R2022b or newer. Load the data with EBSD.load or PoleFigure.load instead.']);
      end

      runningApp = getRunningApp(app);

      if isempty(runningApp)
        createComponents(app)
        registerApp(app, app.UIFigure)
      else
        figure(runningApp.UIFigure)
        app = runningApp;
      end

      if nargout == 0
        clear app
      end
    end

    function delete(app)
      cancelWarmUp(app)
      if ~isempty(app.ImportTimer) && isvalid(app.ImportTimer), delete(app.ImportTimer), end
      if ~isempty(app.UIFigure) && isvalid(app.UIFigure)
        delete(app.UIFigure)
      end
    end
  end
end
