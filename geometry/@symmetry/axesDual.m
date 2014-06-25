function vec = axesDual(cs)
% get dual coordinate axes

abc = cs.axes;
V  = dot(abc(1),cross(abc(2),abc(3)));
vec(1) = cross(abc(2),abc(3)) ./ V;
vec(2) = cross(abc(3),abc(1)) ./ V;
vec(3) = cross(abc(1),abc(2)) ./ V;
