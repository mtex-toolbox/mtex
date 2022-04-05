function value = mean(SO3F, varargin)
% Calculates the mean value of a fibre SO3Fun or calculates the mean along
% a specified dimension for a vector-valued SO3Fun.
%
% Syntax
%   value = mean(SO3F)
%   SO3F  = mean(SO3F, d)
%
% Input
%  SO3F - @SO3FunCBF
%  d - dimension to take the mean value over
%
% Output
%  SO3F  - @SO3FunCBF
%  value - double
%
% Description
%
% If SO3F is a 3x3 SO3Fun then 
% |mean(SO3F)| returns a 3x3 matrix with the mean values of each function 
% |mean(SO3F,1)| returns a 1x3 SO3Fun wich contains the pointwise mean values along the first dimension
%

% TODO: mean along specific dimension
 
value = sum(SO3F.weights,varargin{:}) * SO3F.psi.A(1);

end
