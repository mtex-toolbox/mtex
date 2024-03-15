function V = innerFace(cS, N)
% return the vertices of an inner face of a crystal shape
%
% Syntax
%   N = Miller(1,0,1,'hkl',cs)
%   v = innerFace(cS,N) 
%
% Input
%  cS - @crystalShape
%  N  - @Miller lattice plane
%
% Output
%  V - vertices of the inner plane
%

% starting and end points of all vertices
v1 = cS.V(cS.E(:,1));
v2 = cS.V(cS.E(:,2));

% compute intersections between edges and plane normal
V = lineIntersect(v1,v2,N,0);
V = V(~isnan(V));
V = unique(V);

% convex hull of vertices - we do this in 2d to avoid triangulation
rot = rotation.map(N,zvector);
VPlane = rot .* V;
T = convhull([VPlane.x,VPlane.y],'Simplify',true);

V = V.subSet(T);

end
