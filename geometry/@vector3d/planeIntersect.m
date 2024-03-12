function v = planeIntersect(n1,n2,n3,d)
% intersection of three planes
%
% Input
%  n1,n2,n3 - plane normal @vector3d, <x,n_i> = d_i
%  d        - [d1,d2,d3] distances of the three planes to the origin
%
% Output
%  v - @vector3d
%
% See also
% vector3d/lineIntersect
%

% ensure last argument is vector3d
if nargin == 4
  d = vector3d(d);
else
  d = vector3d(1,1,1);
end

D = det(n1,n2,n3);
D(isnull(D)) = 0;

x = vector3d(n1.x,n2.x,n3.x);
y = vector3d(n1.y,n2.y,n3.y);
z = vector3d(n1.z,n2.z,n3.z);

v = vector3d(det(d,y,z),det(x,d,z),det(x,y,d)) ./ D;