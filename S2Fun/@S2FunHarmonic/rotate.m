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

if sF.bandwidth ~= 0
  f = @(v) sF.eval(v.rotate(rot));
  sF = S2FunHarmonic.quadrature(f, 'bandwidth', sF.bandwidth);
end

end
