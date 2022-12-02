function value = mean(SO3F,varargin)
% Calculates the mean value of a SO3FunBingham
%
% Syntax
%   value = mean(SO3F)
%
% Input
%  SO3F - @SO3FunBingham
%
% Output
%  value - double

value = SO3F.weight;
if isalmostreal(value)
  value = real(value);
end

end