function sF = rotate_outer(sF, rot)
% rotate a function by a rotation
%
% Syntax
%   sF = sF.rotate_outer(rot)
%
% Input
%  sF - @S2FunHarmonic
%  rot - @rotation
%
% Output 
%  sF - @S2FunHarmonic
%

sF = rotate(sF, rot);

end
