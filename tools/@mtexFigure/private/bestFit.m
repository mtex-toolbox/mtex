function [ncols,nrows,axisWidth] = bestFit(figSize,dxdy,n,marginx,marginy)
% determine best partition of equaly sized axes within a figure
%
% Input
%  figSize - empty space in the figure
%  dxdy    - ratio axesHeight / axesWidth
%  n       - number of axes to placed
%  marginx -
%  marginy - 
%
% Output
%  ncols - number of columns
%  nrows - number of rows
%  axisWidth - width of an axis

% maximum axes width for a given partition
lx = @(nc,nr) ceil(min((figSize(1)-(nc-1)*marginx)/nc,...
  (figSize(2)-(nr-1)*marginy)/dxdy/nr));

% start with one row partition
nrows = 1; ncols = n;
axisWidth = lx(ncols,nrows);

if n == 1, return;end

% check for better partitions
for nr=2:n
  nc = ceil(n/nr);
  if lx(nc,nr) > axisWidth % new best fit
    axisWidth = lx(nc,nr);
    ncols = nc;
    nrows = nr;
  end
end

end
