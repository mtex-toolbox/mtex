function value = mode(sF, varargin)
% calculates the mode value for an univariate S2Fun or calculates the mode along a specified dimension fo a multimodal S2Fun
%
% Syntax
%   value = mode(sF)
%   sF = mode(sF, d)
%
% Input
%  sF - @S2FunHarmonic
%  d - dimension to take the mode value over
%
% Output
%  sF - S2FunHarmonic
%  value - double
%
% Description
%
% If sF is a 3x3 S2Fun then |mode(sF)| returns a 3x3 matrix with the mode
% values of each function mode(sF, 1) returns a 1x3 S2Fun wich contains the
% pointwise means values along the first dimension
%
 
nodes = quadratureS2Grid(256);

value = mode(sF.eval(nodes),1);

if isalmostreal(value,'componentwise')
  value = real(value);
end


end
