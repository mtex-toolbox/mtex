function d = dot(sF1, sF2)
% inner product 
%
% Syntax
%   sF = dot(sF1, sF1)
%
% Input
%  sF1, sF2   - @S2FunHarmonic
%
% Output
%  sF - @S2FunHarmonic
%

bw = min(sF1.bandwidth,sF2.bandwidth);

sF1.bandwidth = bw;
sF2.bandwidth = bw;

d = sum(sF1.fhat .* conj(sF2.fhat));

end
