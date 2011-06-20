function v = rotate(v,q)
% rotate vector3d by quaternion
%
%% Syntax
%  r = rotate(v,q)
%
%% Input
%  v - @vector3d
%  q - @quaternion
%
%% Output
%  r = q * v;

%extract coefficients
[a,b,c,d] = double(q);

% rotate
[v.x,v.y,v.z] = quaternion_mtimes(a(:),b(:),c(:),d(:),v.x(:).',v.y(:).',v.z(:).');
		
% resize
if numel(v) == 1  
  v = reshape(v,size(q));
elseif numel(q) == 1
  v = reshape(v,size(v));
end

% convert to vector3d
v = vector3d(v);
