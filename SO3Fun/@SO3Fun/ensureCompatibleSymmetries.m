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
%   ensureCompatibleSymmetries(SO3F1,sF)
%   ensureCompatibleSymmetries(SO3F1,ori)
%   ensureCompatibleSymmetries(SO3F1,SO3F2,'conv')
%
% Input
%  SO3F1, SO3F2 - @SO3Fun
%  sF - @S2FunHarmonicSym
%  ori - @orientation
%
% Output
%  msg - yields a error message if the symmetry do not match
%
% Options
%  conv - be shure switched symmetries match
%


if isnumeric(SO3F1) || isnumeric(SO3F2) || ...
    (isa(SO3F1,'SO3FunRBF') && SO3F1.c0~=0 && isempty(SO3F1.weights)) || ...
    (isa(SO3F2,'SO3FunRBF') && SO3F2.c0~=0 && isempty(SO3F2.weights))
  return
end



% TODO: Currently only same symmetries are suitable.
%       Possibly use LaueGroups or properGroups
%       By changing that also update the code in SO3FunComposition.

if isa(SO3F2,'S2FunHarmonicSym')
  % compare symmetries in case of convolution with S2Fun
  if SO3F1.SRight ~= SO3F2.s
    error('By convolution of a @SO3Fun with a @S2Fun the symmetries have to be compatible.')
  end
  return
end

if check_option(varargin,'conv_Left')
  % compare symmetries in case of left sided convolution
  em = SO3F1.SRight ~= SO3F2.SLeft;
else
  % compare all symmetrys in case of +, -, *, /, cat, subsasgn
  em = (SO3F1.SRight ~= SO3F2.SRight) || (SO3F1.SLeft ~= SO3F2.SLeft);
end


% error message
if em
  error('Calculations with @SO3Fun''s are not supported if the symmetries are not compatible.')
end

end