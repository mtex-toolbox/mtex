function sF = rdivide(sF1, sF2)
% pointwise division of functions on the circle
%
% Syntax
%
%   sF = sF1 ./ sF2   % the quotient of two functions
%   sF = sF1 ./ a     % divide by the number a
%   sF = a ./ sF1     % the quotient of a number and a function
%
% Input
%  sF1, sF2 - @S1FunHarmonic
%  a - double
%
% Output
%  sF - @S1FunHarmonic

if isnumeric(sF1)
  f = @(v) sF1./sF2.eval(v);
  sF = S1FunHarmonic.quadrature(f);
elseif isnumeric(sF2)
  sF = sF1.*(1./sF2);
else
  f = @(v) sF1.eval(v)./sF2.eval(v);
  sF = S1FunHarmonic.quadrature(f);
end

end
