function sF = le(sF1,sF2)
% overloads sF1 <= sF2
%
% Syntax
%   sF = sF1 <= sF2
%   sF = a <= sF1
%   sF = sF1 <= a
%
% Input
%  sF1, sF2 - S2FunHarmonic
%  a - double
%
% Output
%  sF - S2FunHarmonic
%

if isnumeric(sF1)
  f1 = @(v) sF1;
  N = 0;
else
  f1 = @(v) sF1.eval(v);
  N = sF1.bandwidth;
end

if isnumeric(sF2)
  f2 = @(v) sF2;
else
  f2 = @(v) sF2.eval(v);
  N = N + sF2.bandwidth;
end

sF = S2FunHarmonic.quadrature(@(v) f1(v) <= f2(v),'bandwidth',256);

end