function value = mean(SO3F, varargin)
% Calculates the mean value of a fibre SO3Fun
%
% Syntax
%   value = mean(SO3F)
%
% Input
%  SO3F - @SO3FunCBF
%
% Output
%  value - double
%
 
value = sum(SO3F.weights,1) * SO3F.psi.A(1);
if isalmostreal(value)
  value = real(value);
end

end
