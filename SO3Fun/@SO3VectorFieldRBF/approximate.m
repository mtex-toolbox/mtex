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

% extract tangentSpace and symmetries
tS = SO3TangentSpace.extract(varargin{:});
[SRight,SLeft] = extractSym(varargin);


if isa(f,'SO3VectorFieldRBF')
  tS = SO3TangentSpace.extract(varargin{:},f.tangentSpace);
  if f.internTangentSpace == tS
    SO3VF = f;
    f.tangentSpace = tS;
    return
  end
end


if isa(f,'SO3VectorField')
  tS = SO3TangentSpace.extract(varargin{:},f.tangentSpace);
  f.tangentSpace = tS;
  SRight = f.hiddenCS; SLeft = f.hiddenSS;
  f = SO3FunHandle(@(rot) f.eval(rot).xyz,SRight,SLeft);
end


if isa(f,'function_handle')
  
  % extract tangent space
  v = f(rotation.id);
  if isa(v,'SO3TangentVector')
    tS = v.tangentSpace;
  end

  % construct SO3Fun
  if isnumeric(v)
    f = SO3FunHandle(f,SRight,SLeft);
  elseif isa(v,'spinTensor')
    f = SO3FunHandle(@(rot) vector3d(f(rot)).xyz,SRight,SLeft);
  else
    f = SO3FunHandle(@(rot) f(rot).xyz,SRight,SLeft);
  end

end


% For approximation, one of the symmetries needs to have id=1.
% This depends on the tangent space representation
if tS.isRight
  f.CS = ID1(f.CS);
else
  f.SS = ID1(f.SS);
end

% ----------------- Do approximation on the components --------------------

SO3F = SO3FunRBF(f,varargin{:});
SO3VF = SO3VectorFieldRBF(SO3F,SRight,SLeft,tS);

end