function S = sym(T,varargin)
% the symmetric part S = 0.5(T + T.') of a tensor
%
% Syntax
%   S = sym(T)
%
% Input
%  T - @tensor
%
% Output
%  S - @tensor
%

switch  T.rank
  case 4
    error('not yet implemented!');
    m = tensor42(T.M,T.doubleConvention);
  case 3
    error('not yet implemented!');
    m = tensor32(T.M,T.doubleConvention);
  case 2
    S = 0.5*(T + T');
end
