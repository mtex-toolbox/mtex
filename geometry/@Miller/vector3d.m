function v = vector3d(m,cs)
% Miller-indece --> vector3d
%% Input
%  m - @Miller
%  cs - crystal symmetry (optional)
%
%% Output
%  v - @vector3d

if nargin == 1, cs = m(1).CS; end

a = getaxes(cs);
V  = dot(a(1),cross(a(2),a(3)));
aa = cross(a(2),a(3)) ./ V;
bb = cross(a(3),a(1)) ./ V;
cc = cross(a(1),a(2)) ./ V;

v = [m.h]*aa+[m.k]*bb+[m.l]*cc;
v = v ./ norm(v);
