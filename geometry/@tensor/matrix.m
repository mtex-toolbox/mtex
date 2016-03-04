function m = matrix(T,varargin)
% return tensor as a matrix
%
% Syntax
%   m = matrix(T)
%   m = matrix(T,'voigt')
%
% Input
%  T - @tensor
%
% Output
%  m - matrix
%
% Options
%  voigt - give a 4 rank tensor in voigt notation, i.e. as a 6 x 6 matrix
%
% See also
%

if check_option(varargin,{'compact','voigt'})
  switch  T.rank
    case 4
      m = tensor42(T.M,T.doubleConvention);
    case 3
      m = tensor32(T.M,T.doubleConvention);
  end
  return
end

m= T.M;

