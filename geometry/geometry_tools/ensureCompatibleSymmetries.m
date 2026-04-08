function ensureCompatibleSymmetries(obj1,varargin)
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
%   ensureCompatibleSymmetries(v1,v2)
%
% Input
%  SO3F1, SO3F2 - @SO3Fun
%  sF - @S2FunHarmonicSym
%  ori - @orientation
%  v1,v2 - @SO3TangentVector, @SO3VectorField
%
% Output
%  msg - yields a error message if the symmetry do not match
%
% Options
%  conv - be shure switched symmetries match
%


% check necessary symmetry condition for antipodal
if check_option(varargin,'antipodal')
  if obj1.CS ~= obj1.SS
    error('ODF can only be antipodal if both symmetries coincide!')
  end
  return
end

% load 2nd object
obj2 = varargin{1};

% constant SO3FunRBF's
if isnumeric(obj1) || isnumeric(obj2)
  return
elseif (isa(obj1,'SO3FunRBF') && all(obj1.c0(:)~=0) && isempty(obj1.weights)) || ...
       (isa(obj2,'SO3FunRBF') && all(obj2.c0(:)~=0) && isempty(obj2.weights))
  return
end


% compare symmetries in case of convolution of SO3Fun with S2Fun
if isa(obj1,'SO3Fun') && isa(obj2,'S2Fun')
  if (isa(obj2,'S2FunHarmonicSym') && (obj1.SLeft ~= obj2.s)) || (~isa(obj2,'S2FunHarmonicSym') && (obj1.SLeft ~= specimenSymmetry))
    error('When convoluting @SO3Fun''s the symmetries have to be compatible.')
  end
  return
end

% compare symmetries in case of convolution of SO3Funs
if check_option(varargin,'conv') && obj1.SRight ~= obj2.SLeft
  error('When convoluting @SO3Fun''s the symmetries have to be compatible.')
end

% check symmetries for all other cases
if isa(obj1,'SO3VectorField') || isa(obj1,'SO3TangentVector')
  obj1 = SO3FunHarmonic(1,obj1.hiddenCS,obj1.hiddenSS);
  obj2 = SO3FunHarmonic(1,obj2.hiddenCS,obj2.hiddenSS);
  s = 'The symmetries are not compatible. (Calculations with @SO3TangentVector''s and @SO3VectorField''s needs suitable intern symmetries.)';
elseif isa(obj1,'SO3Fun') && isa(obj2,'SO3Fun')
  s = 'The symmetries are not compatible. (Calculations with @SO3Fun''s needs suitable symmetries.)';
elseif isa(obj1,'SO3Fun') && isa(obj2,'orientation')
  s = 'The symmetries are not compatible. (Evaluating SO3Fun''s at orientations needs suitable symmetries.)';
end


% TODO: Currently only same symmetries are suitable.
%       Possibly use LaueGroups or properGroups
%       By changing that also update the code in SO3FunComposition.

em = (obj1.CS ~= obj2.CS) || (obj1.SS ~= obj2.SS);
if em
  error(s)
end

end