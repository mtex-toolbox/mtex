classdef mtexFigure < handle
% 
% a class to handles figures equaly sized axes with the following features
%
% * nicely resize axes
% * global or individual colorbars
% *
%
% Syntax
%   newMTEXFigure
%
%
% Class Properties
%  parent            - handle of the parent figure    
%  children          - handles to all axes
%  cBarAxis          - handles to all colorbar axes
%  innerPlotSpacing  - 
%  keepAspectRatio   - 
%  nrows = 1         - number of rows
%  ncols = 1         - number of columns
%  axisWidth         - width of an individual axis
%  axisHeight        - height of an individual axis 
%  cbx = 0           - colorbar width
%  cby = 0           - colorbar height
%  tightInset        - is added to axisSize
%  figTightInset     - is added to figSize
%  layoutMode        - 'auto' or 'user'
%
% Dependent Class Properties
%   currentAxes      - handle of the current axis
%   currentId        - id of te current axis 
%   axesWidth        - 
%   axesHeight       -
%   outerPlotSpacing -
%   dataCursorMenu   - handle of the data cursor context menu  
%
% Description
% 
% The calculation of the layout is initiated by the command
% <mtexFigure.drawNow.html drawNow>. This involves calls to the following
% functions:
%
%  drawNow
%    |  |
%    V  |
%  calcTightInset -> compute width of boundary around each axis
%       |
%       V
%  updateLayout
%       |
%       V
%  calcPartition -> compute partition (nrows, ncols)
%       |
%       V
%  calcAxesSize  -> compute axes size
%
% A mtexFigure may have the following children
%
% * <mapPlot.html mapPlot> -> micronbar
% * <sphericalPlot.html sphericalPlot> (stored in appdata of axes handle)
% * pfPlot [CS,SS,h]
% * ipdfPlot [CS]
% * MillerPlot [r,SS]
%
% See also
%

  properties
    parent            % the parent figure    
    children          % the axes
    cBarAxis          % the colorbar axes
    innerPlotSpacing  %
    keepAspectRatio   % 
    nrows = 1         % number of rows
    ncols = 1         % number of columns
    axisWidth         % width of an individual axis
    axisHeight        % height of an individual axis 
    cbx = 0           % colorbar width
    cby = 0           % colorbar height
    tightInset = [0,0,0,0] % is added to axisSize
    figTightInset = [10,10,10,10] % is added to figSize
    layoutMode = 'auto' % set to user to fix it
    figSizeFactor = 0 % relative to the full screen
  end
  
  properties (Dependent = true)        
    currentAxes       % current axis
    currentId         % current axis id
    axesWidth         %
    axesHeight        %
    outerPlotSpacing  %
    dataCursorMenu    % handle of the data cursor context menu  
  end

  properties (Access = protected)
    cBarShift
  end
  
  
  methods    
    
    function mtexFig = mtexFigure(varargin)
      
      % clear figure and set it up
      
      clf('reset');
      rmallappdata(gcf);
      set(gcf,'Visible','on');

      % set figure name
      if ~isempty(get_option(varargin,'FigureTitle'))
        set(gcf,'Name',get_option(varargin,'FigureTitle'));
      end
      
      % set custom resize function
      set(gcf,'ResizeFcn',@(src,evt) updateLayout(mtexFig));

      mtexFig.parent = gcf;
                
      mtexFig.outerPlotSpacing = get_option(varargin,'outerPlotSpacing',...
        getMTEXpref('outerPlotSpacing'));
      mtexFig.innerPlotSpacing = get_option(varargin,'innerPlotSpacing',...
        getMTEXpref('innerPlotSpacing'));
      mtexFig.keepAspectRatio = get_option(varargin,'keepAspectRatio',true);
      
      colrow = get_option(varargin,'layout',[1 1]);
      mtexFig.nrows = get_option(varargin,'nrows',colrow(1));
      mtexFig.ncols = get_option(varargin,'ncols',colrow(2));
      
      if check_option(varargin,{'nrows','ncols','layout'})
        mtexFig.layoutMode = 'user';
      end
           
      switch get_option(varargin,'figSize','','char')
        case 'huge'
          mtexFig.figSizeFactor = 1;
        case 'large'
          mtexFig.figSizeFactor = 0.8;
        case {'normal','medium'}
          mtexFig.figSizeFactor = 0.5;
        case 'small'
          mtexFig.figSizeFactor = 0.35;
        case 'tiny'
          mtexFig.figSizeFactor =  0.25;
        otherwise
          mtexFig.figSizeFactor = get_option(varargin,'figSize',0,'double');
      end
            
      set(mtexFig.parent,'color',[1 1 1],'nextPlot','replaceChildren');
      setappdata(mtexFig.parent,'mtexFig',mtexFig);
      
      varargin = delete_option(varargin,'color',1);
      varargin = delete_option(varargin,'position',1);
      optiondraw(mtexFig.parent,varargin{:});              

      % set data cursor
      if check_option(varargin,'datacursormode')
        dcm_obj = datacursormode(mtexFig.parent);
        set(dcm_obj,'SnapToDataVertex','off')
        set(dcm_obj,'UpdateFcn',ensurecell(get_option(varargin,'datacursormode')));
        if ~check_option(varargin,'3d')
          datacursormode on;
        end
      end
      
      set(mtexFig.parent,'DefaultAxesCreateFcn', @updateChildren);
      set(mtexFig.parent,'DefaultAxesDeleteFcn', @deleteChildren);
      
      MTEXFigureMenu(mtexFig,varargin{:});
      
      h = findall(mtexFig.parent,'ToolTipString','Insert Colorbar');
      set(h,'ClickedCallback',@(a,b) mtexColorbar(mtexFig,a,b));
      
      function updateChildren(a,b)
        
        % prevent that this is called by colorbar
        x = dbstack; 
        if any(strcmpi(x(2).name,{'colorbar','legend'})), return;end
        
        mtexFig.children = ...
        flipud(findobj(mtexFig.parent,'type','axes',...
        '-not','tag','Colorbar','-and','-not','tag','legend')); 
      end
      
      function deleteChildren(a,b)
        mtexFig.children(mtexFig.children==a) = [];
      end
      
    end
    
    function ax = gca(mtexFig)
      % return current axis if exist otherwise create a new one
      
      if mtexFig.currentId == 0, mtexFig.currentId = 1;end
      
      ax = mtexFig.currentAxes;
      
    end
    
    
    % ---------------------------------------------------------
            
    function ax = get.currentAxes(mtexFig)
      ax = get(mtexFig.parent,'CurrentAxes');
    end
    
    function set.currentAxes(mtexFig,ax)
      try
        set(mtexFig.parent,'CurrentAxes',ax);
      end
    end
        
    function id = get.currentId(mtexFig)
      if isempty(mtexFig.currentAxes)
        id = 0;
      else
        id = find(mtexFig.currentAxes == mtexFig.children);
      end
    end
    
    function set.currentId(mtexFig,id)
      
      if id > numel(mtexFig.children) % create a nex axes
        for k = numel(mtexFig.children)+1:id
          axes('visible','off','parent',mtexFig.parent);
        end
        set(mtexFig.parent,'nextplot','add');
  
        if numel(mtexFig.children) > mtexFig.ncols * mtexFig.nrows
          mtexFig.ncols = ceil(numel(mtexFig.children) / mtexFig.nrows);
        end
        
      else
        set(mtexFig.parent,'CurrentAxes',mtexFig.children(id));
      end      
    end
    
    function w = get.outerPlotSpacing(mtexFig)  
      w = min(mtexFig.figTightInset);
    end
    
    function set.outerPlotSpacing(mtexFig,w)  
      mtexFig.figTightInset = w * [1,1,1,1];
    end
    
    function aw = get.axesWidth(mtexFig)
      % the width of all axes is the number of columns times the width of
      % each single axis + inner and outer spacing
      
      aw = mtexFig.ncols * (mtexFig.axisWidth + sum(mtexFig.tightInset([1,3])))...
        + sum(mtexFig.figTightInset([1,3])) + ...
        (mtexFig.ncols-1) * mtexFig.innerPlotSpacing;
    end
    
    function ah = get.axesHeight(mtexFig)
      % the height of all axes is the number of rows times the height of
      % each single axis + inner and outer spacing
      
      ah = mtexFig.nrows * (mtexFig.axisHeight + sum(mtexFig.tightInset([2,4])))...
        + sum(mtexFig.figTightInset([2,4])) + ...
        (mtexFig.nrows-1) * mtexFig.innerPlotSpacing;
    end

    function setCamera(mtexFig,varargin)
      
      for a = 1:numel(mtexFig.children)
        setCamera(mtexFig.children(a),varargin{:});        
      end
      mtexFig.drawNow;
    end
    
    function dcm = get.dataCursorMenu(mtexFig)
      
     dcm_obj = datacursormode(mtexFig.parent);        
     dcm = dcm_obj.UIContextMenu;

    end
    
  end
end

