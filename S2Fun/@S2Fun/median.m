function value = median(sF, varargin)
% calculates the median value for an univariate S2Fun or calculates the median along a specified dimension fo a multimodal S2Fun
%
% Syntax
%   value = median(sF)
%   sF = median(sF, d)
%
% Input
%  sF - @S2FunHarmonic
%  d - dimension to take the median value over
%
% Output
%  sF - S2FunHarmonic
%  value - double
%
% Description
%
% If sF is a 3x3 S2Fun then |median(sF)| returns a 3x3 matrix with the median
% values of each function median(sF, 1) returns a 1x3 S2Fun wich contains the
% pointwise means values along the first dimension
%
 
nodes = quadratureS2Grid(256);

value = median(sF.eval(nodes),1);

if isalmostreal(value,'componentwise')
  value = real(value);
end


end
