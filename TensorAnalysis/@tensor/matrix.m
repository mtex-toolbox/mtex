function m = matrix(T,varargin)
% return tensor as a matrix
%
% Syntax
%   m = matrix(T)
%   m = matrix(T,'Voigt')
%   m = matrix(T,'Kelvin')
%
% Input
%  T - @tensor
%
% Output
%  m - matrix
%
% Options
%  Voigt - give a 4 rank tensor in Voigt notation, i.e. as a 6 x 6 matrix
%  Kelvin - same as above but with Kelvin normalization
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
elseif check_option(varargin,'Kelvin')
  m = tensor42(T.M,2);
else
  m= T.M;
end



