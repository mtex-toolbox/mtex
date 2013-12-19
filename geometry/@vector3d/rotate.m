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

% bring the coefficient into the right shape
[a,b,c,d] = double(q(:));
[x,y,z] = deal(v.x(:).',v.y(:).',v.z(:).');

%rotation
v.x = (a.^2+b.^2-c.^2-d.^2)*x + 2*( (a.*c+b.*d)*z + (b.*c-a.*d)*y );
v.y = (a.^2-b.^2+c.^2-d.^2)*y + 2*( (a.*d+b.*c)*x + (c.*d-a.*b)*z );
v.z = (a.^2-b.^2-c.^2+d.^2)*z + 2*( (a.*b+c.*d)*y + (b.*d-a.*c)*x );

% [v.x,v.y,v.z] = quaternion_mtimes(a(:),b(:),c(:),d(:),x(:).',y(:).',z(:).');

if numel(v) == 1
  v = reshape(v,size(q));
elseif numel(q) == 1
  v = reshape(v,size(v));
end

% convert to vector3d
v = vector3d(v);
