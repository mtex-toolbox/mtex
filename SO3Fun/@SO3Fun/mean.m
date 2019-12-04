function value = mean(SO3F, varargin)
% calculates the mean value for an univariate SO3Fun or calculates the mean
% along a specified dimension fo a multimodal SO3Fun
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
% If sF is a 3x3 S2Fun then |mean(sF)| returns a 3x3 matrix with the mean
% values of each function mean(sF, 1) returns a 1x3 S2Fun wich contains the
% pointwise means values along the first dimension
%
 
nodes = equispacedSO3Grid(SO3F.SRight, SO3F.SLeft,'resolution',2.5*degree);

value = mean(SO3F.eval(nodes),1);  

end
