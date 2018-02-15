function [width,height] = calcAxesSize(mtexFig,figSize,nc,nr,varargin)
% determine best partition of equaly sized axes within a figure
%
% Input
%  mtexFig - mtexFigure
%  nc - number of columns
%  nr - number of rows
%
% Output
%  width, height - width of an axis

if nargin <= 2, nc = mtexFig.ncols; nr = mtexFig.nrows; end

% compute axes lenght ratio
axesSize = get(mtexFig.children(1),'PlotBoxAspectRatio');
cd = get(mtexFig.children(1),'CameraPosition')-get(mtexFig.children(1),'CameraTarget');
axesSize(cd == max(abs(cd))) = [];

if find(get(mtexFig.children(1),'CameraUpVector'))==1
  axesRatio = axesSize(1)/axesSize(2);
else
  axesRatio = axesSize(2)/axesSize(1);
end

width = (figSize(1)-(nc-1)*mtexFig.innerPlotSpacing - nc*sum(mtexFig.tightInset([1,3])))/nc;
height = (figSize(2)-(nr-1)*mtexFig.innerPlotSpacing - nr*sum(mtexFig.tightInset([2,4])))/nr;

if mtexFig.keepAspectRatio
  width = ceil(min(width,height/axesRatio));
  height = ceil(width*axesRatio);
end
  
  
end
