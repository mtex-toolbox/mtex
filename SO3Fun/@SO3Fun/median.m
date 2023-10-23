function value = median(SO3F, varargin)
% Calculates the median value of a SO3Fun or calculates the median
% along a specified dimension of a vector-valued SO3Fun
%
% Syntax
%   value = median(SO3F)
%   SO3F = median(SO3F, d)
%
% Input
%  SO3F - @SO3Fun
%  d - dimension to take the median value over
%
% Output
%  SO3F  - @SO3Fun
%  value - double
%
% Description
%
% If SO3F is a 3x3 SO3Fun then 
% |median(SO3F)| returns a 3x3 matrix with the median values of each function 
% |median(SO3F, 1)| returns a 1x3 SO3Fun which contains the pointwise median values along the first dimension
%
% Example 
%   %generate SO3Funs
%   SO3F1 = SO3Fun.dubna
%   SO3F2 = SO3FunHandle(@(rot) SO3F1.eval(rot))
%   A = ones(2,3);
%   SO3F3 = SO3F2.*A
% 
%   %calculate median values of SO3Funs
%   median(SO3F2)
%   median(SO3F3)
%   median(SO3F3,2)
%   median(SO3F3,1)
%


% median along specific dimension
if nargin>1 && isnumeric(varargin{1})
  value = SO3FunHandle(@(rot) median(SO3F.eval(rot),varargin{1}+1),SO3F.SRight,SO3F.SLeft);
  return
end

% median value of a SO3Fun
res = get_option(varargin,'resolution',2.5*degree);
nodes = equispacedSO3Grid(SO3F.SRight,SO3F.SLeft,'resolution',res);
value = median(SO3F.eval(nodes(:)));
value = reshape(value,size(SO3F));
if isalmostreal(value,'componentwise')
  value = real(value);
end

end
