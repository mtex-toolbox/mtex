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
%   ensureCompatibleSymmetries(sF1,sF2)
%   ensureCompatibleSymmetries(v1,v2)
%
% Input
%  SO3F1, SO3F2 - @SO3Fun
%  sF, sF1, sF2 - @S2Fun
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
  if ~symFits(obj1.CS,obj1.SS)
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
  if isa(obj2,'S2FunHarmonicSym')
    ok = symFits(obj1.SLeft,obj2.s);
  else
    % a plain S2Fun carries at most a frame, so the left side has to be group free
    ok = obj1.SLeft.Laue.id == 2;
    if ok, ok = framesFit(obj2.frame,obj1.SLeft); end
  end
  if ~ok
    error('When convoluting @SO3Fun''s the symmetries have to be compatible.')
  end
  return
end

% two spherical functions - what always has to fit is the frame they are expressed in
if isa(obj1,'S2Fun') && isa(obj2,'S2Fun')
  s1 = getSym(obj1); s2 = getSym(obj2);
  ok = isempty(s1) || isempty(s2) || symFits(s1,s2);
  if ok, ok = framesFit(obj1.frame,obj2.frame); end
  if ~ok
    error('The symmetries are not compatible. (Calculations with @S2Fun''s need suitable symmetries.)')
  end
  return
end

% compare symmetries in case of convolution of SO3Funs, only the inner pair has to fit
if check_option(varargin,'conv')
  if ~symFits(obj1.SRight,obj2.SLeft)
    error('When convoluting @SO3Fun''s the symmetries have to be compatible.')
  end
  return
end

% check symmetries for all other cases
s = 'The symmetries are not compatible.';
if isa(obj1,'SO3VectorField') || isa(obj1,'SO3TangentVector')
  [cs1,ss1] = symPair(obj1);
  [cs2,ss2] = symPair(obj2);
  obj1 = SO3FunHarmonic(1,cs1,ss1);
  obj2 = SO3FunHarmonic(1,cs2,ss2);
  s = 'The symmetries are not compatible. (Calculations with @SO3TangentVector''s and @SO3VectorField''s needs suitable intern symmetries.)';
elseif isa(obj1,'SO3Fun') && isa(obj2,'SO3Fun')
  s = 'The symmetries are not compatible. (Calculations with @SO3Fun''s needs suitable symmetries.)';
elseif isa(obj1,'SO3Fun') && isa(obj2,'orientation')
  s = 'The symmetries are not compatible. (Evaluating SO3Fun''s at orientations needs suitable symmetries.)';
end


em = ~symFits(obj1.CS,obj2.CS) || ~symFits(obj1.SS,obj2.SS);
if em
  error(s)
end

end

function [cs,ss] = symPair(obj)
% the un-stripped symmetry pair. A vector field stores it, since it has no
% single reference orientation to hang it on; a tangent vector carries it on
% the reference its tangent space is located at.

if isa(obj,'SO3TangentVector')
  ref = obj.oriRef;
  cs = ref.CS; ss = ref.SS;
else
  cs = obj.hiddenCS; ss = obj.hiddenSS;
end

end
