function SO3VF = quadrature(f, varargin)
%
% Syntax
%   SO3VF = SO3VectorFieldHarmonic.quadrature(rot, value)
%   SO3VF = SO3VectorFieldHarmonic.quadrature(tVec)
%   SO3VF = SO3VectorFieldHarmonic.quadrature(f)
%   SO3VF = SO3VectorFieldHarmonic.quadrature(f, 'bandwidth', bw)
%
% Input
%  rot - @rotation, @orientation
%  value - @vector3d, @spinTensor
%  tVec - @SO3TangentVector
%  f - function handle , @SO3VectorField
%
% Output
%  SO3VF - @SO3VectorFieldHarmonic
%
% Options
%  bandwidth - degree of the Wigner-D functions (default: 64)
%
% See also
% SO3FunHarmonic.quadrature


% TODO: adjust new tangential vector represnetation
%       adjust for spin Tensors



% -------------------------------------------------------------------------
% --------------------- (1) Input is (nodes,values) -----------------------
% -------------------------------------------------------------------------

% extract data
if isa(f,'SO3TangentVector')
  rot = f.rot;
  tS = f.tangentSpace;
  val = vector3d(f);
  varargin = {f.hiddenCS, f.hiddenSS, varargin{:}};
elseif isa(f,'rotation') && isa(varargin{1},'SO3TangentVector')
  if varargin{1}.rot ~= f
    error('The input nodes do not match to the rotations which define the tangent spaces of the tangent vectors.')
  end
  rot = f;
  tS = varargin{1}.tangentSpace;
  val = vector3d(varargin{1});
  varargin = { varargin{1}.hiddenCS , varargin{1}.hiddenSS , varargin{:} };
elseif isa(f,'rotation') && ( isa(varargin{1},'vector3d') || isa(varargin{1},'spinTensor') )
  rot = f;
  tS = SO3TangentSpace.extract(varargin{:});
  val = vector3d(varargin{1});
end

% Do quadrature
if exist('rot','var')

  val = val.xyz;
  [SRight,SLeft] = extractSym(varargin);
  if isa(rot,'orientation')
    if SRight.id==1
      SRight = rot.SRight;
    end
    if SLeft.id==1
      SLeft = rot.SLeft;
    end
  else
    rot = orientation(rot,SRight,SLeft);
  end

  % Do quadrature without specimenSymmetry and set SLeft afterwards 
  % (if left sided tangent space) clear crystalSymmetry otherwise 
  if isa(rot,'quadratureSO3Grid')
    if tS.isRight
      rot = quadratureSO3Grid(rot,crystalSymmetry);
    else
      rot = quadratureSO3Grid(rot,rot.CS,specimenSymmetry);
    end    
  else
    if tS.isRight
      rot.CS = crystalSymmetry;
    else
      rot.SS = specimenSymmetry;
    end
  end

  SO3F = SO3FunHarmonic.quadrature(rot, val, varargin{:});
  SO3VF = SO3VectorFieldHarmonic(SO3F,SRight,SLeft,tS);
  return

end


% -------------------------------------------------------------------------
% ------------------------ (2) Transform to SO3Fun ------------------------
% -------------------------------------------------------------------------

tS = SO3TangentSpace.extract(varargin{:});

if isa(f,'SO3VectorField')
  tS = f.tangentSpace;
  SRight = f.hiddenCS; SLeft = f.hiddenSS;
  % TODO: evaluation with quadratureSO3Grid
  varargin = {varargin{:},'bandwidth',f.bandwidth};
  f = SO3FunHandle(@(rot) f.eval(rot).xyz,f.CS,f.SS);
end

if isa(f,'function_handle')
  
  % extract tangent space
  v = f(rotation.id);
  if isa(v,'SO3TangentVector')
    tS = v.tangentSpace;
  end

  % extract symmetry
  [SRight,SLeft] = extractSym(varargin);

  % construct SO3Fun
  if isnumeric(v)
    f = SO3FunHandle(f,SRight,SLeft);
  elseif isa(v,'spinTensor')
    f = SO3FunHandle(@(rot) vector3d(f(rot)).xyz,SRight,SLeft);
  else
    f = SO3FunHandle(@(rot) f(rot).xyz,SRight,SLeft);
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

% -------------------------------------------------------------------------
% ---------------- (3) Do quadrature on the components --------------------
% -------------------------------------------------------------------------

SO3F = SO3FunHarmonic(f,varargin{:});
SO3VF = SO3VectorFieldHarmonic(SO3F,SRight,SLeft,tS);

end