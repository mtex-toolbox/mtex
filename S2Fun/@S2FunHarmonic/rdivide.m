function sF = rdivide(sF1, sF2)
%
% Syntax
%   sF = sF1/sF2
%   sF = sF1/a
%   sF = a/sF1
%
% Input
%  sF1, sF2 - @S2FunHarmonic
%  a - double
%
% Output
%  sF - @S2FunHarmonic
%

% the quotient is symmetric only under what both sides share
if isnumeric(sF1)
  f = @(v) sF1./sF2.eval(v);
  sF = S2FunHarmonic.quadrature(f,S2Fun.jointFrame(sF1,sF2,sF2.frame));
elseif isnumeric(sF2)
  sF = sF1.*(1./sF2);
else
  f = @(v) sF1.eval(v)./sF2.eval(v);
  sF = S2FunHarmonic.quadrature(f,S2Fun.jointFrame(sF1,sF2,sF2.frame));
end

end
