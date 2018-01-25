function sF = power(sF1,sF2)
%
% Syntax
%   sF = sF1.^a
%

if isnumeric(sF1)
  f = @(v) sF1 .^ eval(sF2, v);
  
  bw = sF1 * sF2.bandwidth;
  sF = S2FunHarmonic.quadrature(f,'bandwidth',min(bw,256));
elseif isnumeric(sF2)
  f = @(v) eval(sF1, v) .^ sF2;
  
  bw = sF1.bandwidth * sF2;
  sF = S2FunHarmonic.quadrature(f,'bandwidth',min(bw,256));
else
  f = @(v) eval(sF1, v) .^ eval(sF2, v);
  
  bw = max(sF1.bandwidth, sF2.bandwidth);
  sF = S2FunHarmonic.quadrature(f,'bandwidth',min(bw,256));
end

end
