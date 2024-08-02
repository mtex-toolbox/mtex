function ensureCompatibleSymmetries(SO3F1,varargin)
% For calculating with @SO3Fun (+, -, .*, ./, conv, ...) we have to verify
% that the symmetries are suitable.
%
% By default the Left and Right symmetries of both functions have to
% coincide. By convolution of SO3Fun's the Left symmetry of one function
% have to coincide with the right symmetry of the other function.
%
% Evaluation of some SO3Fun in some orientation also needs suitable
% symmetries.
%
% Syntax
%   ensureCompatibleSymmetries(SO3F1,SO3F2)
%   ensureCompatibleSymmetries(SO3F1,sF)
%   ensureCompatibleSymmetries(SO3F1,ori)
%   ensureCompatibleSymmetries(SO3F1,SO3F2,'conv')
%   ensureCompatibleSymmetries(SO3F1,'antipodal')
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


if check_option(varargin,'antipodal')
  if SO3F1.CS ~= SO3F1.SS
    error('ODF can only be antipodal if both symmetries coincide!')
  end
  return
end

SO3F2 = varargin{1};

if isnumeric(SO3F1) || isnumeric(SO3F2) || ...
    (isa(SO3F1,'SO3FunRBF') && SO3F1.c0~=0 && isempty(SO3F1.weights)) || ...
    (isa(SO3F2,'SO3FunRBF') && SO3F2.c0~=0 && isempty(SO3F2.weights))
  return
end



% TODO: Currently only same symmetries are suitable.
%       Possibly use LaueGroups or properGroups
%       By changing that also update the code in SO3FunComposition.

if isa(SO3F2,'S2FunHarmonic')
  % compare symmetries in case of convolution with S2Fun
  if (isa(SO3F2,'S2FunHarmonicSym') && (SO3F1.SLeft ~= SO3F2.s)) || (~isa(SO3F2,'S2FunHarmonicSym') && (SO3F1.SLeft ~= specimenSymmetry))
    error('By convolution of a @SO3Fun with a @S2Fun the symmetries have to be compatible.')
  end
  return
end

if check_option(varargin,'conv_Left')
  % compare symmetries in case of left sided convolution
  em = SO3F1.SRight ~= SO3F2.SLeft;
else
  % compare all symmetrys in case of +, -, *, /, cat, subsasgn
  em = (SO3F1.CS ~= SO3F2.CS) || (SO3F1.SS ~= SO3F2.SS);
end


s = 'The symmetries are not compatible. (Calculations with @SO3Fun''s needs suitable symmetries.)';

% if check_option(varargin,'SO3VectorField')
%   s = 'The symmetries are not compatible. (Calculations with @SO3VectorField''s needs suitable symmetries.)';
% end

if isa(SO3F2,'orientation')
  s = 'The symmetries are not compatible. (Evaluating SO3Fun''s at orientations needs suitable symmetries.)';
end

if em
  error(s)
end

end