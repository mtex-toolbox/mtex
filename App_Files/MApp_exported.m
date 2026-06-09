classdef MApp_exported < matlab.apps.AppBase

  % Properties that correspond to app components
  properties (Access = public)
    UIFigure                       matlab.ui.Figure
    EBSDDataAnalysisPanel          matlab.ui.container.Panel
    Tree                           matlab.ui.container.CheckBoxTree
    OrientationMapNode             matlab.ui.container.TreeNode
    IPFZNode                       matlab.ui.container.TreeNode
    IPFYNode                       matlab.ui.container.TreeNode
    IPFXNode                       matlab.ui.container.TreeNode
    PhaseMaptNode                  matlab.ui.container.TreeNode
    PropertyMapNode                matlab.ui.container.TreeNode
    MADNode                        matlab.ui.container.TreeNode
    BCNode                         matlab.ui.container.TreeNode
    PoleFiguresNode                matlab.ui.container.TreeNode
    Node_2                         matlab.ui.container.TreeNode
    Node                           matlab.ui.container.TreeNode
    Node_3                         matlab.ui.container.TreeNode
    EulerImage                     matlab.ui.control.Image
    MapImage                       matlab.ui.control.Image
    EulerCoordinatesDropDown       matlab.ui.control.DropDown
    EulerCoordinatesDropDownLabel  matlab.ui.control.Label
    MapCoordinatesDropDown         matlab.ui.control.DropDown
    MapCoordinatesDropDownLabel    matlab.ui.control.Label
    TypeofPlotDropDown             matlab.ui.control.DropDown
    TypeofPlotDropDownLabel        matlab.ui.control.Label
    ExportButton                   matlab.ui.control.Button
    Label                          matlab.ui.control.Label
    CurrentData                    matlab.ui.control.EditField
    Panel                          matlab.ui.container.Panel
    DataTable                      matlab.ui.control.Table
    UIAxes                         matlab.ui.control.UIAxes
    ImportEBSDDataButton           matlab.ui.control.Button
  end

    
  properties (Access = public)
    ebsd % EBSD Data imported by import_data
    Color
    DataToPlot
    OrientationPanel
  end

  properties (Constant, Access = private)
    CoordinateSystems = table( ...
      ["yUxR" "yDxR" "xUyR" "xDyR" "yUxL" "yDxL" "xUyL" "xDyL" ]', ...
      ["y↑→x" "y↓→x" "x↑→y" "x↓→y" "x←↑y" "x←↓y" "y←↑x" "y←↓x" ]', ...            
      [plottingConvention(zvector,xvector)
      plottingConvention(-zvector,xvector)
      plottingConvention(-zvector,yvector)
      plottingConvention(zvector,yvector)
      plottingConvention(-zvector,-xvector)
      plottingConvention(zvector,-xvector)
      plottingConvention(zvector,-yvector)
      plottingConvention(-zvector,-yvector)], ...
      'VariableNames', {'Key', 'Label', 'how2plot'})
  end



    

  % Callbacks that handle component events
  methods (Access = private)

    % Code that executes after component creation
    function startupFcn(app)

    end

    % Button pushed function: ImportEBSDDataButton
    function ImportEBSDDataButtonPushed(app, event)
      app.DataTable.Data = [];
      removeStyle(app.DataTable);
      app.TypeofPlotDropDown.Items = {};
      
      % create the check-boxes of column 'Enabled'
      app.DataTable.ColumnEditable = [true false false false false false false false false];
      app.DataTable.ColumnFormat = {'logical',[],[],[],[],[],[],[],[]};
      
      % create a style
      s = uistyle('HorizontalAlignment','left');
      addStyle(app.DataTable,s)
      
      % Import EBSD Data using the import_data function
      [ebsd, fileName] = import_data();
      
      % case for termination of import window
      if isempty(ebsd), return, end
      
      app.ebsd = ebsd;
      app.DataToPlot = app.ebsd;
      % Displaying the Name of the imported File
      app.CurrentData.Value = fileName;
      
      % set map coordinate system
      pC = app.CoordinateSystems.how2plot;
      id = find(ebsd.how2plot.rot == [pC.rot]);
      app.MapCoordinatesDropDown.Items = cellstr(app.CoordinateSystems.Label);
      app.MapCoordinatesDropDown.ValueIndex = id;

      % set Euler coordinate system
      % mapRot = screen -> mapXYZ
      % EulerRot = screen -> EulerXYZ
      % ebsd.rotations = Euler2MapCorrection .* ebsd.rotations;
      % Euler2MapCorrection = EulerXYZ -> mapXYZ
      EulerRot = inv(ebsd.EulerCorrection) * ebsd.how2plot.rot; %#ok<MINV>
      [~,id] = min(angle(EulerRot,[pC.rot]));
      app.EulerCoordinatesDropDown.Items = cellstr(app.CoordinateSystems.Label);
      app.EulerCoordinatesDropDown.ValueIndex = id;

      % fill UIAxes with the plotted data, only gets update once here
      % after pressing the 'Import EBSD' button
      % !!! Figure created by plot() cannot be closed
      cla(app.UIAxes);
      axes(app.UIAxes);
      plot(app.DataToPlot,'parent',app.UIAxes);
      
      
      
      PhaseId_array = unique(app.ebsd.phaseId);
      % new way of filling out DataTable
      for i = 1:1:length(unique(app.ebsd.phaseId))
                
        PhaseId = PhaseId_array(i);
        cs = app.ebsd.CSList{i};
        
        if strcmp(cs,'notIndexed')
          Mineral = 'NotIndexed';
          Pixels = nnz(app.ebsd.phaseId == PhaseId);
          Symmetry = 'None';
          a = 0;
          b = 0;
          c = 0;
        else
          Mineral= app.ebsd(app.ebsd.phaseId == PhaseId).CS.mineral;
          Pixels = nnz(app.ebsd.phaseId == PhaseId);
          Symmetry = app.ebsd(app.ebsd.phaseId == PhaseId).CS.pointGroup;
          a = norm(app.ebsd(app.ebsd.phaseId == PhaseId).CS.aAxis);
          b = norm(app.ebsd(app.ebsd.phaseId == PhaseId).CS.bAxis);
          c = norm(app.ebsd(app.ebsd.phaseId == PhaseId).CS.cAxis);
          
          app.Color{i} = app.ebsd(app.ebsd.phaseId == PhaseId).CS.color;
          
          s.BackgroundColor = [app.Color{i}];
          addStyle(app.DataTable,s,"cell",[i,9]);
        end
        
        % create new entry for
        newEntry = {true, PhaseId, Mineral, Pixels, Symmetry, a, b, c,''};
        app.DataTable.Data = [app.DataTable.Data;newEntry];
        
      end
      
      % get the properties of the file and put them into the "Type of
      % Plot" DropDown
      % create a Cell Array OtherTypes for more types of plots
      OtherTypes = {'EBSD';
        'IPF' };
      app.TypeofPlotDropDown.Items = [OtherTypes;fieldnames(app.ebsd.prop)];
    end

    % Cell edit callback: DataTable
    function DataTableCellEdit(app, event)
      indices = event.Indices;
      newData = event.NewData;
            
      % check for invalid selection or selection of phase
      % 'NotIndexed'
      if isempty(indices)
        return
      elseif strcmp(app.DataTable.Data(indices(1),3),'NotIndexed')
        return
      end
      
      hrows = indices(1);
      cols = indices(2);
      
      % create a mask to disable/enable corresponding phases of
      % logical values in DataTable (checkboxes)
      mask = logical(cell2mat(app.DataTable.Data(:,1)));
      
      % filter for enabled phases
      app.DataToPlot = app.ebsd(ismember(app.ebsd.phaseId, find(mask)));
      
      % update plot in UIAxes
      cla(app.UIAxes);
      axes(app.UIAxes);
      plot(app.DataToPlot,'parent',app.UIAxes);
      
      
    end

    % Callback function
    function DataTableSelectionChanged(app, event)

    end

    % Cell selection callback: DataTable
    function DataTableCellSelection(app, event)
            indices = event.Indices;
            
            % check if indices has a invalid value or if 'NotIndexed' color
            % cell has been selected, if so, return to prohibit change 
            if isempty(indices)
                return
            elseif strcmp(app.DataTable.Data(indices(1),3),'NotIndexed')
                return
            end

            rows = indices(1);
            cols = indices(2);

            % check for selection of cells in column 9 (Color cells)
            if cols == 9

                NewColor = uisetcolor(app.Color{rows});

                % case for termination of uisetcolor window
                if NewColor == 0 
                    return
                end

                app.ebsd.CSList{rows}.color = NewColor;
                app.Color{rows} = NewColor;
                % change color of selected cell
                s = uistyle;
                s.BackgroundColor = [app.ebsd.CSList{rows}.color];
                addStyle(app.DataTable,s,"cell",[rows,cols]);
            end

            % update plot in UIAxes (still opens plot windows of plot()
            % function) 
            
            cla(app.UIAxes);
            axes(app.UIAxes);
            plot(app.DataToPlot,'parent',app.UIAxes);
    end

    % Button pushed function: ExportButton
    function ExportButtonPushed(app, event)
            % has no function yet
            if isempty(app.ebsd)
                return
            end

            app.ExportButton.Text = 'Exported !';
    end

    % Value changed function: TypeofPlotDropDown
    function TypeofPlotDropDownValueChanged(app, event)
      value = app.TypeofPlotDropDown.Value;
      if strcmp(value,'EBSD')
        cla(app.UIAxes);
        axes(app.UIAxes);
        plot(app.DataToPlot,'parent',app.UIAxes);
      elseif strcmp(value,'IPF')
        % DataToPlot has to contain only a one phase (one phase is
        % enabled) or the regular plot(ebsd) will be displayed
        colors = ipfColorKey(app.DataToPlot).orientation2color(app.DataToPlot.orientations);
        cla(app.UIAxes);
        axes(app.UIAxes);
        plot(app.DataToPlot,colors,'parent',app.UIAxes);
      else
        cla(app.UIAxes);
        axes(app.UIAxes);
        plot(app.ebsd,app.ebsd.(value),'parent',app.UIAxes);
      end
      
    end

    % Value changed function: MapCoordinatesDropDown
    function setMapCoordinates(app, event)
      value = app.MapCoordinatesDropDown.ValueIndex;
      app.ebsd.how2plot = app.CoordinateSystems.how2plot(value);
      setView(app.ebsd.how2plot,app.UIAxes);

      % change also EulerCoordinateDropDown      
      EulerRot = inv(app.ebsd.EulerCorrection) * app.ebsd.how2plot.rot; %#ok<MINV>
      pC = app.CoordinateSystems.how2plot;
      [~,id] = min(angle(EulerRot,[pC.rot]));
      app.EulerCoordinatesDropDown.ValueIndex = id;
      

    end

    % Value changed function: EulerCoordinatesDropDown
    function setEulerCoordinate(app, event)
       
      % mapRot = screen -> mapXYZ
      % EulerRot = screen -> EulerXYZ
      % ebsd.rotations = Euler2MapCorrection .* ebsd.rotations;
      % Euler2MapCorrection = EulerXYZ -> mapXYZ

      pC = app.CoordinateSystems.how2plot; rot = [pC.rot];
      EulerRot = rot(app.EulerCoordinatesDropDown.ValueIndex);
      mapRot = rot(app.MapCoordinatesDropDown.ValueIndex);
      
      % apply new Euler correction
      app.ebsd.EulerCorrection = inv(EulerRot) * mapRot;

    end
  end

  % Component initialization
  methods (Access = private)

    % Create UIFigure and components
    function createComponents(app)

      % Create UIFigure and hide until all components are created
      app.UIFigure = uifigure('Visible', 'off');
      app.UIFigure.Position = [100 100 1300 700];
      app.UIFigure.Name = 'MATLAB App';
      app.UIFigure.Theme = 'light';

      % Create EBSDDataAnalysisPanel
      app.EBSDDataAnalysisPanel = uipanel(app.UIFigure);
      app.EBSDDataAnalysisPanel.Title = 'EBSD Data Analysis';
      app.EBSDDataAnalysisPanel.FontWeight = 'bold';
      app.EBSDDataAnalysisPanel.FontSize = 18;
      app.EBSDDataAnalysisPanel.Position = [1 1 1300 700];

      % Create ImportEBSDDataButton
      app.ImportEBSDDataButton = uibutton(app.EBSDDataAnalysisPanel, 'push');
      app.ImportEBSDDataButton.ButtonPushedFcn = createCallbackFcn(app, @ImportEBSDDataButtonPushed, true);
      app.ImportEBSDDataButton.FontWeight = 'bold';
      app.ImportEBSDDataButton.Position = [20 620 120 40];
      app.ImportEBSDDataButton.Text = 'Import EBSD-Data';

      % Create Panel
      app.Panel = uipanel(app.EBSDDataAnalysisPanel);
      app.Panel.Position = [300 1 1000 673];

      % Create UIAxes
      app.UIAxes = uiaxes(app.Panel);
      title(app.UIAxes, 'Title')
      xlabel(app.UIAxes, 'X')
      ylabel(app.UIAxes, 'Y')
      zlabel(app.UIAxes, 'Z')
      app.UIAxes.Position = [1 0 1000 444];

      % Create DataTable
      app.DataTable = uitable(app.Panel);
      app.DataTable.ColumnName = {'Plot'; 'Phase'; 'Mineral'; 'Pixel'; 'Symmetry'; 'a'; 'b'; 'c'; 'Color'};
      app.DataTable.ColumnWidth = {60, 'auto', 'auto', 'auto', 'auto', 'auto', 'auto', 'auto', 'auto'};
      app.DataTable.RowName = {};
      app.DataTable.ColumnEditable = [true false false true false true true true true];
      app.DataTable.CellEditCallback = createCallbackFcn(app, @DataTableCellEdit, true);
      app.DataTable.CellSelectionCallback = createCallbackFcn(app, @DataTableCellSelection, true);
      app.DataTable.Position = [1 443 1000 230];

      % Create CurrentData
      app.CurrentData = uieditfield(app.EBSDDataAnalysisPanel, 'text');
      app.CurrentData.Editable = 'off';
      app.CurrentData.Position = [150 628 130 25];

      % Create Label
      app.Label = uilabel(app.EBSDDataAnalysisPanel);
      app.Label.Position = [150 74 34 22];

      % Create ExportButton
      app.ExportButton = uibutton(app.EBSDDataAnalysisPanel, 'push');
      app.ExportButton.ButtonPushedFcn = createCallbackFcn(app, @ExportButtonPushed, true);
      app.ExportButton.FontWeight = 'bold';
      app.ExportButton.Position = [50 26 200 35];
      app.ExportButton.Text = 'Export';

      % Create TypeofPlotDropDownLabel
      app.TypeofPlotDropDownLabel = uilabel(app.EBSDDataAnalysisPanel);
      app.TypeofPlotDropDownLabel.HorizontalAlignment = 'right';
      app.TypeofPlotDropDownLabel.FontWeight = 'bold';
      app.TypeofPlotDropDownLabel.Position = [15 566 73 22];
      app.TypeofPlotDropDownLabel.Text = 'Type of Plot';

      % Create TypeofPlotDropDown
      app.TypeofPlotDropDown = uidropdown(app.EBSDDataAnalysisPanel);
      app.TypeofPlotDropDown.Items = {};
      app.TypeofPlotDropDown.ValueChangedFcn = createCallbackFcn(app, @TypeofPlotDropDownValueChanged, true);
      app.TypeofPlotDropDown.Position = [100 557 120 40];
      app.TypeofPlotDropDown.Value = {};

      % Create MapCoordinatesDropDownLabel
      app.MapCoordinatesDropDownLabel = uilabel(app.EBSDDataAnalysisPanel);
      app.MapCoordinatesDropDownLabel.HorizontalAlignment = 'right';
      app.MapCoordinatesDropDownLabel.FontWeight = 'bold';
      app.MapCoordinatesDropDownLabel.Position = [26 498 102 22];
      app.MapCoordinatesDropDownLabel.Text = 'Map Coordinates';

      % Create MapCoordinatesDropDown
      app.MapCoordinatesDropDown = uidropdown(app.EBSDDataAnalysisPanel);
      app.MapCoordinatesDropDown.Items = {'y↑→x', 'y↓→x', 'x↑→y', 'x↓→y'};
      app.MapCoordinatesDropDown.ValueChangedFcn = createCallbackFcn(app, @setMapCoordinates, true);
      app.MapCoordinatesDropDown.FontSize = 16;
      app.MapCoordinatesDropDown.Position = [20 469 130 30];
      app.MapCoordinatesDropDown.Value = 'y↑→x';

      % Create EulerCoordinatesDropDownLabel
      app.EulerCoordinatesDropDownLabel = uilabel(app.EBSDDataAnalysisPanel);
      app.EulerCoordinatesDropDownLabel.HorizontalAlignment = 'right';
      app.EulerCoordinatesDropDownLabel.FontWeight = 'bold';
      app.EulerCoordinatesDropDownLabel.Position = [171 498 108 22];
      app.EulerCoordinatesDropDownLabel.Text = 'Euler Coordinates';

      % Create EulerCoordinatesDropDown
      app.EulerCoordinatesDropDown = uidropdown(app.EBSDDataAnalysisPanel);
      app.EulerCoordinatesDropDown.Items = {'y↑→x', 'y↓→x', 'x↑→y', 'x↓→y', ''};
      app.EulerCoordinatesDropDown.ValueChangedFcn = createCallbackFcn(app, @setEulerCoordinate, true);
      app.EulerCoordinatesDropDown.FontSize = 16;
      app.EulerCoordinatesDropDown.Position = [164 469 130 30];
      app.EulerCoordinatesDropDown.Value = 'y↑→x';

      % Create MapImage
      app.MapImage = uiimage(app.EBSDDataAnalysisPanel);
      app.MapImage.Position = [35 362 100 100];

      % Create EulerImage
      app.EulerImage = uiimage(app.EBSDDataAnalysisPanel);
      app.EulerImage.Position = [179 362 100 100];

      % Create Tree
      app.Tree = uitree(app.EBSDDataAnalysisPanel, 'checkbox');
      app.Tree.Position = [87 74 150 257];

      % Create OrientationMapNode
      app.OrientationMapNode = uitreenode(app.Tree);
      app.OrientationMapNode.Text = 'Orientation Map';

      % Create IPFXNode
      app.IPFXNode = uitreenode(app.OrientationMapNode);
      app.IPFXNode.Text = 'IPFX';

      % Create IPFYNode
      app.IPFYNode = uitreenode(app.OrientationMapNode);
      app.IPFYNode.Text = 'IPFY';

      % Create IPFZNode
      app.IPFZNode = uitreenode(app.OrientationMapNode);
      app.IPFZNode.Text = 'IPFZ';

      % Create PhaseMaptNode
      app.PhaseMaptNode = uitreenode(app.Tree);
      app.PhaseMaptNode.Text = 'Phase Mapt';

      % Create PropertyMapNode
      app.PropertyMapNode = uitreenode(app.Tree);
      app.PropertyMapNode.Text = 'Property Map';

      % Create MADNode
      app.MADNode = uitreenode(app.PropertyMapNode);
      app.MADNode.Text = 'MAD';

      % Create BCNode
      app.BCNode = uitreenode(app.PropertyMapNode);
      app.BCNode.Text = 'BC';

      % Create PoleFiguresNode
      app.PoleFiguresNode = uitreenode(app.Tree);
      app.PoleFiguresNode.Text = 'Pole Figures';

      % Create Node_2
      app.Node_2 = uitreenode(app.PoleFiguresNode);
      app.Node_2.Text = '(100)';

      % Create Node
      app.Node = uitreenode(app.PoleFiguresNode);
      app.Node.Text = '(010)';

      % Create Node_3
      app.Node_3 = uitreenode(app.PoleFiguresNode);
      app.Node_3.Text = '(001)';

      % Assign Checked Nodes
      app.Tree.CheckedNodes = [app.PhaseMaptNode];

      % Show the figure after all components are created
      app.UIFigure.Visible = 'on';
    end
  end

  % App creation and deletion
  methods (Access = public)

    % Construct app
    function app = MApp_exported

      runningApp = getRunningApp(app);

      % Check for running singleton app
      if isempty(runningApp)

        % Create UIFigure and components
        createComponents(app)

        % Register the app with App Designer
        registerApp(app, app.UIFigure)

        % Execute the startup function
        runStartupFcn(app, @startupFcn)
      else

        % Focus the running singleton app
        figure(runningApp.UIFigure)

        app = runningApp;
      end

      if nargout == 0
        clear app
      end
    end

    % Code that executes before app deletion
    function delete(app)

      % Delete UIFigure when app is deleted
      delete(app.UIFigure)
    end
  end
end