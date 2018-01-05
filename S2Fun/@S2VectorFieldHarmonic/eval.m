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

f = vector3d(sVF.sF.eval(v)');
f = f';

end
