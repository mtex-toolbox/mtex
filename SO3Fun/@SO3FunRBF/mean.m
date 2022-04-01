function value = mean(SO3F, varargin)
% calculates the mean value for an univariate SO3Fun or calculates the mean
% along a specified dimension for a multimodal SO3Fun
%
% Syntax
%   value = mean(SO3F)
%   SO3F  = mean(SO3F, d)
%
% Input
%  SO3F - @SO3FunRBF
%
% Output
%  value - double
%

% TODO: mean along specific dimension
 
value = sum(SO3F.weights(:),varargin{:}) * SO3F.psi.A(1) + SO3F.c0;

end
