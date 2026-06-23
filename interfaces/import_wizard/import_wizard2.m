classdef import_wizard2 < matlab.apps.AppBase
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
    CurrentPathLabel                matlab.ui.control.Label
    FileTree                       matlab.ui.container.Tree
    CurrentData                    matlab.ui.control.TextArea
    PhaseTable                      matlab.ui.control.Table
    UIAxes                         matlab.ui.control.UIAxes
    ExportButton                   matlab.ui.control.Button
    ExportScriptButton             matlab.ui.control.Button % Button for generating an MTEX script

    Tree                           matlab.ui.container.CheckBoxTree
    PhaseMapNode                   matlab.ui.container.TreeNode
    PropertyMapNode                matlab.ui.container.TreeNode
    OrientationMapNode             matlab.ui.container.TreeNode
    IPFXNode                       matlab.ui.container.TreeNode
    IPFYNode                       matlab.ui.container.TreeNode
    IPFZNode                       matlab.ui.container.TreeNode
    PoleFiguresNode                matlab.ui.container.TreeNode
    PF100Node                      matlab.ui.container.TreeNode
    PF010Node                      matlab.ui.container.TreeNode
    PF001Node                      matlab.ui.container.TreeNode
    ImagesNode                     matlab.ui.container.TreeNode

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
    LastPlotSignature string = ""
    FontSize double = 14
    CurrentFolder string = ""
    LoadedFilePath string = "" % Keeps track of the path of the imported EBSD file
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
      app.UIFigure.Name = 'EBSD Data Analysis';
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

      createPlotTree(app)
      createCoordinateControls(app)
      createExportButtonsPanel(app) % Combined layout setup for both buttons
      createRightPanel(app)

      app.AnalysisUICreated = true;
    end

    function createPlotTree(app)
      app.Tree = uitree(app.LeftLayout, 'checkbox', ...
        'CheckedNodesChangedFcn', createCallbackFcn(app, @TreeCheckedNodesChanged, true), ...
        'FontSize', app.FontSize);
      app.Tree.Layout.Row = 3;

      app.PhaseMapNode = uitreenode(app.Tree, ...
        'Text', 'Phase Map', ...
        'NodeData', struct('Type', 'PhaseMap'));

      app.PropertyMapNode = uitreenode(app.Tree, ...
        'Text', 'Property Map', ...
        'NodeData', struct('Type', 'Group'));

      app.OrientationMapNode = uitreenode(app.Tree, ...
        'Text', 'Orientation Map', ...
        'NodeData', struct('Type', 'Group'));
      app.IPFXNode = uitreenode(app.OrientationMapNode, ...
        'Text', 'IPF X', ...
        'NodeData', struct('Type', 'IPF', 'Direction', 'X'));
      app.IPFYNode = uitreenode(app.OrientationMapNode, ...
        'Text', 'IPF Y', ...
        'NodeData', struct('Type', 'IPF', 'Direction', 'Y'));
      app.IPFZNode = uitreenode(app.OrientationMapNode, ...
        'Text', 'IPF Z', ...
        'NodeData', struct('Type', 'IPF', 'Direction', 'Z'));

      app.PoleFiguresNode = uitreenode(app.Tree, ...
        'Text', 'Pole Figures', ...
        'NodeData', struct('Type', 'Group'));
      app.PF100Node = uitreenode(app.PoleFiguresNode, ...
        'Text', '(100)', ...
        'NodeData', struct('Type', 'PoleFigure', 'Miller', '(100)'));
      app.PF010Node = uitreenode(app.PoleFiguresNode, ...
        'Text', '(010)', ...
        'NodeData', struct('Type', 'PoleFigure', 'Miller', '(010)'));
      app.PF001Node = uitreenode(app.PoleFiguresNode, ...
        'Text', '(001)', ...
        'NodeData', struct('Type', 'PoleFigure', 'Miller', '(001)'));

      app.ImagesNode = uitreenode(app.Tree, ...
        'Text', 'Images', ...
        'NodeData', struct('Type', 'Group'));

      app.Tree.CheckedNodes = app.PhaseMapNode;
      expand(app.Tree)
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
        'CellEditCallback', createCallbackFcn(app, @DataTableCellEdit, true), ...
        'CellSelectionCallback', createCallbackFcn(app, @DataTableCellSelection, true), ...
        'FontSize', app.FontSize - 1);
      app.PhaseTable.Layout.Row = 1;

      app.UIAxes = uiaxes(app.RightLayout);
      title(app.UIAxes, '')
      xlabel(app.UIAxes, '')
      ylabel(app.UIAxes, '')
      zlabel(app.UIAxes, '')
      app.UIAxes.Layout.Row = 2;
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
      app.LastPlotSignature = "";

      syncCoordinateControls(app)
      populatePropertyNodes(app)
      fillPhaseTable(app)

      app.Tree.CheckedNodes = app.IPFZNode;
      app.Tree.SelectedNodes = app.IPFZNode;

      updatePlot(app, true)
    end

    function populatePropertyNodes(app)
      delete(app.PropertyMapNode.Children)
      delete(app.ImagesNode.Children)

      names = getPropertyNames(app);
      for k = 1:numel(names)
        name = names{k};
        uitreenode(app.PropertyMapNode, ...
          'Text', name, ...
          'NodeData', struct('Type', 'Property', 'PropertyName', name));
      end

      hasImages = false;
      try
        hasImages = addImageNodes(app, app.ImagesNode, app.ebsd.opt, {});
      catch
      end

      if ~isempty(names) || hasImages
        expand(app.Tree)
      end
    end

    function found = addImageNodes(app, parentNode, s, pathSoFar)
      % Recursively walk struct s (e.g. ebsd.opt), adding one tree node
      % per numeric matrix of at least 100x100 ("image"), and one group
      % node per nested struct that contains such matrices (directly or
      % in deeper nesting). pathSoFar accumulates the field-name chain
      % needed to re-access the matrix later (NodeData.Path).
      found = false;

      if ~isstruct(s) || ~isscalar(s)
        return
      end

      fields = fieldnames(s);
      for k = 1:numel(fields)
        field = fields{k};
        value = s.(field);
        fieldPath = [pathSoFar, {field}];

        if isnumeric(value) && ismatrix(value) && ...
            size(value, 1) >= 100 && size(value, 2) >= 100
          uitreenode(parentNode, ...
            'Text', field, ...
            'NodeData', struct('Type', 'OptImage', 'Path', {fieldPath}));
          found = true;

        elseif isstruct(value) && isscalar(value)
          childGroupNode = uitreenode(parentNode, ...
            'Text', field, ...
            'NodeData', struct('Type', 'Group'));
          childFound = addImageNodes(app, childGroupNode, value, fieldPath);
          if childFound
            found = true;
          else
            delete(childGroupNode)
          end
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
        
        cs = csList{pId};
        if isa(cs,'symmetry')          
          mineral = asChar(app, cs.mineral);
          symmetry = asChar(app, cs.pointGroup);
          a = norm(cs.aAxis);
          b = norm(cs.bAxis);
          c = norm(cs.cAxis);
          app.Color{pId} = cs.color;
        else
          mineral = 'NotIndexed';
          symmetry = 'None';
          a = 0; b = 0; c = 0;
          app.Color{pId} = [0.8 0.8 0.8];
        end
                
        phaseTable(pId, :) = {false, app.ebsd.phaseMap(pId), mineral, ...
           [int2str(numPhases(pId)),' (' num2str(100*numPhases(pId)/sum(numPhases)) '%)'], ...
           symmetry, a, b, c, ''};     
      end

      % pre select indexed phase with the most pixels
      numPhases(cellfun('isclass',csList,'char')) = 0;
      [~,maxPhase] = max(numPhases);
      phaseTable.Plot(maxPhase) = true;

      % colorize color column
      app.PhaseTable.Data = phaseTable;
      
      for row = 1:length(numPhases)
        addStyle(app.PhaseTable, ...
          uistyle('BackgroundColor', app.Color{row}), 'cell', [row 9])
      end
      
    end

    function updatePlot(app, force)
      % Read the current UI state, derive the data to plot, and redraw
      % only if the relevant plot state changed or force is true.
      arguments
        app
        force logical = false
      end

      if isempty(app.ebsd) || ~app.AnalysisUICreated
        return
      end

      [plotSpec, selectedNode] = currentPlotSpec(app);
      if isempty(selectedNode) || strcmp(plotSpec.Type, 'Group')
        return
      end

      enabledPhaseIds = find(app.PhaseTable.Data.Plot);
      ebsd = app.ebsd(ismember(app.ebsd.phaseId, enabledPhaseIds));
      applyCurrentCoordinateState(app)

      signature = plotSignature(app, plotSpec, enabledPhaseIds);
      if ~force && signature == app.LastPlotSignature
        return
      end
      app.LastPlotSignature = signature;

      cla(app.UIAxes)
      if isempty(ebsd)
       title(app.UIAxes, 'No phase selected')
       return
      end

      switch plotSpec.Type
        case 'PhaseMap'
          plot(ebsd, 'parent', app.UIAxes)

        case 'IPF'
          direction = directionVector(app, plotSpec.Direction);
          hold(app.UIAxes, 'on')
          for phaseId = enabledPhaseIds(:)'
            ebsdPhase = ebsd(ebsd.phaseId == phaseId);
            if isempty(ebsdPhase)
              continue
            end
            ipfKey = ipfColorKey(ebsdPhase);
            ipfKey.inversePoleFigureDirection = direction;
            colors = ipfKey.orientation2color(ebsdPhase.orientations);
            plot(ebsdPhase, colors, 'parent', app.UIAxes)
          end
          hold(app.UIAxes, 'off')

        case 'Property'
          plot(ebsd, ebsd.(plotSpec.PropertyName), 'parent', app.UIAxes)
          mtexColorMap(app.UIAxes,'white2black');
          colorbar(app.UIAxes)

        case 'OptImage'
          image = resolveOptImage(app, plotSpec.Path);
          if isempty(image)
            title(app.UIAxes, 'Image not found')
            return
          end
          imagesc(image, 'parent', app.UIAxes)
          colormap(app.UIAxes, 'gray')
          axis(app.UIAxes, 'image')
          colorbar(app.UIAxes)

        case 'PoleFigure'

          cla(app.UIAxes,'reset');
          rmallappdata(app.UIAxes)
          h = string2Miller(plotSpec.Miller,ebsd.CS);
          odf = calcDensity(ebsd.orientations);
          plotPDF(odf,h, 'parent', app.UIAxes,'contourf')
          pfAnnotations = getMTEXpref('pfAnnotations');
          pfAnnotations('parent', app.UIAxes,'fontSize',20)
          colorbar(app.UIAxes)
      end
    end

    function [spec, node] = currentPlotSpec(app)
      node = [];
      spec = struct('Type', 'Group');

      checked = app.Tree.CheckedNodes;
      if isempty(checked)
        app.Tree.CheckedNodes = app.PhaseMapNode;
        checked = app.PhaseMapNode;
      end

      node = checked(1);
      if isempty(node.NodeData)
        return
      end
      spec = node.NodeData;
    end


    function applyCurrentCoordinateState(app)
      idx = app.MapCoordinatesDropDown.ValueIndex;
      app.ebsd.how2plot = app.CoordinateSystems.how2plot(idx);

      rot = [app.CoordinateSystems.how2plot.rot];
      eulerRot = rot(app.EulerCoordinatesDropDown.ValueIndex);
      mapRot = rot(app.MapCoordinatesDropDown.ValueIndex);
      app.ebsd.EulerCorrection = inv(eulerRot) * mapRot; %#ok<MINV>
    end

    function signature = plotSignature(app, spec, phaseIds)
      parts = ["type=" + string(spec.Type), ...
          "phases=" + strjoin(string(phaseIds(:).'), ','), ...
          "map=" + string(app.MapCoordinatesDropDown.ValueIndex), ...
          "euler=" + string(app.EulerCoordinatesDropDown.ValueIndex)];

      if isfield(spec, 'Direction')
        parts(end + 1) = "dir=" + string(spec.Direction);
      end
      if isfield(spec, 'PropertyName')
        parts(end + 1) = "prop=" + string(spec.PropertyName);
      end
      if isfield(spec, 'Miller')
        parts(end + 1) = "miller=" + string(spec.Miller);
      end
      if isfield(spec, 'Path')
        parts(end + 1) = "path=" + strjoin(string(spec.Path), '.');
      end

      signature = strjoin(parts, '|');
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
      cs = app.ebsd.CSList{row};
      if ~isa(cs,'symmetry')
        app.ebsd.CSList{row} = value;
      else
        app.ebsd.CSList{row}.mineral = value;
      end

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

    function TreeCheckedNodesChanged(app, ~)
      checked = app.Tree.CheckedNodes;
      if numel(checked) > 1
        selected = app.Tree.SelectedNodes;
        if isempty(selected)
          selected = checked(end);
        end
        app.Tree.CheckedNodes = selected(1);
      end

      [spec, node] = currentPlotSpec(app);
      if strcmp(spec.Type, 'Group')
        app.Tree.CheckedNodes = app.PhaseMapNode;
        app.Tree.SelectedNodes = app.PhaseMapNode;
      end

      updatePlot(app)
    end

    function DataTableCellEdit(app, event)
      if isempty(event.Indices)
        return
      end

      row = event.Indices(1);
      col = event.Indices(2);

      switch col
        case 1
          updatePlot(app, true)

        case 3
          updateMineralName(app, row, event.NewData)
          updatePlot(app, true)
      end
    end

    function DataTableCellSelection(app, event)
      if isempty(event.Indices) || event.Indices(2) ~= 9
        return
      end

      row = event.Indices(1);

      newColor = uisetcolor(app.Color{row}, 'Select phase color');
      if isequal(newColor, 0)
        return
      end

      app.Color{row} = newColor;
      if isa(app.ebsd.CSList{row}, 'symmetry')
          app.ebsd.CSList{row}.color = newColor;
      end

      addStyle(app.PhaseTable, uistyle('BackgroundColor', newColor), 'cell', [row 9])
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
        setView(app.ebsd.how2plot, app.UIAxes)
      catch
      end

      updatePlot(app, true)
    end

    function setEulerCoordinate(app, ~)
      if isempty(app.ebsd)
        return
      end

      setCoordinateImage(app, app.EulerImage, app.EulerCoordinatesDropDown.ValueIndex)
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
      app.ExportButton.Text = ['Imported as ' varName '!'];
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
        cs = app.ebsd.CSList{k};
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
    function app = import_wizard2
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