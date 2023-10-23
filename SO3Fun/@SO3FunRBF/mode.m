function value = mode(SO3F, varargin)
% calculates the mode value for an SO3FunRBF
%
% Syntax
%   value = mode(SO3F)
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
uniqueValues = unique(sortedData);
counts = histc(sortedData, uniqueValues);
[~, idx] = max(counts);
value = uniqueValues(idx);
end

end