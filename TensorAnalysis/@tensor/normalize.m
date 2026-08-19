function t = normalize(t)
% mean stress
%
% Input
%  t - @tensor
%
% Output
%  t - @tensor
%

t = t ./ norm(t);
