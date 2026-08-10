classdef import_wizard < matlab.apps.AppBase
  % EBSD app variant with lazy analysis UI, one colorized tab per plot
  % view, compact layout, and a single self-contained updatePlot routine.

  properties (Access = public)
    UIFigure                       matlab.ui.Figure
    EBSDDataAnalysisPanel          matlab.ui.container.Panel
    MainLayout                     matlab.ui.container.GridLayout
    LeftPanel                      matlab.ui.container.Panel
    LeftLayout                     matlab.ui.container.GridLayout
    RightPanel                     matlab.ui.container.Panel
    RightLayout                    matlab.ui.container.GridLayout

    FileBrowserPanel               matlab.ui.container.Panel
    FileBrowserLayout              matlab.ui.container.GridLayout
    UpFolderButton                 matlab.ui.control.Button
    CurrentPathLabel               matlab.ui.control.Label
    FileTree                       matlab.ui.container.Tree
    ImportStatusLabel              matlab.ui.control.Label       % hint / loading status below the file tree
    DataSetListLabel               matlab.ui.control.Label
    DataSetList                    matlab.ui.control.ListBox     % everything the selected file offers to import:
                                                                 % its data sets times the recorded / post
                                                                 % processed versions. Selecting one imports it.
    CurrentData                    matlab.ui.control.Table       % basic file info, 2-column label/value
    PhaseTable                     matlab.ui.control.Table
    VariableNameField              matlab.ui.control.EditField   % variable name for "Import to variable"
    ExportButton                   matlab.ui.control.Button
    ExportScriptButton             matlab.ui.control.Button % Button for generating an MTEX script


    TabGroup                       matlab.ui.container.TabGroup
    MapTabs                        matlab.ui.container.Tab       % phase map + one tab per property
    MapAxes                        matlab.ui.control.UIAxes      % parallel to MapTabs; built lazily, see ensureTabAxesBuilt
    MapAxesParent                  matlab.ui.container.GridLayout % holds MapAxes(1) once built
    IPFTabs                        matlab.ui.container.Tab       % 1x3 array: IPF X / Y / Z
    IPFAxes                        matlab.ui.control.UIAxes      % 1x3 array; built lazily, see ensureTabAxesBuilt
    IPFAxesParent                  matlab.ui.container.GridLayout % 1x3 array, holds IPFAxes once built
    PFTab                          matlab.ui.container.Tab
    PFGrid                         matlab.ui.container.GridLayout
    ImagesTab                      matlab.ui.container.Tab
    PFMillerField                  matlab.ui.control.EditField   % 1x3 array
    PFAxes                         matlab.ui.control.UIAxes      % 1x3 array; built lazily, see ensureTabAxesBuilt
    ImagesAxes                     matlab.ui.control.UIAxes      % built lazily, see ensureTabAxesBuilt
    ImagesAxesParent               matlab.ui.container.GridLayout % holds ImagesAxes once built
    OptTree                        matlab.ui.container.Tree      % browser for ebsd.opt, right of PhaseTable

    CoordinatePanel                matlab.ui.container.Panel
    CoordinateLayout               matlab.ui.container.GridLayout
    MapCoordinatesDropDownLabel    matlab.ui.control.Label
    MapCoordinatesDropDown         matlab.ui.control.DropDown
    EulerCoordinatesDropDownLabel  matlab.ui.control.Label
    EulerCoordinatesDropDown       matlab.ui.control.DropDown
    MapImage                       matlab.ui.control.Image
    EulerImage                     matlab.ui.control.Image
  end

  properties (Access = private)
    ebsd
    Color cell = {}
    AnalysisUICreated logical = false
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
    IPFKeys cell = {}           % precomputed ipfColorKey per phase, shared
                                % by the IPF X/Y/Z tabs (they only differ by
                                % the inversePoleFigureDirection)
    PFODF = []                  % cached ODF for the pole figure tab
    PFODFKey string = ""        % cache key describing what PFODF was computed from
    PFODFCorr = []              % Euler correction the cached ODF refers to
  end

  properties (Constant, Access = private)
    CoordinateSystems = table( ...
      ["yUxR" "yDxR" "xUyR" "xDyR" "xLyU" "xLyD" "yLxU" "yLxD"]', ...
      ["y↑→x" "y↓→x" "x↑→y" "x↓→y" "x←↑y" "x←↓y" "y←↑x" "y←↓x"]', ...
      [plottingConvention( zvector,  xvector)
      plottingConvention(-zvector,  xvector)
      plottingConvention(-zvector,  yvector)
      plottingConvention( zvector,  yvector)
      plottingConvention(-zvector, -xvector)
      plottingConvention( zvector, -xvector)
      plottingConvention( zvector, -yvector)
      plottingConvention(-zvector, -yvector)], ...
      'VariableNames', {'Key', 'Label', 'how2plot'})

    % tab label colors: one color per plot category so that map, IPF,
    % pole figure and image tabs are distinguishable at a glance
    TabColors = struct( ...
      'Maps',     [0.00 0.35 0.68], ...
      'IPF',      [0.13 0.55 0.20], ...
      'PF',       [0.49 0.18 0.56], ...
      'Images',   [0.85 0.33 0.10], ...
      'Disabled', [0.60 0.60 0.60])
  end

  methods (Access = private)
    function createComponents(app)
      leftWidth = app.leftPanelWidth();

      app.UIFigure = uifigure('Visible', 'off');
      app.UIFigure.Position = [100 100 1300 700];
      app.UIFigure.WindowState = 'maximized';
      app.UIFigure.Name = 'MTEX Import Wizard';
      app.UIFigure.WindowKeyPressFcn = createCallbackFcn(app, @WizardKeyPress, true);
      try
        app.UIFigure.Theme = 'light';
      catch
      end

      app.EBSDDataAnalysisPanel = uipanel(app.UIFigure, ...
        'Title', 'MTEX Import Wizard', ...
        'FontWeight', 'bold', ...
        'FontSize', 18, ...
        'Units', 'normalized', ...
        'Position', [0 0 1 1]);

      app.MainLayout = uigridlayout(app.EBSDDataAnalysisPanel, ...
        'ColumnWidth', {leftWidth, '1x'}, ...
        'RowHeight', {'1x'}, ...
        'ColumnSpacing', 12, ...
        'Padding', [12 10 12 12]);

      app.LeftPanel = uipanel(app.MainLayout, 'BorderType', 'none');
      app.LeftPanel.Layout.Row = 1;
      app.LeftPanel.Layout.Column = 1;

      app.LeftLayout = uigridlayout(app.LeftPanel, ...
        'ColumnWidth', {'1x'}, ...
        'RowHeight', {'1x', 210, 80}, ...
        'RowSpacing', 10, ...
        'Padding', [0 0 0 0]);

      createFileBrowser(app)

      % basic file info as a 2-column label/value table (see
      % updateCurrentDataInfo) instead of free-form text lines
      app.CurrentData = uitable(app.LeftLayout, ...
        'ColumnName', {'Property','Value'}, ...
        'RowName', {}, ...
        'ColumnWidth', {90, '1x'}, ...
        'FontSize', app.FontSize - 1);
      app.CurrentData.Layout.Row = 2;
      app.CurrentData.Data = cell2table({'Status','No EBSD data loaded'}, ...
        'VariableNames',{'Property','Value'});

      app.RightPanel = uipanel(app.MainLayout, 'BorderType', 'none');
      app.RightPanel.Layout.Row = 1;
      app.RightPanel.Layout.Column = 2;

      app.UIFigure.Visible = 'on';

      % Build the analysis UI (tabs, axes, phase table, ...) right away:
      % the first axes and the table pay a substantial one-time renderer
      % boot cost, which this way happens asynchronously while the user
      % is still browsing for a file - instead of delaying the first plot.
      ensureAnalysisUI(app)

      % start with the keyboard focus on the file browser, so a file can
      % be picked with the arrow keys and loaded with Enter right away
      try focus(app.FileTree); catch, end
    end

    function createFileBrowser(app)
      % Compact inline file browser (top-left): a uitree showing folders
      % and EBSD files of the current directory, plus a back button and
      % path label for navigation. Single-clicking a folder only expands
      % its branch in place; double-clicking (or pressing Enter) descends
      % into a folder or imports a file, Backspace navigates up. Merely
      % selecting a file (click or arrow keys, see SelectionChangedFcn)
      % triggers a fast headerOnly preview into the file info table below,
      % without touching the actually imported/plotted data set.
      app.FileBrowserPanel = uipanel(app.LeftLayout, 'BorderType', 'line');
      app.FileBrowserPanel.Layout.Row = 1;

      app.FileBrowserLayout = uigridlayout(app.FileBrowserPanel, ...
        'ColumnWidth', {30, '1x'}, ...
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

      app.CurrentPathLabel = uilabel(app.FileBrowserLayout, ...
        'Text', '', ...
        'FontSize', app.FontSize - 2, ...
        'Interpreter', 'none');
      app.CurrentPathLabel.Layout.Row = 1;
      app.CurrentPathLabel.Layout.Column = 2;

      app.FileTree = uitree(app.FileBrowserLayout, ...
        'FontSize', app.FontSize - 1, ...
        'ClickedFcn', createCallbackFcn(app, @FileTreeClicked, true), ...
        'NodeExpandedFcn', createCallbackFcn(app, @FileTreeNodeExpanded, true), ...
        'DoubleClickedFcn', createCallbackFcn(app, @FileTreeDoubleClicked, true), ...
        'SelectionChangedFcn', createCallbackFcn(app, @FileTreeSelectionChanged, true));
      app.FileTree.Layout.Row = 2;
      app.FileTree.Layout.Column = [1 2];

      app.ImportStatusLabel = uilabel(app.FileBrowserLayout, ...
        'HorizontalAlignment', 'center', ...
        'FontSize', app.FontSize - 2);
      app.ImportStatusLabel.Layout.Row = 3;
      app.ImportStatusLabel.Layout.Column = [1 2];
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
      app.DataSetListLabel.Layout.Column = [1 2];

      app.DataSetList = uilistbox(app.FileBrowserLayout, ...
        'Items', {}, ...
        'Enable', 'off', ...
        'FontSize', app.FontSize - 2, ...
        'Tooltip', 'Select what to import from the file above', ...
        'ValueChangedFcn', createCallbackFcn(app, @DataSetListValueChanged, true));
      app.DataSetList.Layout.Row = 5;
      app.DataSetList.Layout.Column = [1 2];
    end

    function ensureAnalysisUI(app)
      if app.AnalysisUICreated
        return
      end

      % RightLayout must exist before createCoordinateControls, since the
      % coordinate panel is now placed as its 3rd column (see item 30)
      createRightPanel(app)
      createCoordinateControls(app)
      createExportButtonsPanel(app) % Combined layout setup for both buttons

      app.AnalysisUICreated = true;
    end

    function createCoordinateControls(app)
      labels = cellstr(app.CoordinateSystems.Label);

      % top-right corner of the right panel: fixed width/height, alongside
      % the phase table (fixed, left) and the opt tree (flexible, middle)
      app.CoordinatePanel = uipanel(app.RightLayout, ...
        'Title', 'Coordinate systems', ...
        'FontWeight', 'bold', ...
        'FontSize', app.FontSize);
      app.CoordinatePanel.Layout.Row = 1;
      app.CoordinatePanel.Layout.Column = 3;

      app.CoordinateLayout = uigridlayout(app.CoordinatePanel, ...
        'ColumnWidth', {'1x', '1x'}, ...
        'RowHeight', {22, 30, 120}, ...
        'ColumnSpacing', 8, ...
        'RowSpacing', 6, ...
        'Padding', [8 8 8 8]);

      app.MapCoordinatesDropDownLabel = uilabel(app.CoordinateLayout, ...
        'Text', 'Map Coordinates', ...
        'FontWeight', 'bold', ...
        'FontSize', app.FontSize - 1);
      app.MapCoordinatesDropDownLabel.Layout.Row = 1;
      app.MapCoordinatesDropDownLabel.Layout.Column = 1;

      app.EulerCoordinatesDropDownLabel = uilabel(app.CoordinateLayout, ...
        'Text', 'Euler Coordinates', ...
        'FontWeight', 'bold', ...
        'FontSize', app.FontSize - 1);
      app.EulerCoordinatesDropDownLabel.Layout.Row = 1;
      app.EulerCoordinatesDropDownLabel.Layout.Column = 2;

      app.MapCoordinatesDropDown = uidropdown(app.CoordinateLayout, ...
        'Items', labels, ...
        'ValueChangedFcn', createCallbackFcn(app, @setMapCoordinates, true), ...
        'FontSize', app.FontSize);
      app.MapCoordinatesDropDown.Layout.Row = 2;
      app.MapCoordinatesDropDown.Layout.Column = 1;

      app.EulerCoordinatesDropDown = uidropdown(app.CoordinateLayout, ...
        'Items', labels, ...
        'ValueChangedFcn', createCallbackFcn(app, @setEulerCoordinate, true), ...
        'FontSize', app.FontSize);
      app.EulerCoordinatesDropDown.Layout.Row = 2;
      app.EulerCoordinatesDropDown.Layout.Column = 2;

      app.MapImage = uiimage(app.CoordinateLayout, 'ScaleMethod', 'fit');
      app.MapImage.Layout.Row = 3;
      app.MapImage.Layout.Column = 1;

      app.EulerImage = uiimage(app.CoordinateLayout, 'ScaleMethod', 'fit');
      app.EulerImage.Layout.Row = 3;
      app.EulerImage.Layout.Column = 2;
    end

    % Row 1: "Import to variable" + inline variable name field; row 2:
    % "Generate import script" spanning the full width (no more type
    % dropdown, see ExportScriptButtonPushed - this app only ever loads
    % EBSD data)
    function createExportButtonsPanel(app)
      buttonGrid = uigridlayout(app.LeftLayout, ...
        'ColumnWidth', {'1x', '1x'}, ...
        'RowHeight', {35, 35}, ...
        'Padding', [0 0 0 0], ...
        'RowSpacing', 8,...
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

      app.ExportScriptButton = uibutton(buttonGrid, 'push', ...
        'ButtonPushedFcn', createCallbackFcn(app, @ExportScriptButtonPushed, true), ...
        'FontWeight', 'bold', ...
        'FontSize', app.FontSize, ...
        'Text', 'Generate import script');
      app.ExportScriptButton.Layout.Row = 2;
      app.ExportScriptButton.Layout.Column = [1 2];

    end

    function createRightPanel(app)
      % row 1: PhaseTable (fixed, left - wide enough for its own column
      % widths below, ~645px, plus a little slack), OptTree (flexible,
      % middle), CoordinatePanel (fixed, right - added by
      % createCoordinateControls); row 2: TabGroup spanning all 3 columns
      app.RightLayout = uigridlayout(app.RightPanel, ...
        'ColumnWidth', {665,'1x',300}, ...
        'RowHeight', {230, '1x'}, ...
        'RowSpacing', 8, ...
        'ColumnSpacing', 8, ...
        'Padding', [0 0 0 0]);

      app.PhaseTable = uitable(app.RightLayout, ...
        'ColumnEditable', [true false true false false false false false false false], ...
        'RowName', {}, ...
        'CellEditCallback', createCallbackFcn(app, @PhaseTableCellEdit, true), ...
        'CellSelectionCallback', createCallbackFcn(app, @PhaseTableCellSelection, true), ...
        'FontSize', app.FontSize - 1);
      app.PhaseTable.Layout.Row = 1;
      app.PhaseTable.Layout.Column = 1;
      % columns: Plot, Phase, Mineral, Pixels, %, Symmetry, a, b, c, Color -
      % Plot/Color only ever hold a checkbox/swatch and Phase a small
      % integer, so they need far less room than the default equal split;
      % Mineral gets extra room since it carries the longest text; Color
      % gets a little extra to fit its pencil marker (see fillPhaseTable)
      app.PhaseTable.ColumnWidth = {45, 55, 135, 70, 55, 75, 55, 55, 55, 60};

      % browser for the full ebsd.opt structure - selecting an image-shaped
      % field shows it in the Images tab (see OptTreeSelectionChanged)
      app.OptTree = uitree(app.RightLayout, ...
        'FontSize', app.FontSize - 1, ...
        'SelectionChangedFcn', createCallbackFcn(app, @OptTreeSelectionChanged, true));
      app.OptTree.Layout.Row = 1;
      app.OptTree.Layout.Column = 2;

      createTabs(app)
      app.TabGroup.Layout.Column = [1 3];
    end

    function createTabs(app)
      % The plot area is a tab group. Every view is its own tab owning its
      % own axes so that no single axis is ever repurposed between a map,
      % an IPF map, a pole figure and an image - which previously forced
      % fragile cla/reset and appdata juggling and broke the scale bar
      % lifecycle. Tab labels are colorized by category (maps, IPF, pole
      % figures, images).
      %
      % The tab CONTAINERS (uitab, their titles/colors, and any cheap
      % uicontrols they hold, e.g. the PF tab's Miller fields) are all
      % still built right here, eagerly - only the uiaxes inside each one
      % (~0.88s apiece, measured) are deferred to ensureTabAxesBuilt, the
      % first time that tab is actually shown (see updatePlot, which
      % every tab switch - interactive or programmatic - funnels through).
      app.TabGroup = uitabgroup(app.RightLayout, ...
        'SelectionChangedFcn', createCallbackFcn(app, @TabSelectionChanged, true));
      app.TabGroup.Layout.Row = 2;

      % The tabs are created directly in their display order - the tab
      % group is never reordered through its Children property, since
      % that makes the renderer rebuild the whole group, which is slow
      % and briefly blanks the currently visible plot.

      % --- map tabs: the phase map now, one tab per property at import ---
      [app.MapTabs, app.MapAxesParent] = createLazyPlotTab(app, 'Phase Map', app.TabColors.Maps);
      app.MapNames = {'Phase Map'};

      % --- IPF tabs: one tab per direction, Z first -----------------------
      [tz, gz] = createLazyPlotTab(app, 'IPF Z', app.TabColors.IPF);
      [ty, gy] = createLazyPlotTab(app, 'IPF Y', app.TabColors.IPF);
      [tx, gx] = createLazyPlotTab(app, 'IPF X', app.TabColors.IPF);
      app.IPFTabs = [tx, ty, tz];   % index 1/2/3 = direction X/Y/Z
      app.IPFAxesParent = [gx, gy, gz];

      % --- Pole Figures tab: parallel axes, a Miller field above each -----
      app.PFTab = uitab(app.TabGroup, 'Title', 'Pole Figures', ...
        'ForegroundColor', app.TabColors.PF);
      % three rows: Miller fields, pole figure axes, filler. The axes row
      % is capped to roughly the column width by PFTabSizeChanged so the
      % square pole figures stay right below their Miller fields instead
      % of floating in the middle of a tall axes.
      gPF = uigridlayout(app.PFTab, ...
        'ColumnWidth', {'1x','1x','1x'}, 'RowHeight', {26, '1x', 1}, ...
        'Padding', [6 6 6 6], 'RowSpacing', 2, 'ColumnSpacing', 6);
      app.PFGrid = gPF;
      defaults = {'(100)','(010)','(001)'};
      for i = 1:3
        % the Miller field sits centered right above its pole figure; the
        % pencil marks it as editable - cheap uicontrols, built eagerly.
        % The pole figure axes themselves are deferred, see
        % ensureTabAxesBuilt
        gField = uigridlayout(gPF, ...
          'ColumnWidth', {'1x', 22, 110, '1x'}, 'RowHeight', {'1x'}, ...
          'Padding', [0 0 0 0], 'ColumnSpacing', 4);
        gField.Layout.Row = 1; gField.Layout.Column = i;

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

      % --- Images tab: image selection happens in the OptTree now --------
      createImagesTab(app)
    end

    function createImagesTab(app)
      % The images tab is always the last one. Since tabs can only be
      % appended (see the comment in createTabs), it is recreated after
      % the property map tabs of an imported data set have been appended,
      % see populateMapTabs. Image selection happens via the OptTree
      % (right of PhaseTable, see createRightPanel/OptTreeSelectionChanged),
      % so this tab is just the axes - built lazily, see ensureTabAxesBuilt.
      app.ImagesTab = uitab(app.TabGroup, 'Title', 'Images', ...
        'ForegroundColor', app.TabColors.Images);
      app.ImagesAxesParent = uigridlayout(app.ImagesTab, ...
        'ColumnWidth', {'1x'}, 'RowHeight', {'1x'}, ...
        'Padding', [6 6 6 6]);
      % the old ImagesAxes (if any) was a child of the just-deleted
      % previous ImagesTab and is no longer valid - clear the handle so
      % ensureTabAxesBuilt correctly sees this as "not yet built" again
      app.ImagesAxes = matlab.ui.control.UIAxes.empty;
    end

    function [tab, parentGrid] = createLazyPlotTab(app, tabTitle, color)
      % a tab holding nothing but an (empty) full-size grid layout - the
      % axes itself is built on demand, see ensureTabAxesBuilt
      tab = uitab(app.TabGroup, 'Title', tabTitle, 'ForegroundColor', color);
      parentGrid = uigridlayout(tab, 'ColumnWidth', {'1x'}, 'RowHeight', {'1x'}, ...
        'Padding', [6 6 6 6]);
    end

    function [tab, ax] = createPlotTab(app, tabTitle, color)
      % a tab holding nothing but a single full-size axes, built right
      % away - used for the per-property map tabs (populateMapTabs),
      % which only ever get created after a file is already loaded, not
      % at app startup, so there is no startup cost to defer here
      tab = uitab(app.TabGroup, 'Title', tabTitle, 'ForegroundColor', color);
      g = uigridlayout(tab, 'ColumnWidth', {'1x'}, 'RowHeight', {'1x'}, ...
        'Padding', [6 6 6 6]);
      ax = uiaxes(g);
      ax.Layout.Row = 1; ax.Layout.Column = 1;
    end

    function ensureTabAxesBuilt(app, tab)
      % axes are built lazily, the first time their tab is actually shown
      % (~0.88s per axes, measured - see TODO item 29) - this is the
      % single place that guarantees they exist before any plotting code
      % touches them. Called at the top of updatePlot, which every tab
      % switch funnels through: interactive (TabSelectionChanged) and
      % programmatic (both call updatePlot right after setting
      % TabGroup.SelectedTab, see importEBSDData/OptTreeSelectionChanged).
      % Idempotent - already-built groups are left untouched.
      if ~isempty(app.MapTabs) && tab == app.MapTabs(1) && isempty(app.MapAxes)
        app.MapAxes = uiaxes(app.MapAxesParent);
        app.MapAxes(1).Layout.Row = 1; app.MapAxes(1).Layout.Column = 1;
      elseif ~isempty(app.IPFTabs) && any(tab == app.IPFTabs) && isempty(app.IPFAxes)
        for i = 1:3
          app.IPFAxes(i) = uiaxes(app.IPFAxesParent(i));
          app.IPFAxes(i).Layout.Row = 1; app.IPFAxes(i).Layout.Column = 1;
        end
      elseif ~isempty(app.PFTab) && tab == app.PFTab && isempty(app.PFAxes)
        for i = 1:3
          app.PFAxes(i) = uiaxes(app.PFGrid);
          app.PFAxes(i).Layout.Row = 2; app.PFAxes(i).Layout.Column = i;
        end
      elseif ~isempty(app.ImagesTab) && tab == app.ImagesTab && isempty(app.ImagesAxes)
        app.ImagesAxes = uiaxes(app.ImagesAxesParent);
        app.ImagesAxes.Layout.Row = 1; app.ImagesAxes.Layout.Column = 1;
      end
    end

    function navigateToFolder(app, folderPath)
      % Set folderPath as the new browser root and populate its children.
      if ~isfolder(folderPath)
        return
      end

      app.CurrentFolder = string(folderPath);
      app.CurrentPathLabel.Text = char(app.CurrentFolder);

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
          folderNode = uitreenode(parentNode, ...
            'Text', entry.name, ...
            'NodeData', struct('Type', 'Folder', 'Path', fullPath));
          if ~isempty(folderIcon), folderNode.Icon = folderIcon; end
          % Dummy child so the node is expandable; replaced on expand.
          uitreenode(folderNode, 'Text', 'Loading...');
        elseif isEBSDFile(app, entry.name)
          fileNode = uitreenode(parentNode, ...
            'Text', entry.name, ...
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

    function setImportStatus(app, mode, fileName)
      % status label directly below the file tree: an idle hint that a
      % file must be double-clicked (or Enter) to import it, replaced by a
      % differently-colored "loading" message while importEBSDData runs -
      % EBSD.load is synchronous, so without this the UI just appears to
      % hang on a large file
      arguments
        app
        mode (1,1) string
        fileName (1,1) string = ""
      end
      switch mode
        case 'loading'
          app.ImportStatusLabel.Text = char("Loading " + fileName + " ...");
          app.ImportStatusLabel.BackgroundColor = [1.00 0.92 0.70]; % amber - busy
        otherwise % 'idle'
          app.ImportStatusLabel.Text = 'Double-click a file (or select + Enter) to import';
          app.ImportStatusLabel.BackgroundColor = [0.90 0.94 0.98]; % light blue - hint
      end
      drawnow % force the label to actually repaint before a blocking load
    end

    function opts = importOptions(app, entry)
      % the selected list row as EBSD.load options - a file that offers no
      % choice contributes none, so they never reach a format that does
      % not know them
      if nargin < 2, entry = selectedDataSet(app); end

      opts = {};
      if isempty(entry), return, end
      if entry.dataSet > 1, opts = [opts, {'dataSet', entry.dataSet}]; end
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
      filePath = char(filePath); % normalize string -> char so fileparts
                                  % and [fileName fileExt] behave predictably
      [~, fName, fExt] = fileparts(filePath);
      fileName = [fName fExt];

      setImportStatus(app, 'loading', fileName)
      opts = importOptions(app);
      try
        ebsdData = EBSD.load(filePath, 'wizard', opts{:});
      catch ME
        setImportStatus(app, 'idle')
        uialert(app.UIFigure, ME.message, 'Could not load EBSD data')
        return
      end
      setImportStatus(app, 'idle')

      if isempty(ebsdData)
        return
      end

      ensureAnalysisUI(app)

      app.ebsd = ebsdData;
      app.LoadedFilePath = string(filePath); % Store file path for the script exporter
      app.PreviewFilePath = app.LoadedFilePath;
      app.PFODFKey = "";
      app.IPFKeys = {};

      markLoadedDataSet(app, ebsdData)

      % --- paint first: everything up to the flush below is the minimum
      % required for the initial IPF Z view; the remaining setup happens
      % afterwards, while the user is already looking at the map
      invalidateAllSigs(app)
      syncCoordinateControls(app)  % plotIPF reads the coordinate dropdowns
      fillPhaseTable(app)          % ... and the phase selection

      % default view: IPF Z of the (pre-selected) largest phase
      app.TabGroup.SelectedTab = app.IPFTabs(3);
      updatePlot(app, true)
      drawnow                      % first paint

      % --- deferred setup: only appends tabs / updates values, it never
      % reorders the tab group (that would blank the visible plot) -------
      updateCurrentDataInfo(app, app.ebsd, filePath, false)
      app.ExportButton.Text = 'Import to variable';
      populateMapTabs(app)
      populateImagesSelector(app)
    end

    function populateMapTabs(app)
      % (Re)create the property map tabs, one per property of the imported
      % data set. New tabs can only be appended, so to keep the images tab
      % the last one it is recreated afterwards - existing tabs (and in
      % particular the currently visible one) are never touched.

      % the Phase Map tab (index 1) is the one lazily-built tab this
      % function keeps around (see ensureTabAxesBuilt) - force it built
      % now since the code below assumes app.MapAxes(1) already exists,
      % regardless of whether the user has ever actually visited it
      ensureTabAxesBuilt(app, app.MapTabs(1))

      % drop the tabs of a previously loaded data set
      delete(app.MapTabs(2:end))
      app.MapTabs = app.MapTabs(1);
      app.MapAxes = app.MapAxes(1);
      delete(app.ImagesTab)

      names = getPropertyNames(app);
      app.MapNames = [{'Phase Map'}; names(:)];
      for k = 2:numel(app.MapNames)
        [app.MapTabs(k), app.MapAxes(k)] = ...
          createPlotTab(app, app.MapNames{k}, app.TabColors.Maps);
      end

      createImagesTab(app)

      % resize the per-tab render signatures without invalidating the
      % already drawn IPF Z plot
      app.LastSig.Maps = repmat("", 1, max(1, numel(app.MapNames)));
      app.LastSig.Images = "";
    end

    function populateImagesSelector(app)
      % (re)build the OptTree from ebsd.opt: one node per field, image-
      % shaped fields (numeric matrix >= 100x100, same criterion the old
      % dropdown used) are selectable and show up in the Images tab,
      % struct fields recurse as branches, everything else is an
      % informational leaf. The Images tab is dimmed if no image exists
      % anywhere in the tree.
      delete(app.OptTree.Children)
      app.SelectedImagePath = {};
      try
        s = app.ebsd.opt;
      catch
        s = struct();
      end
      hasImage = false;
      if isstruct(s) && isscalar(s)
        hasImage = populateOptNode(app, app.OptTree, s, {});
      end
      if hasImage
        app.ImagesTab.ForegroundColor = app.TabColors.Images;
      else
        app.ImagesTab.ForegroundColor = app.TabColors.Disabled;
      end
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
          % small enough to just show the values - transpose a column
          % vector to a row first so it reads left-to-right like the rest
          % of the preview instead of stacking vertically
          txt = num2str(value(:)');
        elseif isnumeric(value) || islogical(value)
          % sprintf (not '[...]' concatenation) - mixing char and string
          % scalars inside '[...]' silently promotes everything to a
          % string ARRAY (one element per operand) instead of
          % concatenating into a single string, which uitreenode's Text
          % then rejects
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
      % the matrix that a 'OptImage' tree node refers to.
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
      removeStyle(app.PhaseTable)
      % right-align every column except Plot (column 1, a checkbox) and
      % Phase (column 2, a small id, centered instead)
      addStyle(app.PhaseTable, uistyle('HorizontalAlignment', 'center'), 'column', 2)
      addStyle(app.PhaseTable, uistyle('HorizontalAlignment', 'right'), 'column', 3:10)

      csList = app.ebsd.CSList;
      numPhases = accumarray(app.ebsd.phaseId,1,[length(csList),1]);

      phaseTable = table('size',[0 10],...
        'VariableTypes',{'logical','uint8','string','double','double','string','double','double','double','string'},...
        'VariableNames',{'Plot'; 'Phase'; 'Mineral'; 'Pixels'; 'Percent'; 'Symmetry'; 'a'; 'b'; 'c'; 'Color'});

      for pId = 1:length(numPhases)

        cs = csList(pId);
        app.Color{pId} = cs.color;
        if isnan(app.Color{pId}), app.Color{pId} = [1 1 1]; end
        mineral = asChar(app, cs.mineral);
        if isa(cs,'symmetry')
          symmetry = asChar(app, cs.pointGroup);
          a = norm(cs.aAxis);
          b = norm(cs.bAxis);
          c = norm(cs.cAxis);
        else
          mineral = 'NotIndexed';
          symmetry = 'None';
          a = 0; b = 0; c = 0;
        end

        phaseTable(pId, :) = {false, app.ebsd.phaseMap(pId), mineral, ...
           numPhases(pId), 100*numPhases(pId)/sum(numPhases), ...
           symmetry, a, b, c, ''};
      end

      % pre select indexed phase with the most pixels
      numPhases(~[csList.isIndexed]) = 0;
      [~,maxPhase] = max(numPhases);
      phaseTable.Plot(maxPhase) = true;

      app.PhaseTable.Data = phaseTable;

      % mark editable columns in the header so users don't have to
      % double-click every cell to find out what can be changed. This is
      % not simply every ColumnEditable column: Plot (column 1) is a
      % checkbox, self-evidently clickable, so it's excluded; Color
      % (column 10) is edited by clicking the swatch to open a color
      % picker (PhaseTableCellSelection), not through normal cell
      % editing, so it's ColumnEditable=false but still needs the marker
      colNames = phaseTable.Properties.VariableNames;
      colNames{5} = '%'; % 'Percent' is not a valid display header choice
      editableCols = setdiff(find(app.PhaseTable.ColumnEditable), 1);
      editableCols = union(editableCols, 10);
      colNames(editableCols) = cellfun(@(s) [s ' ' char(9998)], ...
        colNames(editableCols), 'UniformOutput', false);
      app.PhaseTable.ColumnName = colNames;

      % colorize color column (now column 10)
      for row = 1:length(csList)
        addStyle(app.PhaseTable, ...
          uistyle('BackgroundColor', app.Color{row}), 'cell', [row 10])
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

      if isempty(app.ebsd) || ~app.AnalysisUICreated
        return
      end

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

      % the maps always show the full data set - the phase selection in
      % the phase table only applies to the IPF maps and the pole figures.
      % The drawn content neither depends on the map coordinate system -
      % when only that changed, realigning the view is all that is needed.
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
      resetAxes(app, ax)

      direction = directionVector(app, dirLabels{ipfIdx});

      % compute the color of every pixel first, then plot the entire map
      % in a single call - this avoids the expensive subsetting of the
      % EBSD data into phases (EBSD/subsref copies all property arrays).
      % Pixels of unselected phases keep NaN colors and are not drawn.
      color = NaN(length(app.ebsd), 3);
      for phaseId = enabledPhaseIds(:)'
        % skip not indexed "phases" - they carry no orientations
        if ~isa(app.ebsd.CSList(phaseId), 'symmetry'), continue; end
        mask = app.ebsd.phaseId == phaseId;
        if ~any(mask), continue; end
        % one precomputed color key per phase - only the direction differs
        % between the IPF tabs and switching it costs nothing
        ipfKey = ipfKeyForPhase(app, phaseId);
        ipfKey.inversePoleFigureDirection = direction;
        ori = orientation(app.ebsd.rotations(mask), app.ebsd.CSList(phaseId));
        color(mask,:) = ipfKey.orientation2color(ori);
      end

      if all(isnan(color(:)))
        title(ax, 'No phase selected'); return
      end

      plot(app.ebsd, color, 'parent', ax)
      setView(app.ebsd.how2plot, ax)
    end

    function plotPoleFigures(app, force)
      enabledPhaseIds = find(app.PhaseTable.Data.Plot);
      applyCurrentCoordinateState(app)

      % spherical axes cannot change their view after plotting, so a map
      % coordinate change requires a replot - but only of the (cheap)
      % pole figures, the cached ODF is reused
      millers = string({app.PFMillerField.Value});
      sig = strjoin(["pf", strjoin(millers,';'), phaseSig(app,enabledPhaseIds), ...
        eulerSig(app), string(app.MapCoordinatesDropDown.ValueIndex)], '|');
      if ~force && sig == app.LastSig.PF, return; end
      app.LastSig.PF = sig;

      pid = dominantEnabledPhase(app, enabledPhaseIds);
      if isempty(pid)
        for i = 1:numel(app.PFAxes)
          resetAxes(app, app.PFAxes(i))
          title(app.PFAxes(i), 'No indexed phase selected')
        end
        return
      end
      ebsdPhase = app.ebsd(app.ebsd.phaseId == pid);

      % the ODF only depends on the phase and the Euler correction, not on
      % the Miller indices or the map view, so compute it once and cache
      % it. When only the Euler correction changed the orientations were
      % merely rotated, so the cached ODF is rotated along instead of
      % being recomputed.
      corr = ebsdPhase.EulerCorrection;
      odfKey = "odf|" + string(pid);
      if odfKey ~= app.PFODFKey || isempty(app.PFODF)
        app.PFODF = calcDensity(ebsdPhase.orientations);
        app.PFODFKey = odfKey;
        app.PFODFCorr = corr;
      elseif angle(corr * inv(app.PFODFCorr)) > 1e-10 %#ok<MINV>
        app.PFODF = rotate(app.PFODF, corr * inv(app.PFODFCorr)); %#ok<MINV>
        app.PFODFCorr = corr;
      end
      odf = app.PFODF;

      for i = 1:numel(app.PFAxes)
        ax = app.PFAxes(i);
        resetAxes(app, ax)
        millerStr = strtrim(app.PFMillerField(i).Value);
        if isempty(millerStr), continue; end
        try
          h = string2Miller(millerStr, ebsdPhase.CS);
        catch
          title(ax, 'invalid Miller'); continue
        end
        % pass the current plotting convention explicitly - the spherical
        % projection would otherwise fall back to odf.SS.how2plot, which
        % does not follow the map coordinate dropdown
        plotPDF(odf, h, 'parent', ax, 'contourf','upper','noTitle',...
          'fontSize', 20,'TL','upper', app.ebsd.how2plot);

        % plot obsolete Euler reference frame
        %rot = [app.CoordinateSystems.how2plot.rot];
        %eulerRot = rot(app.EulerCoordinatesDropDown.ValueIndex);
        %mapRot = rot(app.MapCoordinatesDropDown.ValueIndex);
        %rot = mapRot * inv(eulerRot);
        rot = ebsdPhase.EulerCorrection;
        opt = {'textColor','r','parent',ax,'fontSize',20,'noAntipodal',...
          'backgroundColor','w','noAntipodal'};
        text(rot * [xvector,yvector,zvector] ,{'X','Y','Z'},opt{:});

      end
    end

    function plotImages(app, force)
      if isempty(app.SelectedImagePath)
        resetAxes(app, app.ImagesAxes)
        title(app.ImagesAxes, 'Select an image in the tree to the right of the phase list')
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
      cla(ax, 'reset')
      rmallappdata(ax)
    end

    function s = phaseSig(~, ids)
      s = strjoin(string(ids(:).'), ',');
      if s == "", s = "none"; end
    end

    function s = eulerSig(app)
      % signature of the Euler -> map correction. Built from the rotation
      % itself (not the dropdown indices) so that a map coordinate change,
      % which keeps the correction fixed and only relabels the Euler
      % dropdown, does not invalidate orientation dependent plots.
      try
        [a, b, g] = Euler(app.ebsd.EulerCorrection);
        s = strjoin(string(round([a b g]/degree, 3)), '_');
      catch
        s = "none";
      end
    end

    function key = ipfKeyForPhase(app, phaseId)
      % lazily create and precompute one ipfColorKey per phase. The
      % expensive precomputation depends only on the crystal symmetry, so
      % the key is shared by the IPF X/Y/Z tabs - they merely set their
      % inversePoleFigureDirection before use (ipfColorKey is a handle
      % class, so mutating the direction on the cached key is fine).
      if numel(app.IPFKeys) < phaseId || isempty(app.IPFKeys{phaseId})
        key = ipfColorKey(app.ebsd.CSList(phaseId));
        key.precompute;
        app.IPFKeys{phaseId} = key;
      else
        key = app.IPFKeys{phaseId};
      end
    end

    function pid = dominantEnabledPhase(app, ids)
      % indexed phase with the most pixels among the enabled ones, or []
      pid = [];
      best = -1;
      counts = accumarray(app.ebsd.phaseId, 1, [numel(app.ebsd.CSList) 1]);
      for k = ids(:)'
        if k >= 1 && k <= numel(app.ebsd.CSList) && ...
            isa(app.ebsd.CSList(k), 'symmetry') && counts(k) > best
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
      idx = app.MapCoordinatesDropDown.ValueIndex;
      app.ebsd.how2plot = app.CoordinateSystems.how2plot(idx);

      rot = [app.CoordinateSystems.how2plot.rot];
      eulerRot = rot(app.EulerCoordinatesDropDown.ValueIndex);
      mapRot = rot(app.MapCoordinatesDropDown.ValueIndex);

      % assigning EulerCorrection rewrites all rotations, so skip the
      % assignment when the correction did not actually change
      newCorr = mapRot * inv(eulerRot); %#ok<MINV>
      oldCorr = app.ebsd.EulerCorrection;
      if ~isa(oldCorr, 'quaternion') || isempty(oldCorr) || ...
          angle(newCorr * inv(oldCorr)) > 1e-10 %#ok<MINV>
        app.ebsd.EulerCorrection = newCorr;
      end
    end

    function syncCoordinateControls(app)
      labels = cellstr(app.CoordinateSystems.Label);
      app.MapCoordinatesDropDown.Items = labels;
      app.EulerCoordinatesDropDown.Items = labels;

      mapIdx = closestCoordinateIndex(app, app.ebsd.how2plot.rot);
      app.MapCoordinatesDropDown.ValueIndex = mapIdx;
      setCoordinateImage(app, app.MapImage, mapIdx)

      eulerIdx = mapIdx;
      try
        eulerRot = inv(app.ebsd.EulerCorrection) * app.ebsd.how2plot.rot; %#ok<MINV>
        eulerIdx = closestCoordinateIndex(app, eulerRot);
      catch
      end
      app.EulerCoordinatesDropDown.ValueIndex = eulerIdx;
      setCoordinateImage(app, app.EulerImage, eulerIdx)
    end

    function setCoordinateImage(app, imageHandle, idx)
      if isempty(imageHandle) || idx < 1 || idx > height(app.CoordinateSystems)
        return
      end
      
      % create prefix for map- and euler-images
      if imageHandle == app.MapImage
        prefix = '';   
      elseif imageHandle == app.EulerImage
        prefix = 'euler_'; 
      else
        prefix = '';
      end
      
      % build filename
      filename = char(prefix + app.CoordinateSystems.Key(idx) + ".png");
      imageHandle.ImageSource = filename;
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

    function idx = csIndexForPhase(app, phaseId, fallbackIdx)
      n = numel(app.ebsd.CSList);
      idx = min(max(fallbackIdx, 1), n);

      if isnumeric(phaseId) && isscalar(phaseId)
        candidate = double(phaseId);
        if isfinite(candidate) && candidate == round(candidate) && ...
            candidate >= 1 && candidate <= n
          idx = candidate;
        end
      end
    end

    function tf = isNotIndexed(~, cs)
      tf = (ischar(cs) && strcmpi(cs, 'notIndexed')) || ...
        (isstring(cs) && isscalar(cs) && strcmpi(cs, "notIndexed"));
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
      % date - as a 2-column Property/Value table.
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
          '] x [' xnum2str(ext(3:4), 'delimiter', ',') '] ' scanUnitLabel(app, ebsd)]};
      catch
      end

      try
        [gridLabel, dimsTxt, resolutionTxt] = gridInfo(app, ebsd);
        rows(end+1,:) = {gridLabel, dimsTxt};
        rows(end+1,:) = {'Step Size', resolutionTxt};
      catch
      end

      vendor = vendorLabel(app, ebsd, filePath);
      if ~isempty(vendor), rows(end+1,:) = {'Vendor', vendor}; end

      fileSize = fileSizeLabel(app, filePath);
      if ~isempty(fileSize), rows(end+1,:) = {'File size', fileSize}; end

      created = creationDateLabel(app, ebsd, filePath);
      if ~isempty(created), rows(end+1,:) = {'Created', created}; end

      app.CurrentData.Data = cell2table(rows, 'VariableNames', {'Property','Value'});
    end

    function u = scanUnitLabel(~, ebsd)
      u = 'um';
      try u = char(ebsd.scanUnit); catch, end
      if strcmpi(u, 'um'), u = 'µm'; end
    end

    function [gridLabel, dimsTxt, resolutionTxt] = gridInfo(app, ebsd)
      % gridLabel: 'Square Grid' or 'Hex Grid' (used as the row's
      % Property name); dimsTxt: e.g. '1000 x 500 pixel'; resolutionTxt
      % (shown under "Step Size"): the plain step size value, no 'dx ='/
      % 'dHex =' label - e.g. '60 µm' or '60 x 80 µm' when dx and dy differ
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

    end

    function width = leftPanelWidth(app)
      % Enough room for two coordinate columns plus padding. The labels
      % are the limiting elements, so scale the width with font size.
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
          isa(co, 'matlab.ui.control.DropDown') || ...
          isa(co, 'matlab.ui.control.Table')
        return
      end

      switch event.Key
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
      % folders - only a genuine, recognized EBSD file triggers a preview
      node = app.FileTree.SelectedNodes;
      if ~isscalar(node) || isempty(node.NodeData) || ...
          ~strcmp(node.NodeData.Type, 'File') || ...
          ~isEBSDFile(app, node.NodeData.Path)
        return
      end
      previewEBSDData(app, node.NodeData.Path)
    end

    function previewEBSDData(app, filePath)
      % lightweight, non-intrusive preview: a headerOnly load feeds the
      % file info table (app.CurrentData) and the list of what the file
      % offers to import, without touching app.ebsd - so browsing around
      % never disturbs the currently plotted data set. Failures are
      % silent (no uialert) since this fires on every arrow-key move, not
      % just a deliberate user action.
      filePath = char(filePath);
      sameFile = strcmp(filePath, char(app.PreviewFilePath));
      app.PreviewFilePath = string(filePath);

      % already the actually imported file - show its real info instead
      % of a redundant, more limited "preview" of the same data. Its list
      % is up to date as well, so it is left alone (rebuilding it would
      % drop the selection back onto the first row).
      if strcmp(filePath, char(app.LoadedFilePath))
        updateCurrentDataInfo(app, app.ebsd, filePath, false)
        if ~sameFile, markLoadedDataSet(app, app.ebsd), end
        return
      end

      try
        ebsdPreview = EBSD.load(filePath, 'wizard', 'headerOnly');
      catch
        % not a recognized/loadable format - leave the table as is
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
      if isempty(node.NodeData) || ~strcmp(node.NodeData.Type, 'Folder')
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
        pad = 6; colSpacing = 6; rowSpacing = 2; labelRow = 26;
        colW = (pos(3) - 2*pad - 2*colSpacing) / 3;
        availH = pos(4) - 2*pad - labelRow - 2*rowSpacing - 1;
        app.PFGrid.RowHeight = {labelRow, max(100, min(ceil(1.1*colW), availH)), '1x'};
      catch
      end
    end

    function PFMillerChanged(app, ~)
      updatePlot(app, true)
    end

    function OptTreeSelectionChanged(app, event)
      node = event.SelectedNodes;
      if ~isscalar(node) || isempty(node.NodeData) || ~strcmp(node.NodeData.Type,'Image')
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
          % the phase selection only affects the IPF maps and the pole
          % figures - their signatures include it, so a plain update
          % suffices and the (phase independent) maps stay untouched
          updatePlot(app)

        case 3
          updateMineralName(app, row, event.NewData)
          invalidateAllSigs(app)
          updatePlot(app, true)
      end
    end

    function PhaseTableCellSelection(app, event)
      if isempty(event.Indices) || event.Indices(2) ~= 10
        return
      end

      row = event.Indices(1);

      newColor = uisetcolor(app.Color{row}, 'Select phase color');
      if isequal(newColor, 0), return, end

      app.ebsd.CSList(row).color = newColor;
      app.Color{row} = newColor;

      addStyle(app.PhaseTable, uistyle('BackgroundColor', newColor), 'cell', [row 10])
      invalidateAllSigs(app)
      updatePlot(app, true)
    end

    function setMapCoordinates(app, ~)
      if isempty(app.ebsd)
        return
      end

      mapIdx = app.MapCoordinatesDropDown.ValueIndex;
      setCoordinateImage(app, app.MapImage, mapIdx)

      try
        app.ebsd.how2plot = app.CoordinateSystems.how2plot(mapIdx);
        eulerRot = inv(app.ebsd.EulerCorrection) * app.ebsd.how2plot.rot; %#ok<MINV>
        eulerIdx = closestCoordinateIndex(app, eulerRot);
        app.EulerCoordinatesDropDown.ValueIndex = eulerIdx;
        setCoordinateImage(app, app.EulerImage, eulerIdx)
      catch
      end

      % no invalidation: the Euler correction is kept fixed, so map and
      % IPF content is unchanged - the plotters only realign the view via
      % setView; only the pole figures replot (with the cached ODF)
      updatePlot(app)
    end

    function setEulerCoordinate(app, ~)
      if isempty(app.ebsd)
        return
      end

      setCoordinateImage(app, app.EulerImage, app.EulerCoordinatesDropDown.ValueIndex)

      % IPF maps and pole figures pick up the new Euler correction through
      % their signatures (the cached ODF is rotated, not recomputed);
      % phase and property maps are unaffected
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

    % Dynamically loads and populates MTEX import templates
    % Dynamically loads and populates MTEX import templates safely
    function ExportScriptButtonPushed(app, ~)
      if isempty(app.ebsd) || app.LoadedFilePath == ""
        return
      end

      % 1. Determine the export type - this app only ever loads EBSD data
      exportType = 'EBSD';

      % 2. Read the template file from the MTEX directory safely
      templatePath = fullfile(mtex_path, 'templates', 'import', ['load' exportType 'template.m']);
      if ~exist(templatePath, 'file')
        uialert(app.UIFigure, ['Template file not found: ' templatePath], 'Export Error');
        return;
      end

      try
        % fileread loads the whole text file into a string character vector safely
        str = fileread(templatePath);
      catch ME
        uialert(app.UIFigure, ['Could not read template file: ' ME.message], 'Export Error');
        return;
      end

      % File and path preparations
      [pathStr, baseName, extStr] = fileparts(char(app.LoadedFilePath));

      %% --- Helper: MTEX-like markup replacement function ---
      function replaceMarkup(token, repVal, delLineMarkup)
        if contains(str, token)
          if ~isempty(repVal)
            str = strrep(str, token, repVal);
          elseif nargin > 2 && ~isempty(delLineMarkup)
            str = strrep(str, delLineMarkup, '');
          else
            str = strrep(str, token, '');
          end
        end
      end

      %% 3. Dynamic Replacements based on App Data
      
      % Crystal Symmetry - one entry per phase, joined into a phaseItem
      % array literal. crystalSymmetry and notIndexed share the common
      % phaseItem base class, so they concatenate directly with '[ ]' -
      % no cell array needed. (The previous version joined the entries
      % without ever wrapping them in braces at all, producing e.g.
      % "CS = crystalSymmetry(...), 'notIndexed', ;" - not valid MATLAB.)
      csLines = {};
      for k = 1:numel(app.ebsd.CSList)
        cs = app.ebsd.CSList(k);

        % Check if the phase is "notIndexed" by class, not by mineral
        % name - the mineral name is user-renameable (see item 25 below)
        % and must not be what decides which branch runs.
        isNotIndexed = ischar(cs) || isa(cs, 'notIndexed');

        if isNotIndexed
          % carry over the color set for this phase in the wizard's phase
          % table, and the mineral name only if it was actually renamed
          % away from the default. notIndexed(name,color) is
          % positional-only (see geometry/notIndexed.m), so a customized
          % color still needs some name written out in front of it - only
          % the fully-default case can drop the argument list entirely.
          hasColor = isobject(cs) && isprop(cs, 'color') && numel(cs.color) == 3 && ~any(isnan(cs.color));
          if isobject(cs) && isprop(cs,'mineral') && ~strcmpi(char(cs.mineral),'notIndexed')
            nameArg = char(cs.mineral);
          else
            nameArg = 'notIndexed';
          end
          if strcmp(nameArg,'notIndexed') && ~hasColor
            csLines{end+1} = '  notIndexed()'; %#ok<AGROW>
          else
            col = [1 1 1];
            if hasColor, col = double(cs.color); end
            csLines{end+1} = sprintf('  notIndexed(''%s'', [%.4f, %.4f, %.4f])', ...
              nameArg, col(1), col(2), col(3)); %#ok<AGROW>
          end
        else
          % Safe extraction with fallbacks to avoid crashes
          try
            pg = char(cs.pointGroup);
            abc = [norm(cs.aAxis), norm(cs.bAxis), norm(cs.cAxis)];
            minName = char(cs.mineral);

            % cubic/orthorhombic/trigonal/tetragonal/hexagonal have their
            % angles implied by the lattice type (crystalSymmetry defaults
            % to lattice.defaultAngles when the angle argument is
            % omitted, see geometry/latticeType.m) - only monoclinic and
            % triclinic have angles that actually vary and must be
            % written out explicitly
            impliedAngles = ismember(cs.lattice, [latticeType.cubic, ...
              latticeType.orthorhombic, latticeType.trigonal, ...
              latticeType.tetragonal, latticeType.hexagonal]);

            if impliedAngles
              csLines{end+1} = sprintf('  crystalSymmetry(''%s'', [%.4f, %.4f, %.4f], ''mineral'', ''%s'')', ...
                pg, abc(1), abc(2), abc(3), minName); %#ok<AGROW>
            else
              ang = [cs.alpha, cs.beta, cs.gamma] / degree;
              csLines{end+1} = sprintf('  crystalSymmetry(''%s'', [%.4f, %.4f, %.4f], [%.1f, %.1f, %.1f], ''mineral'', ''%s'')', ...
                pg, abc(1), abc(2), abc(3), ang(1), ang(2), ang(3), minName); %#ok<AGROW>
            end
          catch
            % Fallback if it's an unrecognized or empty phase structure
            csLines{end+1} = '  notIndexed(''notIndexed'')'; %#ok<AGROW>
          end
        end
      end
      csBlock = ['[' char(10) strjoin(csLines, [', ...' char(10)]) char(10) ']'];
      str = strrep(str, '{crystal symmetry}', csBlock);

      % Specimen Symmetry
      replaceMarkup('{specimen symmetry}', 'specimenSymmetry(''1'')');

      function s = vectorLiteral(v)
        % render a principal-direction vector3d as xvector/-xvector/... ,
        % falling back to an explicit vector3d(...) for anything else
        v = double(v(:))';
        names = {'xvector', 'yvector', 'zvector'};
        for k = 1:3
          ev = zeros(1,3); ev(k) = 1;
          if norm(v - ev) < 1e-6
            s = names{k};
            return
          elseif norm(v + ev) < 1e-6
            s = ['-' names{k}];
            return
          end
        end
        s = sprintf('vector3d(%s)', mat2str(v));
      end

      % Plotting Convention
      mapIdx = app.MapCoordinatesDropDown.ValueIndex;
      mapObj = app.CoordinateSystems.how2plot(mapIdx);
      replaceMarkup('{zAxisDirection}', vectorLiteral(mapObj.outOfScreen));
      replaceMarkup('{xAxisDirection}', vectorLiteral(mapObj.east));

      % File Paths & Names
      safePath = strrep(pathStr, "'", "''");
      safeFile = strrep([baseName extStr], "'", "''");
      replaceMarkup('{path to files}', sprintf('''%s''', safePath));
      replaceMarkup('{file names}', sprintf('[pname filesep ''%s'']', safeFile));

      % Options (the interface/file format is auto-detected from the file
      % extension by EBSD.load - forcing 'wizard' here, as before, made
      % EBSD.load's own dispatcher fail to recognize the format and fall
      % through to the generic loader instead of e.g. loadEBSD_ctf).
      % What does have to be written out is which data set of a multi map
      % file was picked and whether the recorded instead of the post
      % processed data was taken - without them the script would silently
      % import something else than the wizard showed.
      optList = {};
      entry = selectedDataSet(app);
      if ~isempty(entry)
        if entry.dataSet > 1
          optList{end+1} = sprintf('''dataSet'',%d', entry.dataSet);
        end
      end
      replaceMarkup('{options}', strjoin(optList, ','), ',{options}');

      % Euler Correction - passed as the EulerCorrection option of
      % EBSD.load itself (see loadEBSDtemplate.m), not applied via a
      % separate post-load rotate() call: EulerCorrection is a proper
      % EBSD.load option (see EBSD/load.m and how mtexdata.m's built-in
      % loaders use it), and rotate() after the fact is a different,
      % non-equivalent mechanism. Written as rotation.map(...) so the
      % script makes explicit which map axes get rotated onto which
      % Euler axes, rather than an opaque set of Euler angles.
      eulerIdx = app.EulerCoordinatesDropDown.ValueIndex;
      eulerObj = app.CoordinateSystems.how2plot(eulerIdx);
      replaceMarkup('{eulerCorrection}', sprintf('rotation.map(%s,%s,%s,%s)', ...
        vectorLiteral(eulerObj.east), vectorLiteral(mapObj.east), ...
        vectorLiteral(eulerObj.outOfScreen), vectorLiteral(mapObj.outOfScreen)));

      % Dominant Phase (for the sanity-check plot)
      plotMask = logical(app.PhaseTable.Data.Plot);
      domRow = find(plotMask, 1);
      if isempty(domRow), domRow = 1; end
      replaceMarkup('{dominantMineral}', char(app.PhaseTable.Data.Mineral(domRow)));

      % Corrections / Coefficients
      replaceMarkup('{corrections}', '', '{corrections}');
      replaceMarkup('c = {structural coefficients}', '', 'c = {structural coefficients}');

      %% 4. Open the generated script in the editor - not saved to disk
      matlab.desktop.editor.newDocument(str);
    end
  end
  methods (Access = public)
    function app = import_wizard
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
      if ~isempty(app.UIFigure) && isvalid(app.UIFigure)
        delete(app.UIFigure)
      end
    end
  end
end