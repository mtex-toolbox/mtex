function r = rotate(v,q)
% rotate vector3d by quaternion
%% Input
%  v - @vector3d
%  q - @quaternion
%% Output
%  r = q v;

r = reshape(q,[],1) * reshape(v,1,[]);

if numel(v) == 1  
  r = reshape(r,size(q));
elseif numel(q) == 1
  r = reshape(r,size(v));
end
