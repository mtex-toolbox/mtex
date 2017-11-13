function f = eval(sVF,v)
%
% syntax
%  f = eval(sF,v)
%
% Input
%  v - interpolation nodes
%
% Output
%

v = v(:);

f = vector3d(sVF.sF_x.eval(v), sVF.sF_y.eval(v), sVF.sF_z.eval(v));

end
