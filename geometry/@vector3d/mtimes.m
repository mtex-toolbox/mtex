function v = mtimes(v1,v2)
% scalar multiplication

if isnumeric(v1)
  v = v2;
  v.x = v1 * v2.x;
  v.y = v1 * v2.y;
  v.z = v1 * v2.z;     
elseif isnumeric(v2)
  v = v1;
  v.x = v1.x * v2;
  v.y = v1.y * v2;
  v.z = v1.z * v2;
else
  v = [v1.x(:).';v1.y(:).';v1.z(:).'] * [v2.x(:),v2.y(:),v2.z(:)];
  %error('the product is not defined. see <a href="matlab: help vector3d/dot">dot</a> or use .*');
end