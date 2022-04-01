function value = mean(SO3F, varargin)
% calculates the mean value for an univariate SO3Fun or calculates the mean
% along a specified dimension of a multimodal SO3Fun
%
% Syntax
%   value = mean(SO3F)
%   SO3F = mean(SO3F, d)
%
% Input
%  SO3F - @SO3Fun
%  d - dimension to take the mean value over
%
% Output
%  SO3F  - @SO3Fun
%  value - double
%
% Description
%
% If SO3F is a 3x3 SO3Fun then |mean(SO3F)| returns a 3x3 matrix with the mean
% values of each function mean(SO3F, 1) returns a 1x3 SO3Fun which contains the
% pointwise means values along the first dimension
%

% TODO: mean along specific dimension

nodes = equispacedSO3Grid(SO3F.SRight,SO3F.SLeft,'resolution',2.5*degree,varargin{:});
value = mean(SO3F.eval(nodes(:)));

end
