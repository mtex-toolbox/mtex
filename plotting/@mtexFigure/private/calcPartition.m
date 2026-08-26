function [ncols,nrows] = calcPartition(mtexFig,figSize,varargin)
% determine best partition of equaly sized axes within a figure
%
% Input
%  mtexFig - mtexFigure
%  figSize - avaiable space
%
% Output
%  ncols - number of columns
%  nrows - number of rows


if ~strcmp(mtexFig.layoutMode,'auto')
  ncols = mtexFig.ncols; nrows = mtexFig.nrows;
  return
elseif isscalar(mtexFig.children)
  ncols = 1; nrows = 1;
  return
elseif ~isempty(mtexFig.fixedAxisHeight)
  % with the axis size fixed there is nothing to maximise - go for a single
  % row and break into a second one only when it gets too long
  nrows = 1 + (numel(mtexFig.children) > 4);
  ncols = ceil(numel(mtexFig.children) / nrows);
  return
end

% start with one row partition
nrows = 1; ncols = numel(mtexFig.children);
axisWidth = calcAxesSize(mtexFig,figSize,ncols,nrows);

% check for best partitions
for nr=2:numel(mtexFig.children)
  nc = ceil(numel(mtexFig.children) / nr);
  next = calcAxesSize(mtexFig,figSize,nc,nr);
  if next > axisWidth % new best fit
    axisWidth = next;
    ncols = nc;
    nrows = nr;
  end
end

end
