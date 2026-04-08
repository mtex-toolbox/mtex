function v = transpose(v)

v = transpose@vector3d(v);
v.rot = v.rot.';

end