function v = cross(v1,v2)
% pointwise cross product of two vector3d
%
% Syntax
%   v = cross(v1,v2)
%
% Input
%  v1,v2 - @vector3d
%
% Output
%  v - @vector3d

if ~isa(v2,'vector3d')
  v = cross(v2,-v1);
else
  v = v1;
  v.x = v1.y.*v2.z-v1.z.*v2.y;
  v.y = v1.z.*v2.x-v1.x.*v2.z;
  v.z = v1.x.*v2.y-v1.y.*v2.x;
  v.isNormalized = false;
  v.antipodal = v1.antipodal | v2.antipodal;

  % the cross product of two plane normals is a lattice direction and the
  % one of two directions a plane normal, so the indices switch sides
  v.dispStyle = MillerConvention(-MillerConvention(v.dispStyle));
end
