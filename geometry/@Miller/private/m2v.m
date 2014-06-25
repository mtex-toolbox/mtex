function v = m2v(h,k,l,cs)
% Miller-indece --> cartesian coordinates
% Input
%  h,k,l - 
%  cs - crystal symmetry (optional)
%
% Output
%  v - @vector3d

if any(h == 0 & k == 0 & l ==0)
  error('(0,0,0) is not a valid Miller index');
end

a = cs.axes;
V  = dot(a(1),cross(a(2),a(3)));
a_star = cross(a(2),a(3)) ./ V;
b_star = cross(a(3),a(1)) ./ V;
c_star = cross(a(1),a(2)) ./ V;

% reciprocal space
v = h * a_star + k * b_star + l * c_star;
% v = v ./ norm(v);
