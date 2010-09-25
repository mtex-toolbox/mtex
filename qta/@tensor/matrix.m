function m= matrix(T,varargin)
% return tensor as a matrix
%
%% Syntax
% m = matrix(T)
% m = matrix('voigt')
%
%% Input
%  T - @tensor
%
%% Output
%  m - matrix
%
%% Options
%  voigt - give a 4 rank tensor in voigt notation, i.e. as a 6 x 6 matrix
%
%% See also
%

if T.rank == 4 && check_option(varargin,'voigt')
  m = tensor42(T.M);
else
  m = T.M;
end
