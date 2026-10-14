function sF = power(sF1,sF2)
% pointwise power of a function on the circle
%
% Syntax
%
%   sF = sF1.^a     % the function to the power a
%   sF = a.^sF1     % a to the power of the function
%   sF = sF1.^sF2   % pointwise power of two functions
%
% Input
%  sF1, sF2 - @S1FunHarmonic
%  a        - double
%
% Output
%  sF - @S1FunHarmonic
%

if isnumeric(sF1)
  f = @(v) sF1 .^ eval(sF2, v);
  bw = sF1 * sF2.bandwidth;
elseif isnumeric(sF2)
  f = @(v) eval(sF1, v) .^ sF2;
  bw = sF1.bandwidth * sF2;
else
  f = @(v) eval(sF1, v) .^ eval(sF2, v);
  bw = max(sF1.bandwidth, sF2.bandwidth);
end

sF = S1FunHarmonic.quadrature(f,'bandwidth',min(bw,getMTEXpref('maxS1Bandwidth')));

end
