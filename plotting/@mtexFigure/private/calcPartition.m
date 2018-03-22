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
