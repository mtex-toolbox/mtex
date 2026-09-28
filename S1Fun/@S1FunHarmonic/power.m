function sF = power(sF1,sF2,varargin)
%
% Syntax
%   sF = sF1.^a
%

if isnumeric(sF1)
  f = @(v) sF1 .^ eval(sF2, v);
elseif isnumeric(sF2)
  f = @(v) eval(sF1, v) .^ sF2;
else
  f = @(v) eval(sF1, v) .^ eval(sF2, v);
end

% an integer power of sF1 has sF2 times its bandwidth, the others none
if isnumeric(sF2) && isscalar(sF2) && sF2 >= 0 && sF2 == round(sF2)
  bw = min(sF1.bandwidth * sF2, getMTEXpref('maxS1Bandwidth'));
else
  bw = getMTEXpref('maxS1Bandwidth');
end
sF = S1FunHarmonic.quadrature(f,'bandwidth',get_option(varargin,'bandwidth',bw));

end
