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
%  d - dimension to take the mean value over
%
% Output
%  SO3F  - @SO3FunRBF
%  value - double
%
% Description
%
% If sF is a 3x3 SO3Fun then |mean(sF)| returns a 3x3 matrix with the mean
% values of each function mean(sF, 1) returns a 1x3 S2Fun wich contains the
% pointwise means values along the first dimension
%
 
value = sum(SO3F.weights,varargin{:}) * SO3F.psi.A(1);

end
