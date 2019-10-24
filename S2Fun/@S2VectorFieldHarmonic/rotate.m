function sVF = rotate(sVF, rot)
% rotate a function by a rotation
%
% Syntax
%   sVF = sVF.rotate(rot)
%
% Input
%  sVF - @S2VectorFieldHarmonic
%  rot - @rotation
%
% Output
%   sVF - @S2VectorFieldHarmonic
%

sVF.sF = rotate(sVF.sF, rot);

end
