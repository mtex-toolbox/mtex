function q = hr2quat(h,r)
% arbitrary quaternion q with q * h = r 
%
%% Description
% The method *hr2quat* defines a [[quaternion_index.html,rotation]] |q|
% by a crystal direction |h| and a specimen direction |r| such that 
% |q * h = r| 
%
%% Input
%  h, r - @vector3d
%
%% Output
%  q - @quaternion
%
%% See also
% quaternion_index quaternion/quaternion axis2quat Miller2quat 
% vec42quat euler2quat idquaternion 


h = h./norm(h);
r = r./norm(r);

n = cross(h,r);

ind = isnull(n);
n(ind) = orth(h(ind));

q = axis2quat(n,acos(dot(h,r)));

