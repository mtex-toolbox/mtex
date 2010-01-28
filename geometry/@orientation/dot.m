function d = dot(rot1,rot2)
% compute minimum dot(o1,o2) modulo symmetry

d = abs(dot(quaternion(rot1),quaternion(rot2)));
