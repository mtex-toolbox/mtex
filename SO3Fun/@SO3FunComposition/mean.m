function value = mean(SO3F,varargin)
% Calculates the mean value of a SO3FunComposition
%
% Syntax
%   value = mean(SO3F)
%
% Input
%  SO3F - @SO3FunComposition
%
% Output
%  value - double
%

value = sum(cellfun(@(x) mean(x),SO3F.components,'UniformOutput',true));
if isalmostreal(value)
  value = real(value);
end

end