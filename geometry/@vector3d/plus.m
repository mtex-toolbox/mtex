function v = plus(v1,v2)
% poitwise addition

if isnumeric(v1)
  v = v2;
  v.x = v1 + v2.x;
  v.y = v1 + v2.y;
  v.z = v1 + v2.z;     
elseif isnumeric(v2)
  v = v1;
  v.x = v1.x + v2;
  v.y = v1.y + v2;
  v.z = v1.z + v2;
elseif isa(v2,'S2Grid')
  v = v1 + vector3d(v2);
elseif isa(v1,'S2Grid')
  v = vector3d(v1) + v2;
elseif isa(v2,'vector3d') && isa(v1,'vector3d')
  v = v1;
  v.x = v1.x + v2.x;
  v.y = v1.y + v2.y;
  v.z = v1.z + v2.z;
else
  v = plus(v2,v1);
end

v.isNormalized = false;