function q = hr2quat(h,r)
% arbitrary quaternion q with q * h = r 
%
% Description
% The method |hr2quat| defines a <quaternion.quaternion.html rotation> |q|
% by a crystal direction |h| and a specimen direction |r| such that 
% |q * h = r| 
%
% Input
%  h - @Miller or @vector3d
%  r - @vector3d
%
% Output
%  q - @quaternion
%
% See also
% quaternion/quaternion quaternion/quaternion axis2quat Miller2quat 
% vec42quat euler2quat

h = vector3d(h);
h = h./norm(h);
r = r./norm(r);

h.antipodal = false;
r.antipodal = false;

n = cross(h,r);

ind = isnull(n);

if length(h) >= length(r)
  n(ind) = orth(h(ind));
else
  n(ind) = orth(r(ind));
end

q = axis2quat(n,angle(h,r,'noSymmetry'));

