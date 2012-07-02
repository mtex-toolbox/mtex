function d = dot(rot1,rot2)
% compute rot1 . rot2

d = abs(dot(quaternion(rot1),quaternion(rot2)));
