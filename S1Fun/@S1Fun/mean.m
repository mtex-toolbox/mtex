function value = mean(sF, varargin)
% mean value of a S1Fun or along a dimension of a vector-valued S1Fun
%
% $$ v = \frac{1}{2\pi} \int_{0}^{2\pi} f( o ) do $$
%
% Syntax
%   value = mean(sF)
%   value = mean(sF,'resolution',0.1*degree)
%   sF = mean(sF, d)
%
% Input
%  sF - @S1Fun
%  d  - dimension to take the mean value over
%
% Output
%  value - double
%  sF    - @S1Fun
%
% Options
%  resolution - spacing of the quadrature nodes, default 0.3 degree
%
% Description
%
% If sF is a 3x3 S1Fun then
% |mean(sF)| returns a 3x3 matrix with the mean values of each function
% |mean(sF, 1)| returns a 1x3 S1Fun which contains the pointwise mean values along the first dimension
%
% Example
%   % a scalar valued function
%   sF = S1FunHandle(@(o) sin(o).^2)
%   mean(sF)
%
%   % a vector valued function
%   sF = S1FunHandle(@(o) [sin(o).^2, cos(2*o).^2, 1+0*o])
%   mean(sF)
%   mean(sF,1)
%
% See also
% S1Fun/sum S1FunHarmonic/mean

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
