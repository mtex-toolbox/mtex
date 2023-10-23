function value = mode(SO3F, varargin)
% Calculates the mode value of a fibre SO3Fun
%
% Syntax
%   value = mode(SO3F)
%
% Input
%  SO3F - @SO3FunCBF
%
% Output
%  value - double
%

data = SO3F.weights * SO3F.psi.A(1);

if isalmostreal(data)
sortedData = sort(real(data));
uniqueValues = unique(sortedData);
counts = histc(sortedData, uniqueValues);
[~, idx] = max(counts);
value = uniqueValues(idx);
end

end