function SO3VF = approximate(f, varargin)
% Approximate a vector field on the rotation group (SO(3)) in its
% multimodal RBF-Kernel representation from a given vector field.
%
% We compute this vector field componentwise, i.e. we compute three
% SO3FunRBFs individually by approximation.
%
% Syntax
%   SO3VF = SO3VectorFieldRBF.approximate(f)
%
% Input
%  f   - @SO3VectorField
%
% Output
%  SO3VF - @SO3VectorFieldRBF
%
% See also
% SO3FunRBF/approximate SO3VectorFieldRBF SO3VectorFieldHarmonic/quadrature


if isa(f,'SO3VectorField')
  tS = f.tangentSpace;
  SRight = f.CS; SLeft = f.SS;
  f = SO3FunHandle(@(rot) f.eval(rot).xyz,SRight,SLeft);
end

if isa(f,'function_handle')
  [SRight,SLeft] = extractSym(varargin);
  % Note that option 'right' in varargin is usually used to describe that the 
  % output is wanted to be described w.r.t. right sided tangent vectors
  % (NOT THE INPUT).
  
  v = f(orientation.id(SRight,SLeft));
  if isa(v,'SO3TangentVector') 
    tS = v.tangentSpace;
  elseif isa(v,'spinTensor')
    if v.CS == SRight
      tS = SO3TangentSpace.right;
    else
      tS = SO3TangentSpace.left;      
    end
  else
    tS = SO3TangentSpace.extract(varargin{:});
  end

  if isnumeric(v) && numel(v)==3
    f = SO3FunHandle(f,SRight,SLeft);
  elseif isa(v,'vector3d')
    f = SO3FunHandle(@(rot) f(rot).xyz,SRight,SLeft);
  elseif isa(v,'spinTensor')
    f = SO3FunHandle(@(rot) vector3d(f(rot)).xyz,SRight,SLeft);
  else
    error('The given function handle do not fit to an SO3VectorField.')
  end
end

% Do quadrature without specimenSymmetry and set SLeft afterwards 
% (if left sided tangent space) clear crystalSymmetry otherwise 
% this means left (the default) is the better option
if tS.isRight
  f.CS = crystalSymmetry;
else
  f.SS = specimenSymmetry;
end

% ----------------- Do approximation on the components --------------------

SO3F = SO3FunRBF.approximate(f,varargin{:});
SO3VF = SO3VectorFieldRBF(SO3F,SRight,SLeft,tS);

end