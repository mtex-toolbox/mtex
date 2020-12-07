function v = cubochoric(q)
% cubochoric coordinates
%
% Cubochoric coordinates
% (<http://dx.doi.org/10.1088/0965-0393/22/7/075013 D. Rosca, A. Morawiec,
% M. De Graef. _A new method of constructing a grid in the space of 3D
% rotations and its applications to texture analysis_, Modeling and
% Simulations in Materials Science and Engineering, 22:075013, 2014> are a
% equal volume representation of the rotation space within a cube.
%
% Input
%  q - @quaternion
%
% Output
%  v - @vector3d
%
% See also
% quaternion/Euler quaternion/Rodigues quaternion/homochoric

% homochoric transformation first
v = homochoric(q);

% 
xyz = homo2cubo([v.x(:), v.y(:), v.z(:)]);

v.x = xyz(:,1);
v.y = xyz(:,2);
v.z = xyz(:,3);

v = reshape(v, size(q));