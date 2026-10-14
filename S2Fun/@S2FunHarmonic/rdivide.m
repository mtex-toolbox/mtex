function sF = rdivide(sF1, sF2)
% pointwise division of spherical functions
%
% Syntax
%
%   sF = sF1./sF2 % quotient of two functions
%   sF = sF1./a   % function divided by a number
%   sF = a./sF1   % number divided by a function
%
% Input
%  sF1, sF2 - @S2FunHarmonic
%  a - double
%
% Output
%  sF - @S2FunHarmonic
%

if isnumeric(sF1)
  f = @(v) sF1./sF2.eval(v);
  sF = S2FunHarmonic.quadrature(f,sF2.frame);
elseif isnumeric(sF2)
  sF = sF1.*(1./sF2);
else
  f = @(v) sF1.eval(v)./sF2.eval(v);
  sF = S2FunHarmonic.quadrature(f,sF2.frame);
end

end
