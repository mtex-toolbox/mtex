function ind = inpolygon(gb,xy)
% checks which gb data are within given polygon
%
% Syntax
%   ind = inpolygon(gb,[xmin,ymin,dx,dy]) % select indices by rectangle
%   ind = inpolygon(gb,[x1 y1; x2 y2; x3 y3; x4 y4]) % select indices by poylgon
%   gb = gb(ind) % select gb data by indices
%
% Input
%  gb    - @grainBoundary
%  xmin, xmax - lower left corner of a rectangle
%  dx, dy - extend of a rectangle
%  x, y  - vertices of a polygon
%
% Output
%  ind - logical
%
% See also
% inpolygon

% shortcut for simple rectangles
if numel(xy)==4
  
  xy(3:4) = xy(1:2) + xy(3:4);
  corners = [1 2; 3 2; 3 4; 1 4; 1 2];
  xy = xy(corners);
  
end

if ~isempty(gb.midPoint(:,1))
  %  check for inside
  ind = inpolygon(gb.midPoint(:,1),gb.midPoint(:,2),xy(:,1),xy(:,2));
  
end