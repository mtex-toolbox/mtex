function vv = d2v(u,v,w,cs)
% direction to  cartesian coordinates
%% Input
%  u,w,v - 
%  cs - crystal symmetry (optional)
%
%% Output
%  v - @vector3d

if any(u == 0 & v == 0 & w ==0)
  error('(0,0,0) is not a valid Miller index');
end

a = get(cs,'axis');

% direct space
vv = u * a(1) + v * a(2) + w * a(3);
% vv = vv ./ norm(vv);
