function [width,height] = calcAxesSize(mtexFig,figSize,nc,nr,varargin)
% determine best partition of equally sized axes within a figure
%
% Input
%  mtexFig - @mtexFigure
%  nc - number of columns
%  nr - number of rows
%
% Output
%  width, height - width of an axis

if nargin <= 2, nc = mtexFig.ncols; nr = mtexFig.nrows; end

if isa(mtexFig.children(1),'matlab.graphics.axis.PolarAxes')

  % polar axes are circular and have no camera to derive a ratio from
  axesRatio = 1;

else

  % compute axes length ratio
  axesSize = mtexFig.children(1).PlotBoxAspectRatio;

  [~,dUp] = max(abs(mtexFig.children(1).CameraUpVector));
  height = axesSize(dUp);
  axesSize(dUp) = 0;

  % camera direction
  cd = mtexFig.children(1).CameraPosition - mtexFig.children(1).CameraTarget;
  axesSize(find(cd == max(abs(cd)),1)) = 0;
  width = max(axesSize);

  axesRatio = height/width;

end

width = (figSize(1)-(nc-1)*mtexFig.innerPlotSpacing - nc*sum(mtexFig.tightInset([1,3])))/nc;
height = (figSize(2)-(nr-1)*mtexFig.innerPlotSpacing - nr*sum(mtexFig.tightInset([2,4])))/nr;

if mtexFig.keepAspectRatio
  width = ceil(min(width,height/axesRatio));
  height = ceil(width*axesRatio);
end
  
end
