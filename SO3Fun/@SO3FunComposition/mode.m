function value = mode(SO3F,varargin)
% Calculates the mode value of a SO3FunComposition
%
% Syntax
%   value = mode(SO3F)
%
% Input
%  SO3F - @SO3FunComposition
%
% Output
%  value - double
%

data = sum(cellfun(@(x) mean(x),SO3F.components,'UniformOutput',true));

if isalmostreal(data)
sortedData = sort(real(data));
uniqueValues = unique(sortedData);
counts = histc(sortedData, uniqueValues);
[~, idx] = max(counts);
value = uniqueValues(idx);
end

end
