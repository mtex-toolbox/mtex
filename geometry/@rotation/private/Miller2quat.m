function quat = Miller2quat(v1,v2,CS)
% calculate quaternion from Miller indece
%
% Description
% The method *Miller2quat* defines a [[quaternion_index.html,rotation]]
% by Miller indece as the rotation |q| such that |q * v1 = e3| and |q * e1 = v2|
%
% Syntax
%  quat = Miller2quat(m1,m2)
%  quat = Miller2quat([h k l],[u v w],CS)
%
% Input
%  m1, m2 - @Miller
%  h,k,l  - Miller indece (double)
%  u,v,w  - Miller indece (double)
%  CS     - @crystalSymmetry
%
% Output
%  quat - @quaternion
%
% See also
% rotation_index quaternion/quaternion 
% vec42quat hr2quat


if isa(v1,'double')
  if nargin == 2, CS = crystalSymmetry('cubic');end
  v1 = Miller(v1(1),v1(2),v1(3),CS);
  v2 = Miller(v2(1),v2(2),v2(3),CS);
end


% ensure angle (v1,v2) = 90°

v1 = vector3d(v1);
v2 = symmetrise(v2);

v2 = v2(isnull(dot(v1,v2))); v2 = v2(1);

if isempty(v2), error('Miller indece have to be orthogonal');end

% v1 -> e3
q1 = hr2quat(v1,zvector);

q1v2 = q1 .* v2;
phi = dot(q1v2,xvector);

% q1v2 -> e1
d = dot(cross(q1v2,xvector),zvector);
q2 = axis2quat(zvector,sign(d).*acos(phi));

% q1v2 ?= e1
ind = isnull(phi - 1);
quat = q1;
quat(~ind) = q2(~ind).*q1(~ind);
