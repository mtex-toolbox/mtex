function SO3VF = quadrature(f, varargin)
%
% Syntax
%   SO3VF = SO3VectorFieldHarmonic.quadrature(rot, value)
%   SO3VF = SO3VectorFieldHarmonic.quadrature(f)
%   SO3VF = SO3VectorFieldHarmonic.quadrature(f, 'bandwidth', bw)
%
% Input
%  rot - @rotation, @orientation
%  value - @vector3d
%  f - function handle , @SO3VectorField
%
% Output
%  SO3VF - @SO3VectorFieldHarmonic
%
% Options
%  bw - degree of the Wigner-D functions (default: 64)
%

% ------------- quadrature nodes are given -------------------
if isa(f,'rotation')
  v = f;
  y = getClass(varargin,'vector3d'); % function values
  if isa(y,'SO3TangentVector') 
    tS = y.tangentSpace;
  else
    tS = SO3TangentSpace.extract(varargin{:});
  end
  y = y.xyz;
  if isa(v,'orientation')
    SRight = v.CS; SLeft = v.SS;
  else
    [SRight,SLeft] = extractSym(varargin);
    v = orientation(v,SRight,SLeft);
  end
  % Do quadrature without specimenSymmetry and set SLeft afterwards 
  % (if left sided tangent space) clear crystalSymmetry otherwise 
  if tS.isRight
    v.CS = crystalSymmetry;
  else
    v.SS = specimenSymmetry;
  end
  SO3F = SO3FunHarmonic.quadrature(v, y, varargin{:});
  SO3VF = SO3VectorFieldHarmonic(SO3F,SRight,SLeft,tS);
  return
end

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
SO3F = SO3FunHarmonic.quadrature(f,varargin{:});
SO3VF = SO3VectorFieldHarmonic(SO3F,SRight,SLeft,tS);

end
