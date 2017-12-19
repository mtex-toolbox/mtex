function sF = power(sF1,sF2)
%
% Syntax
%  sF = sF1^a
%

if isnumeric(sF1)
  warning('not yet implemented');
elseif isnumeric(sF2)
  f = @(v) sF1.eval(v).^sF2;
  sF = S2FunHarmonic.quadrature(f);
else
  warning('not yet implemented');
end

end
