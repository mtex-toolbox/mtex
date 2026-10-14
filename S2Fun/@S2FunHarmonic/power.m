function sF = power(sF1,sF2)
% pointwise power of a spherical function
%
% Syntax
%
%   sF = sF1.^a     % the function to the power a
%   sF = a.^sF1     % a to the power of the function
%   sF = sF1.^sF2   % pointwise power of two functions
%
% Input
%  sF1, sF2 - @S2FunHarmonic
%  a        - double
%
% Output
%  sF - @S2FunHarmonic
%

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

end
