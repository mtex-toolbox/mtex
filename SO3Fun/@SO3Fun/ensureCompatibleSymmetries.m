function ensureCompatibleSymmetries(SO3F1,SO3F2,varargin)
% For calculating with @SO3Fun (+, -, .*, ./, conv, ...) we have to verify
% that the symmetries are suitable.
%
% By default the Left and Right symmetries of both functions have to
% coincide. By convolution of SO3Fun's the Left symmetry of one function
% have to coincide with the right symmetry of the oter function.
%
% Syntax
%   ensureCompatibleSymmetries(SO3F1,SO3F2)
%   ensureCompatibleSymmetries(SO3F1,SO3F2,'conv')
%
% Input
%  SO3F1, SO3F2 - @SO3Fun
%
% Output
%  msg - yields a error message if the symmetry do not match
%
% Options
%  conv - be shure switched symmetries match
%

if check_option(varargin,'conv')
  sym = SO3F1.SRight;
  SO3F1.SRight = SO3F1.SLeft;
  SO3F1.SLeft = sym;
end

if (SO3F1.SRight ~= SO3F2.SRight) || (SO3F1.SLeft ~= SO3F2.SLeft)
  error('Calculations with @SO3Fun''s are not supported if the symmetries are not compatible.')
end

end