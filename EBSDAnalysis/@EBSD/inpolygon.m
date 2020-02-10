function ind = inpolygon(ebsd,xy)
% checks which ebsd data are within given polygon
%
% Syntax
%   ind = inpolygon(ebsd,[xmin,ymin,dx,dy]) % select indices by rectangle
%   ind = inpolygon(ebsd,[x1 y1; x2 y2; x3 y3; x4 y4]) % select indices by poylgon
%   ebsd = ebsd(ind) % select EBSD data by indices
%
% Input
%  ebsd    - @EBSD
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

% check for inside
if ~getMTEXpref('insidepoly')
  ind = inpolygon(ebsd.prop.x,ebsd.prop.y,xy(:,1),xy(:,2));
else
  ind = insidepoly(ebsd.prop.x,ebsd.prop.y,xy(:,1),xy(:,2));
end
  
end
