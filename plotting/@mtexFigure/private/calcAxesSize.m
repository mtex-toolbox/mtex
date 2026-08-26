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

ratio = axesRatio(mtexFig.children(1));

% a fixed height ignores the space available - the figure is grown to fit it
if ~isempty(mtexFig.fixedAxisHeight)
  height = mtexFig.fixedAxisHeight;
  width = height / ratio;
  return
end

width = (figSize(1)-(nc-1)*mtexFig.innerPlotSpacing - nc*sum(mtexFig.tightInset([1,3])))/nc;
height = (figSize(2)-(nr-1)*mtexFig.innerPlotSpacing - nr*sum(mtexFig.tightInset([2,4])))/nr;

if mtexFig.keepAspectRatio
  width = ceil(min(width,height/ratio));
  height = ceil(width*ratio);
end

end
