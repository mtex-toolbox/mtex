function sigma = normalize(sigma)
% mean stress
%
% Input
%  sigma - @stressTensor
%
% Output
%  sigma - @stressTensor
%

sigma = sigma ./ norm(sigma);
