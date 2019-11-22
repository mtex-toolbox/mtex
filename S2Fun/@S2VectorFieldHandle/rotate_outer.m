function sF = rotate_outer(sF, rot)
% rotate a function by a rotation
%
% Syntax
%   sF = sF.rotate_outer(rot)
%
% Input
%  sF - @S2FunHandle
%  rot - @rotation
%
% Output 
%  sF - @S2FunHandle
%

sF.fun = @(v) sF.fun(inv(rot)*v);

end
