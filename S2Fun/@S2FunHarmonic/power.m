function sF = power(sF1,sF2,varargin)
%
% Syntax
%   sF = sF1.^a
%   sF = power(sF1,a,'bandwidth',bw)
%

if isnumeric(sF1)
  f = @(v) sF1 .^ eval(sF2, v); fr = sF2.frame;
elseif isnumeric(sF2)
  f = @(v) eval(sF1, v) .^ sF2; fr = sF1.frame;
else
  f = @(v) eval(sF1, v) .^ eval(sF2, v); fr = sF2.frame;
end

% an integer power of sF1 has sF2 times its bandwidth, the others none
bw = getMTEXpref('defaultS2Bandwidth');
if isnumeric(sF2) && isscalar(sF2) && sF2 >= 0 && sF2 == round(sF2)
  bw = min(sF1.bandwidth * sF2, getMTEXpref('maxS2Bandwidth'));
end
sF = S2FunHarmonic.quadrature(f,'bandwidth',get_option(varargin,'bandwidth',bw),fr);

end
