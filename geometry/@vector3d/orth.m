function ov = orth(v)
% an arbitrary orthogonal vector
%
% convention:
% (x,y,z) -> (-y,x,0)
% (0,y,z) -> (1,0,0)

v.y(isnull(v.x)) = -1;
ov = vector3d(-v.y,v.x,zeros(size(v)));
ov = normalize(ov);
