function A = antiSym(T,varargin)
% the antisymmetric part A = 0.5(T - T.') of a tensor
%
% Syntax
%   A = antiSym(T)
%
% Input
%  T - @tensor
%
% Output
%  A - @tensor
%

switch  T.rank
  case 4
    error('not yet implemented!');
    m = tensor42(T.M,T.doubleConvention);
  case 3
    error('not yet implemented!');
    m = tensor32(T.M,T.doubleConvention);
  case 2
    A = 0.5*(T - T');
  otherwise
      error('Tensor should be of rank 2')
end
