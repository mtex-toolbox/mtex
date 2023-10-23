function value = median(SO3F,varargin)
% Calculates the median value of a SO3FunBingham
%
% Syntax
%   value = median(SO3F)
%
% Input
%  SO3F - @SO3FunBingham
%
% Output
%  value - double

data = SO3F.weight;

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