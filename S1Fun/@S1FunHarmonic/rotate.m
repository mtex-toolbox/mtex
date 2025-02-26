function S1F = rotate(S1F,omega)
% rotate a S1FunHarmonic by an angle
%
% Syntax
%   S1F = S1F.rotate(omega)
%
% Input
%  S1F   - @S1FunHarmonic
%  omega - double
%
% Output 
%  S1F   - @S1FunHarmonic
%

if S1F.bandwidth ~= 0
  f = @(v) S1F.eval(mod(v+omega,2*pi));
  S1F = S1FunHarmonic.quadrature(f, 'bandwidth', S1F.bandwidth);
end

end