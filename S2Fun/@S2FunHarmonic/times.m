function sF = times(sF1,sF2)
% overloads sF1 .* sF2
%
% Syntax
%   sF = sF1.*sF2
%   sF = a.*sF1
%   sF = sF1.*a
%
% Input
%  sF1, sF2 - S2FunHarmonic
%
% Output
%  sF - S2FunHarmonic
%

if isnumeric(sF1) 
  sF = sF2;
  sF.fhat = sF.fhat*sF1;
elseif isnumeric(sF2)
  sF = sF1;
  sF.fhat = sF.fhat*sF2;
elseif isa(sF2,'S2Fun')
  f = @(v) sF1.eval(v) .* sF2.eval(v);
  sF = S2FunHarmonic.quadrature(f, 'bandwidth', min(getMTEXpref('maxBandwidth'),sF1.bandwidth + sF2.bandwidth));
else
  sF = sF2.*sF1
end

end
