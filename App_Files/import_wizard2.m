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

    ImportEBSDDataButton           matlab.ui.control.Button
    CurrentData                    matlab.ui.control.TextArea
    DataTable                      matlab.ui.control.Table
    UIAxes                         matlab.ui.control.UIAxes
    ExportButton                   matlab.ui.control.Button

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
    PhaseIds double = []
    CSIndexByRow double = []
    Color cell = {}
    AnalysisUICreated logical = false
    LastPlotSignature string = ""
    FontSize double = 14
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
      app.UIFigure.Name = 'EBSD Data Analysis';
      try
        app.UIFigure.Theme = 'light';
      catch
      end

      app.EBSDDataAnalysisPanel = uipanel(app.UIFigure, ...
        'Title', 'EBSD Data Analysis', ...
        'FontWeight', 'bold', ...
        'FontSize', 18, ...
        'Position', [1 1 1300 700]);

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
        'RowHeight', {40, 95, '1x', 250, 40}, ...
        'RowSpacing', 10, ...
        'Padding', [0 0 0 0]);

      app.ImportEBSDDataButton = uibutton(app.LeftLayout, 'push', ...
        'ButtonPushedFcn', createCallbackFcn(app, @ImportEBSDDataButtonPushed, true), ...
        'FontWeight', 'bold', ...
        'FontSize', app.FontSize, ...
        'Text', 'Import EBSD-Data');
      app.ImportEBSDDataButton.Layout.Row = 1;

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

    function ensureAnalysisUI(app)
      if app.AnalysisUICreated
        return
      end

      createPlotTree(app)
      createCoordinateControls(app)
      createExportButton(app)
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

    function createExportButton(app)
      app.ExportButton = uibutton(app.LeftLayout, 'push', ...
        'ButtonPushedFcn', createCallbackFcn(app, @ExportButtonPushed, true), ...
        'FontWeight', 'bold', ...
        'FontSize', app.FontSize, ...
        'Text', 'Export');
      app.ExportButton.Layout.Row = 5;
    end

    function createRightPanel(app)
      app.RightLayout = uigridlayout(app.RightPanel, ...
        'ColumnWidth', {'1x'}, ...
        'RowHeight', {230, '1x'}, ...
        'RowSpacing', 8, ...
        'Padding', [0 0 0 0]);

      app.DataTable = uitable(app.RightLayout, ...
        'ColumnName', {'Plot'; 'Phase'; 'Mineral'; 'Pixel'; 'Symmetry'; 'a'; 'b'; 'c'; 'Color'}, ...
        'ColumnEditable', [true false true false false false false false false], ...
        'ColumnFormat', {'logical', [], [], [], [], [], [], [], []}, ...
        'RowName', {}, ...
        'CellEditCallback', createCallbackFcn(app, @DataTableCellEdit, true), ...
        'CellSelectionCallback', createCallbackFcn(app, @DataTableCellSelection, true), ...
        'FontSize', app.FontSize - 1);
      app.DataTable.Layout.Row = 1;

      app.UIAxes = uiaxes(app.RightLayout);
      title(app.UIAxes, '')
      xlabel(app.UIAxes, '')
      ylabel(app.UIAxes, '')
      zlabel(app.UIAxes, '')
      app.UIAxes.Layout.Row = 2;
    end

    function importEBSDData(app)
      [ebsdData, fileName] = import_data();
      if isempty(ebsdData)
        return
      end

      ensureAnalysisUI(app)

      app.ebsd = ebsdData;
      updateCurrentDataInfo(app, fileName)
      app.ExportButton.Text = 'Export';
      app.LastPlotSignature = "";

      syncCoordinateControls(app)
      populatePropertyNodes(app)
      fillPhaseTable(app)
      updatePlot(app, true)
    end

    function populatePropertyNodes(app)
      delete(app.PropertyMapNode.Children)

      names = getPropertyNames(app);
      for k = 1:numel(names)
        name = names{k};
        uitreenode(app.PropertyMapNode, ...
          'Text', name, ...
          'NodeData', struct('Type', 'Property', 'PropertyName', name));
      end

      if ~isempty(names)
        expand(app.Tree)
      end
    end

    function fillPhaseTable(app)
      removeStyle(app.DataTable)
      addStyle(app.DataTable, uistyle('HorizontalAlignment', 'left'))

      app.PhaseIds = sort(unique(app.ebsd.phaseId(:)));
      n = numel(app.PhaseIds);
      tableData = cell(n, 9);
      app.Color = cell(n, 1);
      app.CSIndexByRow = zeros(n, 1);
      colorable = false(n, 1);

      for row = 1:n
        phaseId = app.PhaseIds(row);
        phaseMask = app.ebsd.phaseId == phaseId;
        phaseData = app.ebsd(phaseMask);
        csIndex = csIndexForPhase(app, phaseId, row);
        cs = app.ebsd.CSList{csIndex};

        app.CSIndexByRow(row) = csIndex;
        pixels = nnz(phaseMask);

        if isNotIndexed(app, cs)
          mineral = 'NotIndexed';
          symmetry = 'None';
          a = 0; b = 0; c = 0;
          app.Color{row} = [0.8 0.8 0.8];
        else
          cs = phaseData.CS;
          mineral = asChar(app, cs.mineral);
          symmetry = asChar(app, cs.pointGroup);
          a = norm(cs.aAxis);
          b = norm(cs.bAxis);
          c = norm(cs.cAxis);
          app.Color{row} = cs.color;
          colorable(row) = true;
        end

        tableData(row, :) = {true, phaseId, mineral, pixels, symmetry, a, b, c, ''};
      end

      app.DataTable.Data = tableData;
      for row = find(colorable)'
        addStyle(app.DataTable, ...
          uistyle('BackgroundColor', app.Color{row}), ...
          'cell', [row 9])
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

      enabledPhaseIds = currentEnabledPhaseIds(app);
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
          ipfKey = ipfColorKey(ebsd);
          ipfKey.inversePoleFigureDirection = directionVector(app, plotSpec.Direction);
          colors = ipfKey.orientation2color(ebsd.orientations);
          plot(ebsd, colors, 'parent', app.UIAxes)

        case 'Property'
          plot(ebsd, ebsd.(plotSpec.PropertyName), 'parent', app.UIAxes)
          mtexColorMap(app.UIAxes,'white2black');
          colorbar(app.UIAxes)
        case 'PoleFigure'

          cla(app.UIAxes,'reset');
          rmallappdata(app.UIAxes)
          h = string2Miller(plotSpec.Miller,ebsd.CS);
          plotPDF(ebsd.orientations,h, 'parent', app.UIAxes,'contourf')
          pfAnnotations = getMTEXpref('pfAnnotations');
          pfAnnotations('parent', app.UIAxes,'fontSize',20)
          mtexColorbar(app.UIAxes,'white2black')
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

    function phaseIds = currentEnabledPhaseIds(app)
      if isempty(app.DataTable.Data)
        phaseIds = app.PhaseIds;
        return
      end

      enabled = logical(cell2mat(app.DataTable.Data(:, 1)));
      phaseIds = app.PhaseIds(enabled);
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
      if row < 1 || row > numel(app.CSIndexByRow)
        return
      end

      csIndex = app.CSIndexByRow(row);
      cs = app.ebsd.CSList{csIndex};
      if isNotIndexed(app, cs)
        app.DataTable.Data{row, 3} = 'NotIndexed';
        return
      end

      mineral = strtrim(app.asChar(value));
      if isempty(mineral)
        mineral = mineralNameForCS(app, cs);
        app.DataTable.Data{row, 3} = mineral;
        return
      end

      try
        app.ebsd.CSList{csIndex}.mineral = mineral;
        app.DataTable.Data{row, 3} = mineral;
      catch ME
        app.DataTable.Data{row, 3} = mineralNameForCS(app, cs);
        uialert(app.UIFigure, ME.message, 'Could not update mineral name')
      end
    end

    function mineral = mineralNameForCS(app, cs)
      if isNotIndexed(app, cs)
        mineral = 'NotIndexed';
        return
      end

      try
        mineral = app.asChar(cs.mineral);
      catch
        mineral = '';
      end
    end

    function width = leftPanelWidth(app)
      % Enough room for two coordinate columns plus padding. The labels
      % are the limiting elements, so scale the width with font size.
      width = max(300, ceil(22 * app.FontSize));
    end
  end

  methods (Access = private)
    function ImportEBSDDataButtonPushed(app, ~)
      importEBSDData(app)
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
      if strcmp(app.DataTable.Data{row, 3}, 'NotIndexed')
        return
      end

      newColor = uisetcolor(app.Color{row}, 'Select phase color');
      if isequal(newColor, 0)
        return
      end

      csIndex = app.CSIndexByRow(row);
      app.ebsd.CSList{csIndex}.color = newColor;
      app.Color{row} = newColor;

      addStyle(app.DataTable, uistyle('BackgroundColor', newColor), 'cell', [row 9])
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
      app.ExportButton.Text = 'Exported!';
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
