function out = isOuterBoundary(grains,varargin)
% check which of the indexed grains border with the map/
% domain boundary - use this function to find boundary grains 
% if they were recosntructed using alphaShapes
%
% Syntax
%
%   out = isOuterBoundary(grains)
%
% Input
%
%  grains - @grain2d
%
% Output
%  out    - logical
%
% Options
%  'delta'  - double (default 0.95; 0 = convex hull,
%                                 1 = envelop touching all points)
%
% see also isBoundary

% take all vertices
V = grains.V;
x = V.x;  y = V.y;      

% how tight should the boundary stick to the map?
% 0 = convex hull 1 = envelop touchign all outer points
delta = get_option(varargin,'delta',0.95);

% indices belonging to the domain boundary
k = boundary(x,y,delta);
   
out = checkInside(grains,[x(k),y(k)],'includeBoundary');

end





