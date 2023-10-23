function value = mode(SO3F,varargin)
% Calculates the mode value of a SO3FunBingham
%
% Syntax
%   value = mode(SO3F)
%
% Input
%  SO3F - @SO3FunBingham
%
% Output
%  value - double

data = SO3F.weight;

if isalmostreal(data)
sortedData = sort(real(data));
uniqueValues = unique(sortedData);
counts = histc(sortedData, uniqueValues);
[~, idx] = max(counts);
value = uniqueValues(idx);
end

end