function f = eval(sVF,v)
%
% syntax
%   f = eval(sVF,v)
%
% Input
%   v - @vector3d interpolation nodes
%
% Output
%   f - @vector3d
%

f = vector3d(real(sVF.sF.eval(v)'));
f = f';

end
