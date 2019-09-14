function d = dot(rot1,rot2)
% compute rot1 . rot2

rot1 = rotation(rot1);
rot2 = rotation(rot2);

d = abs(dot(quaternion(rot1),quaternion(rot2)));

d = d .* (~xor(rot1.i,rot2.i));
