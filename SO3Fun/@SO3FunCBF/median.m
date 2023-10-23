function value = median(SO3F, varargin)
% Calculates the median value of a fibre SO3Fun
%
% Syntax
%   value = median(SO3F)
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
n = numel(sortedData);
if mod(n, 2) == 0
    value = (sortedData(n/2) + sortedData(n/2 + 1)) / 2;
else
    value = sortedData((n + 1) / 2);
end
end

end
