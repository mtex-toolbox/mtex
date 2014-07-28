function calcBestFit(mtexFig,varargin)
% determine best partition of equaly sized axes within a figure
%
% Input
%  mtexFig - mtexFigure
%  dxdy    - ratio axesHeight / axesWidth
%  n       - number of axes to placed
%  marginx -
%  marginy - 
%
% Output
%  ncols - number of columns
%  nrows - number of rows
%  axisWidth - width of an axis

% compute empty space
if check_option(varargin,'screen')
  screenExtend = get(0,'MonitorPositions');
  figSize = screenExtend(1,:); % consider only the first monitor
else
  figSize = get(mtexFig.parent,'Position');
end
figSize = figSize(3:4) - 2*mtexFig.outerPlotSpacing;


if mtexFig.keepAspectRatio

  % get axes size
  axesSize = get(mtexFig.children(1),'PlotBoxAspectRatio');

  % correct for xAxisDirection
  if find(get(mtexFig.children(1),'CameraUpVector'))==1
    axesSize(1:2) = fliplr(axesSize(1:2));
  end
  axesRatio = axesSize(2)/axesSize(1);

  % maximum axes width for a given partition
  lx = @(nc,nr) ceil(min(...
    (figSize(1)-(nc-1)*mtexFig.innerPlotSpacing - nc*mtexFig.cbx)/nc,...
    (figSize(2)-(nr-1)*mtexFig.innerPlotSpacing - nr*mtexFig.cby)/axesRatio/nr));

  % start with one row partition
  mtexFig.nrows = 1; mtexFig.ncols = numel(mtexFig.children);
  mtexFig.axisWidth = lx(mtexFig.ncols,mtexFig.nrows);

  % check for better partitions
  
  for nr=2:numel(mtexFig.children)
    nc = ceil(numel(mtexFig.children) / nr);
    if lx(nc,nr) > mtexFig.axisWidth % new best fit
      mtexFig.axisWidth = lx(nc,nr);
      mtexFig.ncols = nc;
      mtexFig.nrows = nr;
    end
  end

  if check_option(varargin,'maxWidth')
    mtexFig.axisWidth = min(mtexFig.axisWidth,get_option(varargin,'maxWidth'));
  end

  mtexFig.axisHeight = ceil(mtexFig.axisWidth*axesRatio);
  
else
  mtexFig.axisWidth = (figSize(1)-(mtexFig.ncols-1)*mtexFig.innerPlotSpacing)/mtexFig.ncols;
  mtexFig.axisHeight = (figSize(2)-(mtexFig.nrows-1)*mtexFig.innerPlotSpacing)/mtexFig.nrows;
end
  
end

