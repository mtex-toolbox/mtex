function v = normalize(v,flag)
% normalize a vector
%
% Syntax
%   v = normalize(v) % norm zero vectors are normalized to NaN     
%   v = normalize(v,true) % norm zero vectors are normalized to zero
%
% Input
%  v - @vector3d
%
% Output
%  v - @vector3d
%

if v.isNormalized, return; end

nv = norm(v);
if nargin == 2 && flag == 1
  id = nv>eps;
  v.x(id) = v.x(id)./nv(id);
  v.y(id) = v.y(id)./nv(id);
  v.z(id) = v.z(id)./nv(id);
else
  v = v ./ nv;
end

v.isNormalized = true;