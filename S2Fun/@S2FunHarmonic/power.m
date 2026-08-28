function sF = power(sF1,sF2)
%
% Syntax
%   sF = sF1.^a
%

% the symmetry both sides share survives the power
sym = S2Fun.jointSym(sF1,sF2);

if isnumeric(sF1)
  f = @(v) sF1 .^ eval(sF2, v);
  
  bw = sF1 * sF2.bandwidth;
  sF = S2FunHarmonic.quadrature(f,'bandwidth',min(bw,256),sF2.frame);
elseif isnumeric(sF2)
  f = @(v) eval(sF1, v) .^ sF2;
  
  bw = sF1.bandwidth * sF2;
  sF = S2FunHarmonic.quadrature(f,'bandwidth',min(bw,256),sF1.frame);
else
  f = @(v) eval(sF1, v) .^ eval(sF2, v);
  
  bw = max(sF1.bandwidth, sF2.bandwidth);
  sF = S2FunHarmonic.quadrature(f,'bandwidth',min(bw,256),sF2.frame);
end

if ~isempty(sym), sF = S2FunHarmonicSym(sF.fhat,sym); end

end
