function v = plus(v1,v2)
% poitwise addition

try %#ok<TRYNC>
  v = vector3d(v1.x+v2.x,v1.y+v2.y,v1.z+v2.z);
  return
end

if isnumeric(v1)
  v = vector3d(v1 + v2.x,v1 + v2.y,v1 + v2.z);
elseif isnumeric(v2)
  v = vector3d(v2 + v1.x,v2 + v1.y,v2 + v1.z);
else
  v = plus(v2,v1);
end