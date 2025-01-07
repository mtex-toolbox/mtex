function value = mean(sF, varargin)
% Calculates the mean value of a SO3Fun or calculates the mean
% along a specified dimension of a vector-valued SO3Fun
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
% If SO3F is a 3x3 SO3Fun then 
% |mean(SO3F)| returns a 3x3 matrix with the mean values of each function 
% |mean(SO3F, 1)| returns a 1x3 SO3Fun which contains the pointwise mean values along the first dimension
%
% Example 
%   %generate SO3Funs
%   SO3F1 = SO3Fun.dubna
%   SO3F2 = SO3FunHandle(@(rot) SO3F1.eval(rot))
%   A = ones(2,3);
%   SO3F3 = SO3F2.*A
% 
%   %calculate mean values of SO3Funs
%   mean(SO3F2)
%   mean(SO3F3)
%   mean(SO3F3,2)
%   mean(SO3F3,1)
%


% mean along specific dimension
if nargin>1 && isnumeric(varargin{1})
  value = S1FunHandle(@(o) mean(sF.eval(o),varargin{1}+1));
  return
end

% mean value of a S1Fun
res = get_option(varargin,'resolution',0.3*degree);
nodes = (0:round(2*pi/res)-1)/round(2*pi/res)*2*pi;
value = mean(sF.eval(nodes(:)));
value = reshape(value,size(sF));
if isalmostreal(value,'componentwise')
  value = real(value);
end

end
