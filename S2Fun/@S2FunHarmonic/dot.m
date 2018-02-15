function d = dot(sF1, sF2)
% inner product 
%
% Syntax
%   sF = conv(sF, psi)
%   sF = conv(sF, A)
%
% Input
%  sF - @S2FunHarmonic
%  psi - @kernel
%  A - double - list of Legendre coeficients
%
% Output
%   sF - @S2FunHarmonic
%

bw = min(sF1.bandwidth,sF2.bandwidth);

sF1.bandwidth = bw;
sF2.bandwidth = bw;
sF2 = conj(sF2);

d = sum(sF1.fhat .* sF2.fhat);

end
