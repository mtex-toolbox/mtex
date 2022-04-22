function sF = rdivide(sF1, sF2)
% overloads ./
%
% Syntax
%   sF = SO3F1 ./ SO3F2
%   sF = sF1 ./ a
%   sF = a ./ sF2
%
% Input
%  SO3F1, SO3F2 - @SO3Fun
%  a - double
%
% Output
%  SO3F - @SO3Fun
%

if isnumeric(sF1)
  sF = S2FunHandle(@(v) sF1./ sF2.eval(v));
  return
end

if isa(sF2,'S2FunHarmonic')
  f = @(v) sF1.eval(v)./sF2.eval(v);
  sF = S2FunHarmonic.quadrature(f);
  return
end

sF = times(sF1,1./sF2);

end