function v = m2v(h,k,l,cs)
% Miller-indece --> cartesian coordinates
%% Input
%  h,k,l - 
%  cs - crystal symmetry (optional)
%
%% Output
%  v - @vector3d

a = get(cs,'axis');
V  = dot(a(1),cross(a(2),a(3)));
aa = cross(a(2),a(3)) ./ V;
bb = cross(a(3),a(1)) ./ V;
cc = cross(a(1),a(2)) ./ V;

v = h * aa + k * bb + l * cc;
v = v ./ norm(v);
