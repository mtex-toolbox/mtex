function out = isOuterBoundary(grains,varargin)
% check which of the indexed grains border with the map/
% domain boundary - use this function to find boundary grains
% if they were reconstructed using alphaShapes
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
%  delta  - double (default 0.95; 0 = convex hull, 1 = envelop touching all points)
%
% Description
% The envelope is spanned by vertices of the grains themselves, so the
% question which grain it touches is one of vertex identity and is answered
% by the polygons directly. It used to be asked as a point in polygon test
% against every grain, which is the same answer by a longer route - and one
% that depended on how exactly a point sitting on a boundary is classified.
% See issue #2527.
%
% See also
% grain2d/isBoundary

% take all vertices
V = grains.V;
x = V.x;  y = V.y;

% how tight should the boundary stick to the map?
% 0 = convex hull 1 = envelop touching all outer points
delta = get_option(varargin,'delta',0.95);

% indices belonging to the domain boundary
k = boundary(x,y,delta);

% grains.V is allV restricted to the vertices the polygons use, in exactly
% this order - so this maps the envelope back to ids into allV
iV = unique(cat(2,grains.poly{:}));
isEnvelope = false(length(grains.allV),1);
isEnvelope(iV(k)) = true;

% a grain borders the map where one of its own vertices is on the envelope
out = reshape(cellfun(@(p) any(isEnvelope(p)),grains.poly),[],1);

end
