function sF = rotate(sF, rot)
% rotate a function by a rotation
%
% Syntax
%   sF = sF.rotate(rot)
%
% Input
%  sF - @S2FunHarmonic
%  rot - @rotation
%
% Output 
%  sF - @S2FunHarmonic
%

if sF.bandwidth ~= 0
  f = @(v) sF.eval(rotate(v, inv(rot)));
  sF = S2FunHarmonic.quadrature(f, 'bandwidth', sF.bandwidth);
end

end
