function ind = inpolygon(grains,xy)
% checks which grains are within given polygon
%
% Syntax
%   ind = inpolygon(grains,[xmin,ymin,dx,dy]) % select indices by rectangle
%   ind = inpolygon(grains,[x1 y1; x2 y2; x3 y3; x4 y4]) % select indices by poylgon
%   grains = grains(ind) % select grains data by indices
%
% Input
%  grains    - @grain2d
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

g_ctd=grains.centroid; % Grains centroid

if ~isempty(g_ctd(:,1))
  %  check for inside
  ind = inpolygon(g_ctd(:,1),g_ctd(:,2),xy(:,1),xy(:,2));
  
end