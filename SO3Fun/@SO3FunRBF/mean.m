function value = mean(SO3F, varargin)
% calculates the mean value for an SO3FunRBF
%
% Syntax
%   value = mean(SO3F)
%
% Input
%  SO3F - @SO3FunRBF
%
% Output
%  value - double
%

value = sum(SO3F.weights(:)) * SO3F.psi.A(1) + SO3F.c0;
if isalmostreal(value)
  value = real(value);
end

end
