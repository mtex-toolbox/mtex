function p = planeIntersect(n1,n2,n3,d)
% pointwise determinant or triple product of three vector3d
%
% Input
%  n1,n2,n3 - normal @vector3d
%  d        - distance
%
% Output
%  d - double

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

p = vector3d(det(d,y,z),det(x,d,z),det(x,y,d)) ./ D;