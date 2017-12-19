function sF = rotate(sF, rot)
% rotate a function by a rotation
%
% Syntax
%  sF = sF.rotate(rot)
%
% Input
%  sF - @S2FunHarmonic
%  rot - @rotation
%

if sF.M ~= 0
  f = @(v) sF.eval(v.rotate(rot));
  sF = S2FunHarmonic.quadrature(f, 'M', sF.M);
end

end
