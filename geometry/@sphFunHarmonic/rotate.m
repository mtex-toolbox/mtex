function sF = rotate(sF, rot)
% rotate a function by a rotation
%
% Syntax
%  sF = sF.rotate(rot)
%
% Input
%  sF - @sphFunHarmonic
%  rot - @rotation
%

f = @(v) sF.eval(v.rotate(rot));
sF = sphFunHarmonic.quadrature(f, 'M', sF.M);

end
