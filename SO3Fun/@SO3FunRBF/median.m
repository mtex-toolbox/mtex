function value = median(SO3F, varargin)
% calculates the median value for an SO3FunRBF
%
% Syntax
%   value = median(SO3F)
%
% Input
%  SO3F - @SO3FunRBF
%
% Output
%  value - double
%

data = sum(SO3F.weights(:)) * SO3F.psi.A(1) + SO3F.c0;

if isalmostreal(data)
sortedData = sort(real(data));
n = numel(sortedData);
if mod(n, 2) == 0
    value = (sortedData(n/2) + sortedData(n/2 + 1)) / 2;
else
    value = sortedData((n + 1) / 2);
end
end

end