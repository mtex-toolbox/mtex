function vec = axesDual(cs)
% return dual coordinate axes

a = cs.axes.subSet(1);
b = cs.axes.subSet(2);
c = cs.axes.subSet(3);
bc = cross(b,c);
V  = dot(a,bc);
vec(1) = bc ./ V;
vec(2) = cross(c,a) ./ V;
vec(3) = cross(a,b) ./ V;
