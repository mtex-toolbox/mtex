function v = rotate(v,q)
% rotate vector3d by quaternion
%% Input
%  v - @vector3d
%  q - @quaternion
%% Output
%  r = q v;

[a,b,c,d] = double(q);
[v.x,v.y,v.z] = quaternion_mtimes(a(:),b(:),c(:),d(:),v.x(:).',v.y(:).',v.z(:).');
		
if numel(v) == 1  
  v = reshape(v,size(q));
elseif numel(q) == 1
  v = reshape(v,size(v));
end
