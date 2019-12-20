function sF = rotate_outer(sF, rot)
% rotate a function by a rotation
%
% Syntax
%   sF = sF.rotate(rot)
%
% Input
%  sF - @S2Fun
%  rot - @rotation
%
% Output 
%  sF - @S2Fun
%

sF = S2FunHandle(@(v) sF.eval(inv(rot).*v));

end
