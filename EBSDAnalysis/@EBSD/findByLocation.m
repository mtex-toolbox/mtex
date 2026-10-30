function ind = findByLocation( ebsd, xy, y )
% index of the measurement closest to given spatial coordinates
%
% Syntax
%   ind = findByLocation(ebsd,xy)
%   ind = findByLocation(ebsd,x,y)
%   ebsd(ind)
%
% Input
%  ebsd - @EBSD
%  xy   - list of [x(:) y(:)] coordinates
%  x,y  - list of x and y coordinates
%
% Output
%  ind - one index into ebsd per coordinate, 0 outside the map
%
% Example
%   mtexdata forsterite silent
%
%   plot(ebsd)
%   p = [10000 5000] %ginput(1)
%   ind = findByLocation(ebsd,p)
%
% See also
% EBSD/findByLocation grain2d/findByOrientation

if nargin==3, xy = [xy(:),y(:)]; end

if isa(ebsd,'EBSDgrid')

  % invert the grid, no search required
  [i,j] = ebsd.pos2ind(xy(:,1),xy(:,2));
  ind = zeros(size(i));
  in = i>=1 & i<=size(ebsd,1) & j>=1 & j<=size(ebsd,2);
  ind(in) = sub2ind(size(ebsd),i(in),j(in));

else

  xyRef = [ebsd.pos.x(:),ebsd.pos.y(:)];
  ind = nearestId(xyRef,xy);
  ind(any(abs(xyRef(ind,:) - xy) > mean(norm(ebsd.unitCell)),2)) = 0;

end
