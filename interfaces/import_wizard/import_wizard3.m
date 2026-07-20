classdef import_wizard3 < matlab.apps.AppBase
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
    CurrentData                    matlab.ui.control.TextArea
    PhaseTable                     matlab.ui.control.Table
    ExportButton                   matlab.ui.control.Button
    ExportScriptTypeDropDown       matlab.ui.control.DropDown
    ExportScriptButton             matlab.ui.control.Button % Button for generating an MTEX script


    TabGroup                       matlab.ui.container.TabGroup
    MapTabs                        matlab.ui.container.Tab       % phase map + one tab per property
    MapAxes                        matlab.ui.control.UIAxes      % parallel to MapTabs
    IPFTabs                        matlab.ui.container.Tab       % 1x3 array: IPF X / Y / Z
    IPFAxes                        matlab.ui.control.UIAxes      % 1x3 array
    PFTab                          matlab.ui.container.Tab
    PFGrid                         matlab.ui.container.GridLayout
    ImagesTab                      matlab.ui.container.Tab
    PFMillerField                  matlab.ui.control.EditField   % 1x3 array
    PFAxes                         matlab.ui.control.UIAxes      % 1x3 array
    ImagesDropDown                 matlab.ui.control.DropDown
    ImagesAxes                     matlab.ui.control.UIAxes

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
    ImagePaths cell = {}        % field-name paths parallel to ImagesDropDown items
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
        'RowHeight', {270, 118, '1x', 210, 80}, ...
        'RowSpacing', 10, ...
        'Padding', [0 0 0 0]);

      createFileBrowser(app)

      app.CurrentData = uitextarea(app.LeftLayout, ...
        'Editable', 'off', ...
        'FontSize', app.FontSize - 1, ...
        'Value', {'No EBSD data loaded'});
      app.CurrentData.Layout.Row = 2;

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
      % into a folder or imports a file, Backspace navigates up.
      app.FileBrowserPanel = uipanel(app.LeftLayout, 'BorderType', 'line');
      app.FileBrowserPanel.Layout.Row = 1;

      app.FileBrowserLayout = uigridlayout(app.FileBrowserPanel, ...
        'ColumnWidth', {30, '1x'}, ...
        'RowHeight', {24, '1x'}, ...
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
        'DoubleClickedFcn', createCallbackFcn(app, @FileTreeDoubleClicked, true));
      app.FileTree.Layout.Row = 2;
      app.FileTree.Layout.Column = [1 2];

      navigateToFolder(app, pwd)
    end

    function ensureAnalysisUI(app)
      if app.AnalysisUICreated
        return
      end

      createCoordinateControls(app)
      createExportButtonsPanel(app) % Combined layout setup for both buttons
      createRightPanel(app)

      app.AnalysisUICreated = true;
    end

    function createCoordinateControls(app)
      labels = cellstr(app.CoordinateSystems.Label);

      app.CoordinatePanel = uipanel(app.LeftLayout, ...
        'Title', 'Coordinate systems', ...
        'FontWeight', 'bold', ...
        'FontSize', app.FontSize);
      app.CoordinatePanel.Layout.Row = 4;

      app.CoordinateLayout = uigridlayout(app.CoordinatePanel, ...
        'ColumnWidth', {'1x', '1x'}, ...
        'RowHeight', {22, 30, '1x'}, ...
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

    % Replaces the single button setup with a 2-column grid layout for both actions
    function createExportButtonsPanel(app)
      buttonGrid = uigridlayout(app.LeftLayout, ...
        'ColumnWidth', {'1x', '1x'}, ...
        'RowHeight', {35, 35}, ...
        'Padding', [0 0 0 0], ...
        'RowSpacing', 8,...
        'ColumnSpacing', 10);
      buttonGrid.Layout.Row = 5;

      app.ExportButton = uibutton(buttonGrid, 'push', ...
        'ButtonPushedFcn', createCallbackFcn(app, @ExportButtonPushed, true), ...
        'FontWeight', 'bold', ...
        'FontSize', app.FontSize, ...
        'Text', 'Import to workspace');
      app.ExportButton.Layout.Row = 1;
      app.ExportButton.Layout.Column = [1 2];

      app.ExportScriptTypeDropDown = uidropdown(buttonGrid, ...
        'Items', ["EBSD", "ODF", "PoleFigure", "tensor"], ...
        'FontWeight', 'bold', ...
        'FontSize', app.FontSize);
      app.ExportScriptTypeDropDown.Layout.Row = 2;
      app.ExportScriptTypeDropDown.Layout.Column = 1;

      app.ExportScriptButton = uibutton(buttonGrid, 'push', ...
        'ButtonPushedFcn', createCallbackFcn(app, @ExportScriptButtonPushed, true), ...
        'FontWeight', 'bold', ...
        'FontSize', app.FontSize, ...
        'Text', 'Export to Script');
      app.ExportScriptButton.Layout.Row = 2;
      app.ExportScriptButton.Layout.Column = 2;

    end

    function createRightPanel(app)
      app.RightLayout = uigridlayout(app.RightPanel, ...
        'ColumnWidth', {'1x'}, ...
        'RowHeight', {230, '1x'}, ...
        'RowSpacing', 8, ...
        'Padding', [0 0 0 0]);

      app.PhaseTable = uitable(app.RightLayout, ...
        'ColumnEditable', [true false true false false false false false false], ...
        'RowName', {}, ...
        'CellEditCallback', createCallbackFcn(app, @PhaseTableCellEdit, true), ...
        'CellSelectionCallback', createCallbackFcn(app, @PhaseTableCellSelection, true), ...
        'FontSize', app.FontSize - 1);
      app.PhaseTable.Layout.Row = 1;

      createTabs(app)
    end

    function createTabs(app)
      % The plot area is a tab group. Every view is its own tab owning its
      % own axes so that no single axis is ever repurposed between a map,
      % an IPF map, a pole figure and an image - which previously forced
      % fragile cla/reset and appdata juggling and broke the scale bar
      % lifecycle. Tab labels are colorized by category (maps, IPF, pole
      % figures, images).
      app.TabGroup = uitabgroup(app.RightLayout, ...
        'SelectionChangedFcn', createCallbackFcn(app, @TabSelectionChanged, true));
      app.TabGroup.Layout.Row = 2;

      % The tabs are created directly in their display order - the tab
      % group is never reordered through its Children property, since
      % that makes the renderer rebuild the whole group, which is slow
      % and briefly blanks the currently visible plot.

      % --- map tabs: the phase map now, one tab per property at import ---
      [app.MapTabs, app.MapAxes] = createPlotTab(app, 'Phase Map', app.TabColors.Maps);
      app.MapNames = {'Phase Map'};

      % --- IPF tabs: one tab per direction, Z first -----------------------
      [tz, az] = createPlotTab(app, 'IPF Z', app.TabColors.IPF);
      [ty, ay] = createPlotTab(app, 'IPF Y', app.TabColors.IPF);
      [tx, ax] = createPlotTab(app, 'IPF X', app.TabColors.IPF);
      app.IPFTabs = [tx, ty, tz];   % index 1/2/3 = direction X/Y/Z
      app.IPFAxes = [ax, ay, az];

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
        % pencil marks it as editable
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

        app.PFAxes(i) = uiaxes(gPF);
        app.PFAxes(i).Layout.Row = 2; app.PFAxes(i).Layout.Column = i;
      end

      app.PFTab.AutoResizeChildren = 'off';
      app.PFTab.SizeChangedFcn = createCallbackFcn(app, @PFTabSizeChanged, true);
      PFTabSizeChanged(app, [])

      % --- Images tab: opt-images via a dropdown --------------------------
      createImagesTab(app)
    end

    function createImagesTab(app)
      % The images tab is always the last one. Since tabs can only be
      % appended (see the comment in createTabs), it is recreated after
      % the property map tabs of an imported data set have been appended,
      % see populateMapTabs.
      app.ImagesTab = uitab(app.TabGroup, 'Title', 'Images', ...
        'ForegroundColor', app.TabColors.Images);
      gImg = uigridlayout(app.ImagesTab, ...
        'ColumnWidth', {120, '1x'}, 'RowHeight', {22, 30, '1x'}, ...
        'Padding', [6 6 6 6], 'RowSpacing', 6, 'ColumnSpacing', 12);

      lblImg = uilabel(gImg, 'Text', 'Image:', 'HorizontalAlignment', 'left', ...
        'FontSize', app.FontSize);
      lblImg.Layout.Row = 1; lblImg.Layout.Column = 1;

      app.ImagesDropDown = uidropdown(gImg, 'Items', {'(none)'}, ...
        'FontSize', app.FontSize, ...
        'ValueChangedFcn', createCallbackFcn(app, @ImagesViewChanged, true));
      app.ImagesDropDown.Layout.Row = 2; app.ImagesDropDown.Layout.Column = 1;

      app.ImagesAxes = uiaxes(gImg);
      app.ImagesAxes.Layout.Row = [1 3]; app.ImagesAxes.Layout.Column = 2;
    end

    function [tab, ax] = createPlotTab(app, tabTitle, color)
      % a tab holding nothing but a single full-size axes
      tab = uitab(app.TabGroup, 'Title', tabTitle, 'ForegroundColor', color);
      g = uigridlayout(tab, 'ColumnWidth', {'1x'}, 'RowHeight', {'1x'}, ...
        'Padding', [6 6 6 6]);
      ax = uiaxes(g);
      ax.Layout.Row = 1; ax.Layout.Column = 1;
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

    function importEBSDData(app, filePath)
      filePath = char(filePath); % normalize string -> char so fileparts
                                  % and [fileName fileExt] behave predictably
      try
        ebsdData = EBSD.load(filePath, 'wizard');
      catch ME
        uialert(app.UIFigure, ME.message, 'Could not load EBSD data')
        return
      end

      if isempty(ebsdData)
        return
      end

      [~, fileName, fileExt] = fileparts(filePath);
      fileName = [fileName fileExt];

      ensureAnalysisUI(app)

      app.ebsd = ebsdData;
      app.LoadedFilePath = string(filePath); % Store file path for the script exporter
      app.PFODFKey = "";
      app.IPFKeys = {};

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
      updateCurrentDataInfo(app, fileName)
      app.ExportButton.Text = 'Import to workspace';
      populateMapTabs(app)
      populateImagesSelector(app)
    end

    function populateMapTabs(app)
      % (Re)create the property map tabs, one per property of the imported
      % data set. New tabs can only be appended, so to keep the images tab
      % the last one it is recreated afterwards - existing tabs (and in
      % particular the currently visible one) are never touched.

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
      % fill the Images dropdown (matrices found anywhere in ebsd.opt)
      [imgNames, imgPaths] = collectImageFields(app, app.ebsd.opt, {});
      app.ImagePaths = imgPaths;
      if isempty(imgNames)
        app.ImagesDropDown.Items = {'(none)'};
        app.ImagesDropDown.ItemsData = {};
        app.ImagesTab.ForegroundColor = app.TabColors.Disabled;
      else
        app.ImagesDropDown.Items = imgNames;
        app.ImagesDropDown.ItemsData = 1:numel(imgNames);
        app.ImagesDropDown.Value = 1;
        app.ImagesTab.ForegroundColor = app.TabColors.Images;
      end
    end

    function [names, paths] = collectImageFields(app, s, prefix)
      % Recursively walk struct s (e.g. ebsd.opt). Return a flat list of
      % display names (nested fields joined with '.') and matching
      % field-name path cells for every numeric matrix of at least 100x100.
      names = {};
      paths = {};

      if ~isstruct(s) || ~isscalar(s)
        return
      end

      fields = fieldnames(s);
      for k = 1:numel(fields)
        field = fields{k};
        value = s.(field);
        thisPath = [prefix, {field}];
        if isempty(prefix)
          displayName = field;
        else
          displayName = [strjoin(prefix, '.') '.' field];
        end

        if isnumeric(value) && ismatrix(value) && ...
            size(value,1) >= 100 && size(value,2) >= 100
          names{end+1} = displayName;   %#ok<AGROW>
          paths{end+1} = thisPath;       %#ok<AGROW>
        elseif isstruct(value) && isscalar(value)
          [childNames, childPaths] = collectImageFields(app, value, thisPath);
          names = [names, childNames];   %#ok<AGROW>
          paths = [paths, childPaths];   %#ok<AGROW>
        end
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
      addStyle(app.PhaseTable, uistyle('HorizontalAlignment', 'left'))

      csList = app.ebsd.CSList;
      numPhases = accumarray(app.ebsd.phaseId,1,[length(csList),1]);
            
      phaseTable = table('size',[0 9],...
        'VariableTypes',{'logical','uint8','string','string','string','double','double','double','string'},...
        'VariableNames',{'Plot'; 'Phase'; 'Mineral'; 'Pixel'; 'Symmetry'; 'a'; 'b'; 'c'; 'Color'});

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
           [int2str(numPhases(pId)),' (' xnum2str(100*numPhases(pId)/sum(numPhases)) '%)'], ...
           symmetry, a, b, c, ''};     
      end

      % pre select indexed phase with the most pixels
      numPhases(~[csList.isIndexed]) = 0;
      [~,maxPhase] = max(numPhases);
      phaseTable.Plot(maxPhase) = true;

      app.PhaseTable.Data = phaseTable;

      % mark editable columns in the header so users don't have to
      % double-click every cell to find out what can be changed
      colNames = phaseTable.Properties.VariableNames;
      editableCols = find(app.PhaseTable.ColumnEditable);
      colNames(editableCols) = cellfun(@(s) [s ' ' char(9998)], ...
        colNames(editableCols), 'UniformOutput', false);
      app.PhaseTable.ColumnName = colNames;

      % colorize color column
      for row = 1:length(csList)
        addStyle(app.PhaseTable, ...
          uistyle('BackgroundColor', app.Color{row}), 'cell', [row 9])
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
      if isempty(app.ImagePaths)
        resetAxes(app, app.ImagesAxes)
        title(app.ImagesAxes, 'No images in ebsd.opt')
        return
      end

      idx = app.ImagesDropDown.Value;   % numeric index via ItemsData
      if isempty(idx) || ~isnumeric(idx), idx = 1; end

      sig = strjoin(["img", string(idx)], '|');
      if ~force && sig == app.LastSig.Images, return; end
      app.LastSig.Images = sig;

      ax = app.ImagesAxes;
      resetAxes(app, ax)
      image = resolveOptImage(app, app.ImagePaths{idx});
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

    function updateCurrentDataInfo(app, fileName)
      % basic information about the loaded data set: file name, spatial
      % extent in scan units, grid geometry in pixels and, when they can
      % be determined, the vendor and the creation date
      lines = {['File: ' asChar(app, fileName)]};

      try
        ext = app.ebsd.extent;
        lines{end+1} = ['Coordinates: [' xnum2str(ext(1:2), 'delimiter', ',') ...
          '] x [' xnum2str(ext(3:4), 'delimiter', ',') '] ' scanUnitLabel(app)];
      catch
      end

      try lines{end+1} = gridInfoLabel(app); catch, end

      vendor = vendorLabel(app);
      if ~isempty(vendor), lines{end+1} = ['Vendor: ' vendor]; end

      created = creationDateLabel(app);
      if ~isempty(created), lines{end+1} = ['Created: ' created]; end

      app.CurrentData.Value = lines(:);
    end

    function u = scanUnitLabel(app)
      u = 'um';
      try u = char(app.ebsd.scanUnit); catch, end
      if strcmpi(u, 'um'), u = 'µm'; end
    end

    function txt = gridInfoLabel(app)
      % e.g. 'Hex grid: 1000 x 500 pixel, dHex = 60 µm'
      %   or 'Square grid: 1000 x 500 pixel, dx = 60 µm'
      ebsd = app.ebsd;
      u = scanUnitLabel(app);
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
        prefix = 'Hex grid: ';
        stepTxt = ['dHex = ' xnum2str(dHex) ' ' u];

      else % square grid

        dx = max(ebsd.unitCell.x) - min(ebsd.unitCell.x);
        dy = max(ebsd.unitCell.y) - min(ebsd.unitCell.y);
        prefix = 'Square grid: ';
        if abs(dx - dy) < 1e-4 * max(dx, dy)
          stepTxt = ['dx = ' xnum2str(dx) ' ' u];
        else
          stepTxt = ['dx = ' xnum2str(dx) ', dy = ' xnum2str(dy) ' ' u];
        end

      end

      nx = round((xmax - xmin) / dx) + 1;
      ny = round((ymax - ymin) / dy) + 1;
      txt = [prefix int2str(nx) ' x ' int2str(ny) ' pixel, ' stepTxt];
    end

    function txt = vendorLabel(app)
      % vendor from the file metadata if present, otherwise a guess based
      % on the file format
      txt = findMetaField(app, app.ebsd.opt, {'manufacturer', 'vendor'}, 3);
      if ~isempty(txt), return, end

      vendors = struct( ...
        'ang', 'EDAX / TSL', 'osc', 'EDAX / TSL', 'tsl', 'EDAX / TSL', ...
        'oh5', 'EDAX / TSL', 'ctf', 'Oxford Instruments', ...
        'crc', 'Oxford Instruments', 'cpr', 'Oxford Instruments', ...
        'hkl', 'Oxford Instruments', 'h5oina', 'Oxford Instruments', ...
        'dream3d', 'DREAM.3D');
      [~, ~, ext] = fileparts(char(app.LoadedFilePath));
      ext = lower(erase(ext, '.'));
      if isfield(vendors, ext), txt = vendors.(ext); end
    end

    function txt = creationDateLabel(app)
      % acquisition date from the file metadata if present, otherwise the
      % file system date
      txt = findMetaField(app, app.ebsd.opt, {'date'}, 3);
      if isempty(txt)
        listing = dir(char(app.LoadedFilePath));
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
      % CurrentObject is the last *clicked* component - for pure keyboard
      % navigation it is empty, so only block when the user demonstrably
      % interacted with some other control last. (Text inputs never reach
      % this callback anyway, they capture their keystrokes themselves.)
      co = app.UIFigure.CurrentObject;
      if ~(isempty(co) || isequal(co, app.UIFigure) || ...
          isequal(co, app.FileTree) || isa(co, 'matlab.ui.container.TreeNode'))
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

    function ImagesViewChanged(app, ~)
      updatePlot(app)
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
      if isempty(event.Indices) || event.Indices(2) ~= 9
        return
      end

      row = event.Indices(1);
      
      newColor = uisetcolor(app.Color{row}, 'Select phase color');
      if isequal(newColor, 0), return, end

      app.ebsd.CSList(row).color = newColor;
      app.Color{row} = newColor;

      addStyle(app.PhaseTable, uistyle('BackgroundColor', newColor), 'cell', [row 9])
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

      answer = inputdlg( ...    
        'Variable name:', ...
        'Import to workspace', ...
        [1 50], ...
        {'ebsd'});

      if isempty(answer)
        return % user cancelled
      end

      varName = strtrim(answer{1});
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
      commandwindow
    end

    % Dynamically loads and populates MTEX import templates
    % Dynamically loads and populates MTEX import templates safely
    function ExportScriptButtonPushed(app, ~)
      if isempty(app.ebsd) || app.LoadedFilePath == ""
        return
      end

      % 1. Determine the export type
      % TODO let the user pick the type
      exportType = app.ExportScriptTypeDropDown.Value; 
      
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
      safeName = matlab.lang.makeValidName(string(baseName));
      scriptFileName = char(safeName + ".m");

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
      
      % Crystal Symmetry
      csLines = {'...'};
      for k = 1:numel(app.ebsd.CSList)
        cs = app.ebsd.CSList(k);
        
        % Check if the phase is "notIndexed" (can be a char, a special object, or have the mineral name 'notIndexed')
        isNotIndexed = ischar(cs) || ...
                       (isprop(cs, 'mineral') && strcmpi(char(cs.mineral), 'notIndexed')) || ...
                       (isfield(cs, 'mineral') && strcmpi(char(cs.mineral), 'notIndexed'));
                   
        if isNotIndexed
          csLines{end+1} = '  ''notIndexed'', ...'; %#ok<AGROW>
        else
          % Safe extraction with fallbacks to avoid crashes
          try
            pg = char(cs.pointGroup);
            abc = [norm(cs.aAxis), norm(cs.bAxis), norm(cs.cAxis)];
            ang = [cs.alpha, cs.beta, cs.gamma] / degree;
            minName = char(cs.mineral);
            
            csLines{end+1} = sprintf('  crystalSymmetry(''%s'', [%.4f, %.4f, %.4f], [%.1f, %.1f, %.1f], ''mineral'', ''%s''), ...', ...
              pg, abc(1), abc(2), abc(3), ang(1), ang(2), ang(3), minName); %#ok<AGROW>
          catch
            % Fallback if it's an unrecognized or empty phase structure
            csLines{end+1} = '  ''notIndexed'', ...'; %#ok<AGROW>
          end
        end
      end
      csLines{end+1} = '  ';
      str = strrep(str, '{crystal symmetry}', strjoin(csLines, [char(10) '']));

      % Specimen Symmetry
      replaceMarkup('{specimen symmetry}', 'specimenSymmetry(''1'')');

      % Plotting Convention
      mapIdx = app.MapCoordinatesDropDown.ValueIndex;
      mapObj = app.CoordinateSystems.how2plot(mapIdx);
      replaceMarkup('{zAxisDirection}', sprintf('vector3d(%s)', mat2str(double(mapObj.outOfScreen))));
      replaceMarkup('{xAxisDirection}', sprintf('vector3d(%s)', mat2str(double(mapObj.east))));

      % File Paths & Names
      safePath = strrep(pathStr, "'", "''");
      safeFile = strrep([baseName extStr], "'", "''");
      replaceMarkup('{path to files}', sprintf('''%s''', safePath));
      replaceMarkup('{file names}', sprintf('[pname filesep ''%s'']', safeFile));

      % Interface and Options
      replaceMarkup('{interface}', '''wizard''', ',{interface}');
      replaceMarkup('{options}', '', ',{options}');

      % Z-Values
      replaceMarkup('{Z-values}', '[]', 'Z = {Z-values};');
      replaceMarkup('{Z}', '', ',{Z}');

      % Euler Corrections (phi1, Phi, phi2)
      try
        [p1, p2, p3] = Euler(app.ebsd.EulerCorrection, 'ZXZ');
        replaceMarkup('{phi1}', sprintf('%.4f*degree', p1/degree));
        replaceMarkup('{Phi}',  sprintf('%.4f*degree', p2/degree));
        replaceMarkup('{phi2}', sprintf('%.4f*degree', p3/degree));
      catch
        replaceMarkup('{phi1}', '0*degree');
        replaceMarkup('{Phi}',  '0*degree');
        replaceMarkup('{phi2}', '0*degree');
      end
      replaceMarkup('{rotationOption}', '', ',{rotationOption}');
      
      % Corrections / Coefficients
      replaceMarkup('{corrections}', '', '{corrections}');
      replaceMarkup('c = {structural coefficients}', '', 'c = {structural coefficients}');

      %% 4. Save and open script
      fid = fopen(scriptFileName, 'wt'); % 'wt' explicitly opens in text mode for correct line endings
      if fid ~= -1
        fprintf(fid, '%s', str);
        fclose(fid);
        matlab.desktop.editor.openDocument(fullfile(pwd, scriptFileName));
      else
        matlab.desktop.editor.newDocument(str);
      end
    end
  end
  methods (Access = public)
    function app = import_wizard3
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