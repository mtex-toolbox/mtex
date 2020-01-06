function v1 = plus(v1,v2)
% poitwise addition

try %#ok<TRYNC>
  v1.x = v1.x+v2.x;
  v1.y = v1.y+v2.y;
  v1.z = v1.z+v2.z;
  
  v1.isNormalized = false;
  v1.opt = struct;
  return
end

if isnumeric(v1)
  v1 = vector3d(v1 + v2.x,v1 + v2.y,v1 + v2.z);
elseif isnumeric(v2)
  v1 = vector3d(v2 + v1.x,v2 + v1.y,v2 + v1.z);
else
  v1 = plus(v2,v1);
end