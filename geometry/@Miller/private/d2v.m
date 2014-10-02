function vv = d2v(u,v,w,cs)
% direction to  cartesian coordinates
% Input
%  u,w,v - 
%  cs - crystal symmetry (optional)
%
% Output
%  v - @vector3d

if any(u == 0 & v == 0 & w ==0)
  error('(0,0,0) is not a valid Miller index');
end

% direct space
vv = u * cs.axes(1) + v * cs.axes(2) + w * cs.axes(3);
