classdef import_wizard3 < matlab.apps.AppBase
  % EBSD app variant with lazy analysis UI, checkbox tree plot selection,
  % compact layout, and a single self-contained updatePlot routine.

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
    ExportScriptButton             matlab.ui.control.Button % Button for generating an MTEX script

    TabGroup                       matlab.ui.container.TabGroup
    MapsTab                        matlab.ui.container.Tab
    IPFTab                         matlab.ui.container.Tab
    PFTab                          matlab.ui.container.Tab
    ImagesTab                      matlab.ui.container.Tab
    MapsDropDown                   matlab.ui.control.DropDown
    MapsAxes                       matlab.ui.control.UIAxes
    IPFDirectionDropDown           matlab.ui.control.DropDown
    IPFAxes                        matlab.ui.control.UIAxes
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
    LastSig struct = struct('Maps',"",'IPF',"",'PF',"",'Images',"")
    FontSize double = 14
    CurrentFolder string = ""
    LoadedFilePath string = "" % Keeps track of the path of the imported EBSD file
    ImagePaths cell = {}        % field-name paths parallel to ImagesDropDown items
    PFODF = []                  % cached ODF for the pole figure tab
    PFODFKey string = ""        % cache key describing what PFODF was computed from
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
  end

  methods (Access = private)
    function createComponents(app)
      leftWidth = app.leftPanelWidth();

      app.UIFigure = uifigure('Visible', 'off');
      app.UIFigure.Position = [100 100 1300 700];
      app.UIFigure.WindowState = 'maximized';
      app.UIFigure.Name = 'MTEX Import Wizard';
      try
        app.UIFigure.Theme = 'light';
      catch
      end

      app.EBSDDataAnalysisPanel = uipanel(app.UIFigure, ...
        'Title', 'EBSD Data Analysis', ...
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
        'RowHeight', {270, 95, '1x', 250, 40}, ...
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
    end

    function createFileBrowser(app)
      % Compact inline file browser (top-left): a uitree showing folders
      % and EBSD files of the current directory, plus a back button and
      % path label for navigation. Double-clicking a file imports it;
      % single-clicking (selecting) a folder navigates into it.
      app.FileBrowserPanel = uipanel(app.LeftLayout, 'BorderType', 'line');
      app.FileBrowserPanel.Layout.Row = 1;

      app.FileBrowserLayout = uigridlayout(app.FileBrowserPanel, ...
        'ColumnWidth', {30, '1x'}, ...
        'RowHeight', {24, '1x'}, ...
        'ColumnSpacing', 4, ...
        'RowSpacing', 2, ...
        'Padding', [4 4 4 4]);

      app.UpFolderButton = uibutton(app.FileBrowserLayout, 'push', ...
        'Text', char(8593), ... % "↑"
        'Tooltip', 'Up one folder', ...
        'FontWeight', 'bold', ...
        'ButtonPushedFcn', createCallbackFcn(app, @UpFolderButtonPushed, true));
      app.UpFolderButton.Layout.Row = 1;
      app.UpFolderButton.Layout.Column = 1;

      app.CurrentPathLabel = uilabel(app.FileBrowserLayout, ...
        'Text', '', ...
        'FontSize', app.FontSize - 2, ...
        'Interpreter', 'none');
      app.CurrentPathLabel.Layout.Row = 1;
      app.CurrentPathLabel.Layout.Column = 2;

      app.FileTree = uitree(app.FileBrowserLayout, ...
        'FontSize', app.FontSize - 1, ...
        'SelectionChangedFcn', createCallbackFcn(app, @FileTreeSelectionChanged, true), ...
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
        'RowHeight', {'1x'}, ...
        'Padding', [0 0 0 0], ...
        'ColumnSpacing', 10);
      buttonGrid.Layout.Row = 5;

      app.ExportButton = uibutton(buttonGrid, 'push', ...
        'ButtonPushedFcn', createCallbackFcn(app, @ExportButtonPushed, true), ...
        'FontWeight', 'bold', ...
        'FontSize', app.FontSize, ...
        'Text', 'Import to workspace');
      app.ExportButton.Layout.Row = 1;
      app.ExportButton.Layout.Column = 1;

      app.ExportScriptButton = uibutton(buttonGrid, 'push', ...
        'ButtonPushedFcn', createCallbackFcn(app, @ExportScriptButtonPushed, true), ...
        'FontWeight', 'bold', ...
        'FontSize', app.FontSize, ...
        'Text', 'Export to Script');
      app.ExportScriptButton.Layout.Row = 1;
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
      % The plot area is a tab group. Each tab owns its own axes so that no
      % single axis is ever repurposed between a map, an IPF map, a pole
      % figure and an image - which previously forced fragile cla/reset and
      % appdata juggling and broke the scale bar lifecycle.
      app.TabGroup = uitabgroup(app.RightLayout, ...
        'SelectionChangedFcn', createCallbackFcn(app, @TabSelectionChanged, true));
      app.TabGroup.Layout.Row = 2;

      % --- Maps tab: phase map + property maps via a dropdown -------------
      app.MapsTab = uitab(app.TabGroup, 'Title', 'Maps');
      gMaps = uigridlayout(app.MapsTab, ...
        'ColumnWidth', {'fit', '1x'}, 'RowHeight', {30, '1x'}, ...
        'Padding', [6 6 6 6], 'RowSpacing', 6, 'ColumnSpacing', 6);
      lblM = uilabel(gMaps, 'Text', 'Map:', 'HorizontalAlignment', 'right', ...
        'FontSize', app.FontSize);
      lblM.Layout.Row = 1; lblM.Layout.Column = 1;
      app.MapsDropDown = uidropdown(gMaps, 'Items', {'Phase Map'}, ...
        'FontSize', app.FontSize, ...
        'ValueChangedFcn', createCallbackFcn(app, @MapsViewChanged, true));
      app.MapsDropDown.Layout.Row = 1; app.MapsDropDown.Layout.Column = 2;
      app.MapsAxes = uiaxes(gMaps);
      app.MapsAxes.Layout.Row = 2; app.MapsAxes.Layout.Column = [1 2];

      % --- IPF tab: X/Y/Z direction via a dropdown ------------------------
      app.IPFTab = uitab(app.TabGroup, 'Title', 'IPF');
      gIPF = uigridlayout(app.IPFTab, ...
        'ColumnWidth', {'fit', '1x'}, 'RowHeight', {30, '1x'}, ...
        'Padding', [6 6 6 6], 'RowSpacing', 6, 'ColumnSpacing', 6);
      lblI = uilabel(gIPF, 'Text', 'Direction:', 'HorizontalAlignment', 'right', ...
        'FontSize', app.FontSize);
      lblI.Layout.Row = 1; lblI.Layout.Column = 1;
      app.IPFDirectionDropDown = uidropdown(gIPF, 'Items', {'X','Y','Z'}, ...
        'Value', 'Z', 'FontSize', app.FontSize, ...
        'ValueChangedFcn', createCallbackFcn(app, @IPFViewChanged, true));
      app.IPFDirectionDropDown.Layout.Row = 1; app.IPFDirectionDropDown.Layout.Column = 2;
      app.IPFAxes = uiaxes(gIPF);
      app.IPFAxes.Layout.Row = 2; app.IPFAxes.Layout.Column = [1 2];

      % --- Pole Figures tab: parallel axes, a Miller field above each -----
      app.PFTab = uitab(app.TabGroup, 'Title', 'Pole Figures');
      gPF = uigridlayout(app.PFTab, ...
        'ColumnWidth', {'1x','1x','1x'}, 'RowHeight', {30, '1x'}, ...
        'Padding', [6 6 6 6], 'RowSpacing', 6, 'ColumnSpacing', 6);
      defaults = {'(100)','(010)','(001)'};
      for i = 1:3
        app.PFMillerField(i) = uieditfield(gPF, 'text', ...
          'Value', defaults{i}, 'HorizontalAlignment', 'center', ...
          'FontSize', app.FontSize, ...
          'ValueChangedFcn', createCallbackFcn(app, @PFMillerChanged, true));
        app.PFMillerField(i).Layout.Row = 1; app.PFMillerField(i).Layout.Column = i;
        app.PFAxes(i) = uiaxes(gPF);
        app.PFAxes(i).Layout.Row = 2; app.PFAxes(i).Layout.Column = i;
      end

      % --- Images tab: opt-images via a dropdown --------------------------
      app.ImagesTab = uitab(app.TabGroup, 'Title', 'Images');
      gImg = uigridlayout(app.ImagesTab, ...
        'ColumnWidth', {'fit', '1x'}, 'RowHeight', {30, '1x'}, ...
        'Padding', [6 6 6 6], 'RowSpacing', 6, 'ColumnSpacing', 6);
      lblImg = uilabel(gImg, 'Text', 'Image:', 'HorizontalAlignment', 'right', ...
        'FontSize', app.FontSize);
      lblImg.Layout.Row = 1; lblImg.Layout.Column = 1;
      app.ImagesDropDown = uidropdown(gImg, 'Items', {'(none)'}, ...
        'FontSize', app.FontSize, ...
        'ValueChangedFcn', createCallbackFcn(app, @ImagesViewChanged, true));
      app.ImagesDropDown.Layout.Row = 1; app.ImagesDropDown.Layout.Column = 2;
      app.ImagesAxes = uiaxes(gImg);
      app.ImagesAxes.Layout.Row = 2; app.ImagesAxes.Layout.Column = [1 2];
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
      [~, order] = sort(lower(string({listing.name})));
      listing = listing(order);

      for k = 1:numel(listing)
        entry = listing(k);
        fullPath = fullfile(folderPath, entry.name);

        if entry.isdir
          folderNode = uitreenode(parentNode, ...
            'Text', entry.name, ...
            'NodeData', struct('Type', 'Folder', 'Path', fullPath));
          % Dummy child so the node is expandable; replaced on expand.
          uitreenode(folderNode, 'Text', 'Loading...');
        elseif isEBSDFile(app, entry.name)
          uitreenode(parentNode, ...
            'Text', entry.name, ...
            'NodeData', struct('Type', 'File', 'Path', fullPath));
        end
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
      updateCurrentDataInfo(app, fileName)
      app.ExportButton.Text = 'Import to workspace';
      invalidateAllSigs(app)
      app.PFODFKey = "";

      syncCoordinateControls(app)
      populateViewSelectors(app)
      fillPhaseTable(app)

      % default view: IPF Z of the (pre-selected) largest phase
      app.IPFDirectionDropDown.Value = 'Z';
      app.TabGroup.SelectedTab = app.IPFTab;

      updatePlot(app, true)
    end

    function populateViewSelectors(app)
      % Fill the Maps dropdown (phase map + property maps) and the Images
      % dropdown (matrices found anywhere in ebsd.opt).
      names = getPropertyNames(app);
      app.MapsDropDown.Items = [{'Phase Map'}; names(:)];
      app.MapsDropDown.Value = 'Phase Map';

      [imgNames, imgPaths] = collectImageFields(app, app.ebsd.opt, {});
      app.ImagePaths = imgPaths;
      if isempty(imgNames)
        app.ImagesDropDown.Items = {'(none)'};
        app.ImagesDropDown.ItemsData = {};
        app.ImagesTab.ForegroundColor = [0.6 0.6 0.6];
      else
        app.ImagesDropDown.Items = imgNames;
        app.ImagesDropDown.ItemsData = 1:numel(imgNames);
        app.ImagesDropDown.Value = 1;
        app.ImagesTab.ForegroundColor = [0 0 0];
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
      numPhases = accumarray(app.ebsd.phaseId,1);
            
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

      % colorize color column
      app.PhaseTable.Data = phaseTable;
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

      switch app.TabGroup.SelectedTab
        case app.MapsTab,   plotMaps(app, force)
        case app.IPFTab,    plotIPF(app, force)
        case app.PFTab,     plotPoleFigures(app, force)
        case app.ImagesTab, plotImages(app, force)
      end
    end

    function plotMaps(app, force)
      enabledPhaseIds = find(app.PhaseTable.Data.Plot);
      applyCurrentCoordinateState(app)
      ebsd = app.ebsd(ismember(app.ebsd.phaseId, enabledPhaseIds));

      sel = app.MapsDropDown.Value;
      sig = strjoin(["maps", string(sel), phaseSig(app,enabledPhaseIds), coordSig(app)], '|');
      if ~force && sig == app.LastSig.Maps, return; end
      app.LastSig.Maps = sig;

      ax = app.MapsAxes;
      resetAxes(app, ax)
      if isempty(ebsd)
        title(ax, 'No phase selected'); return
      end

      if strcmp(sel, 'Phase Map')
        plot(ebsd, 'parent', ax, 'wizard')
      else
        plot(ebsd, ebsd.(sel), 'parent', ax)
        mtexColorMap(ax, 'white2black');
        colorbar(ax)
      end
      setView(app.ebsd.how2plot, ax)
    end

    function plotIPF(app, force)
      enabledPhaseIds = find(app.PhaseTable.Data.Plot);
      applyCurrentCoordinateState(app)
      ebsd = app.ebsd(ismember(app.ebsd.phaseId, enabledPhaseIds));

      dir = app.IPFDirectionDropDown.Value;
      sig = strjoin(["ipf", string(dir), phaseSig(app,enabledPhaseIds), coordSig(app)], '|');
      if ~force && sig == app.LastSig.IPF, return; end
      app.LastSig.IPF = sig;

      ax = app.IPFAxes;
      resetAxes(app, ax)
      if isempty(ebsd)
        title(ax, 'No phase selected'); return
      end

      direction = directionVector(app, dir);
      hold(ax, 'on')
      for phaseId = enabledPhaseIds(:)'
        ebsdPhase = ebsd(ebsd.phaseId == phaseId);
        if isempty(ebsdPhase), continue; end
        ipfKey = ipfColorKey(ebsd.CSList(phaseId));
        ipfKey.inversePoleFigureDirection = direction;
        ipfKey.precompute;
        colors = ipfKey.orientation2color(ebsdPhase.orientations);
        plot(ebsdPhase, colors, 'parent', ax)
      end
      hold(ax, 'off')
      setView(app.ebsd.how2plot, ax)
    end

    function plotPoleFigures(app, force)
      enabledPhaseIds = find(app.PhaseTable.Data.Plot);
      applyCurrentCoordinateState(app)

      millers = string({app.PFMillerField.Value});
      sig = strjoin(["pf", strjoin(millers,';'), phaseSig(app,enabledPhaseIds), coordSig(app)], '|');
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

      % the ODF only depends on the phase and the coordinate state, not on
      % the Miller indices, so compute it once and cache it across the axes
      odfKey = strjoin(["odf", string(pid), coordSig(app)], '|');
      if odfKey ~= app.PFODFKey || isempty(app.PFODF)
        app.PFODF = calcDensity(ebsdPhase.orientations);
        app.PFODFKey = odfKey;
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
        plotPDF(odf, h, 'parent', ax, 'contourf','upper','noTitle',...
          'fontSize', 20,'TL','upper');

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

    function s = coordSig(app)
      s = string(app.MapCoordinatesDropDown.ValueIndex) + "_" + ...
          string(app.EulerCoordinatesDropDown.ValueIndex);
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
      app.LastSig = struct('Maps',"",'IPF',"",'PF',"",'Images',"");
    end

    function applyCurrentCoordinateState(app)
      idx = app.MapCoordinatesDropDown.ValueIndex;
      app.ebsd.how2plot = app.CoordinateSystems.how2plot(idx);

      rot = [app.CoordinateSystems.how2plot.rot];
      eulerRot = rot(app.EulerCoordinatesDropDown.ValueIndex);
      mapRot = rot(app.MapCoordinatesDropDown.ValueIndex);
      
      app.ebsd.EulerCorrection = mapRot * inv(eulerRot); %#ok<MINV>
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
      imageHandle.ImageSource = char(app.CoordinateSystems.Key(idx) + ".png");
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
      app.CurrentData.Value = { ...
        ['File: ' asChar(app, fileName)]; ...
        ['Step size: ' ebsdValueText(app, 'dxy')]; ...
        ['Grid: ' gridTypeLabel(app)]; ...
        ['Extent: ' ebsdValueText(app, 'extent')]};
    end

    function text = ebsdValueText(app, propertyName)
      try
        text = formatDisplayValue(app, app.ebsd.(propertyName));
      catch
        text = '<unavailable>';
      end
    end

    function text = gridTypeLabel(app)
      text = 'unknown';

      try
        n = size(app.ebsd.unitCell, 1);
        if n == 4
          text = 'square';
        elseif n == 6
          text = 'hex';
        end
        return
      catch
      end

      try
        if app.ebsd.isHex
          text = 'hex';
        end
      catch
      end
    end

    function text = formatDisplayValue(app, value)
      if isnumeric(value)
        text = mat2str(value, 5);
        return
      end

      if ischar(value) || isstring(value)
        text = app.asChar(value);
        return
      end

      try
        text = app.asChar(value);
      catch
        text = '<unavailable>';
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
    function FileTreeSelectionChanged(app, event)
      node = event.SelectedNodes;
      if isempty(node) || isempty(node.NodeData)
        return
      end

      data = node.NodeData;
      if strcmp(data.Type, 'Folder')
        navigateToFolder(app, data.Path)
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

    function MapsViewChanged(app, ~)
      updatePlot(app)
    end

    function IPFViewChanged(app, ~)
      updatePlot(app)
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
          invalidateAllSigs(app)
          updatePlot(app, true)

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

      invalidateAllSigs(app)
      app.PFODFKey = "";
      updatePlot(app, true)
    end

    function setEulerCoordinate(app, ~)
      if isempty(app.ebsd)
        return
      end

      setCoordinateImage(app, app.EulerImage, app.EulerCoordinatesDropDown.ValueIndex)
      invalidateAllSigs(app)
      app.PFODFKey = "";
      updatePlot(app, true)
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

    % Generates a clean MTEX script string and opens it directly inside the Editor
    function ExportScriptButtonPushed(app, ~)
      if isempty(app.ebsd) || app.LoadedFilePath == ""
        return
      end

      [~, baseName] = fileparts(app.LoadedFilePath);
      safeName = matlab.lang.makeValidName(string(baseName));
      scriptFileName = char(safeName + ".m");
      safePath = strrep(app.LoadedFilePath, "'", "''");
      
      mapIdx = app.MapCoordinatesDropDown.ValueIndex;
      mapObj = app.CoordinateSystems.how2plot(mapIdx);
      
      eulerIdx = app.EulerCoordinatesDropDown.ValueIndex;
      eulerObj = app.CoordinateSystems.how2plot(eulerIdx);

      scriptLines = { ...
        '%% MTEX Script generated by import_wizard2'; ...
        ''; ...
        '%% Specify Crystal Symmetries'; ...
        'CS = { ...'; ...
      };

      for k = 1:numel(app.ebsd.CSList)
        cs = app.ebsd.CSList(k);
        if ischar(cs) && strcmpi(cs, 'notIndexed')
          scriptLines{end+1} = '  ''notIndexed'', ...'; %#ok<AGROW>
        else
          pg = char(cs.pointGroup);
          abc = [norm(cs.aAxis), norm(cs.bAxis), norm(cs.cAxis)];
          ang = [cs.alpha, cs.beta, cs.gamma] / degree;
          minName = char(cs.mineral);
          
          csStr = sprintf('  crystalSymmetry(''%s'', [%.4f, %.4f, %.4f], [%.1f, %.1f, %.1f], ''mineral'', ''%s''), ...', ...
            pg, abc(1), abc(2), abc(3), ang(1), ang(2), ang(3), minName);
          scriptLines{end+1} = csStr; %#ok<AGROW>
        end
      end
      
      scriptLines{end+1} = '};';
      scriptLines{end+1} = '';
      scriptLines{end+1} = '%% Load EBSD Data';
      scriptLines{end+1} = sprintf('fname = ''%s'';', safePath);
      scriptLines{end+1} = 'ebsd = EBSD.load(fname, CS, ''interface'', ''wizard'');';
      scriptLines{end+1} = '';
      scriptLines{end+1} = '%% Apply Coordinate Conversions';
      scriptLines{end+1} = sprintf('ebsd.how2plot = plottingConvention(vector3d(%s), vector3d(%s));', ...
        mat2str(double(mapObj.outOfScreen)), mat2str(double(mapObj.east)));
      scriptLines{end+1} = sprintf('eulerRot = rotation.byMatrix(%s);', mat2str(eulerObj.rot.matrix));
      scriptLines{end+1} = sprintf('mapRot = rotation.byMatrix(%s);', mat2str(mapObj.rot.matrix));
      scriptLines{end+1} = 'ebsd.EulerCorrection = inv(eulerRot) * mapRot;';
      scriptLines{end+1} = '';
      scriptLines{end+1} = '%% Plot Data';
      scriptLines{end+1} = 'plot(ebsd);';

      textString = strjoin(scriptLines, newline);
      
      fid = fopen(scriptFileName, 'wt');
      if fid ~= -1
        fprintf(fid, '%s', textString);
        fclose(fid);
        matlab.desktop.editor.openDocument(fullfile(pwd, scriptFileName));
      else
        matlab.desktop.editor.newDocument(textString);
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