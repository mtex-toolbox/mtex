function SO3VF = quadrature(f, varargin)
%
% Syntax
%   SO3VF = SO3VectorFieldHarmonic.quadrature(tVec)
%   SO3VF = SO3VectorFieldHarmonic.quadrature(tVec, tS)
%   SO3VF = SO3VectorFieldHarmonic.quadrature(rot, value)
%   SO3VF = SO3VectorFieldHarmonic.quadrature(rot, value, cs, ss, tS)
%   SO3VF = SO3VectorFieldHarmonic.quadrature(f)
%   SO3VF = SO3VectorFieldHarmonic.quadrature(f, 'bandwidth', bw)
%
% Input
%  rot - @rotation, @orientation
%  value - @vector3d, @spinTensor, @SO3TangentVector
%  tVec - @SO3TangentVector
%  f - function handle , @SO3VectorField
%  cs,ss - @symmetry 
%  tS - @SO3TangentSpace
%
% Output
%  SO3VF - @SO3VectorFieldHarmonic
%
% Options
%  bandwidth - degree of the Wigner-D functions (default: 64)
%  weights
%
% See also
% SO3FunHarmonic.quadrature



% -------------------------------------------------------------------------
% --------------------- (1) Input is (nodes,values) -----------------------
% -------------------------------------------------------------------------

% extract data
if isa(f,'SO3TangentVector')
  
  tS = SO3TangentSpace.extract(varargin{:},f.tangentSpace);
  % Maybe change tangent space
  f = transformTangentSpace(f,tS);
  
  ref = f.oriRef;
  rot = f.rot;
  val = vector3d(f);
  varargin = {ref.CS, ref.SS, varargin{:}};

elseif isa(f,'rotation') && isa(varargin{1},'SO3TangentVector')

  tS = SO3TangentSpace.extract(varargin{:},varargin{1}.tangentSpace);
  % Maybe change tangent space
  varargin{1} = transformTangentSpace(varargin{1},tS);

  % check for same rotations & same symmetries
  r = varargin{1}.rot;
  if isa(f,'orientation')
    r.CS = f.CS; r.SS = f.SS;
  end
  if any(r(:) ~= f(:))
    error('The input nodes have to be the same as the rotations which define the tangent spaces of the tangent vectors.')
  end

  rot = f;
  val = vector3d(varargin{1});
  ref = varargin{1}.oriRef;
  varargin = { ref.CS , ref.SS , varargin{:} };

elseif isa(f,'rotation') && ( isa(varargin{1},'vector3d') || isa(varargin{1},'spinTensor') )

  rot = f;
  tS = SO3TangentSpace.extract(varargin{:});
  val = vector3d(varargin{1});
  % It will be ensured later, that one of the symmetries of the input 
  % orientation has id=1 (dependent on the tangent space representation) 

end

% Do quadrature
if exist('rot','var')

  val = val.xyz;
  % absence is empty, so passed triclinic symmetries survive with their
  % frames (ADR 0003); only genuinely absent slots fall back
  [SRight,SLeft] = extractSym(varargin,'empty');
  if isa(rot,'orientation')
    if isempty(SRight), SRight = rot.CS; end
    if isempty(SLeft), SLeft = rot.SS; end
  else
    if isempty(SRight), SRight = specimenSymmetry; end
    if isempty(SLeft), SLeft = specimenSymmetry; end
    rot = orientation(rot,SRight,SLeft);
  end

  % For quadrature, one of the symmetries needs to have id=1.
  % This depends on the tangent space representation 
  if isa(rot,'quadratureSO3Grid')
    if tS.isRight
      rot = quadratureSO3Grid(rot,stripSym(rot.CS));
    else
      rot = quadratureSO3Grid(rot,rot.CS,stripSym(rot.SS));
    end
  else
    % drop the group, keep the frame - a session default here would swap
    % the data's frame for the session's (ADR 0003)
    if tS.isRight
      rot.CS = stripSym(rot.CS);
    else
      rot.SS = stripSym(rot.SS);
    end
  end
  
  % compute quadrature
  SO3F = SO3FunHarmonic.quadrature(rot, val, varargin{:});
  SO3VF = SO3VectorFieldHarmonic(SO3F,SRight,SLeft,tS);
  return

end


% -------------------------------------------------------------------------
% ------------------------ (2) Transform to SO3Fun ------------------------
% -------------------------------------------------------------------------

% extract tangentSpace and symmetries - for a bare function handle an
% absent symmetry genuinely means the session default
tS = SO3TangentSpace.extract(varargin{:});
[SRight,SLeft] = extractSym(varargin,'empty');
if isempty(SRight), SRight = specimenSymmetry; end
if isempty(SLeft), SLeft = specimenSymmetry; end

% How to handle SO3VectorFieldHarmonics
if isa(f,'SO3VectorFieldHarmonic')
  tS = SO3TangentSpace.extract(varargin{:},f.tangentSpace);
  if f.internTangentSpace == tS
    SO3VF = f;
    SO3VF.tangentSpace = tS;
    return
  end
end

if isa(f,'SO3VectorField')
  tS = SO3TangentSpace.extract(varargin{:},f.tangentSpace);
  f.tangentSpace = tS;
  SRight = f.hiddenCS; SLeft = f.hiddenSS;
  varargin = {varargin{:},'bandwidth',f.bandwidth};
  f = SO3FunHandle(@(rot) f.eval(rot).xyz,SRight,SLeft);
end

if isa(f,'function_handle')
  
  % extract tangent space
  v = f(orientation.id(SRight,SLeft));
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


% For quadrature, one of the symmetries needs to have id=1.
% This depends on the tangent space representation 
if tS.isRight
  f.CS = stripSym(f.CS);
else
  f.SS = stripSym(f.SS);
end

% -------------------------------------------------------------------------
% ---------------- (3) Do quadrature on the components --------------------
% -------------------------------------------------------------------------

SO3F = SO3FunHarmonic(f,varargin{:});
SO3VF = SO3VectorFieldHarmonic(SO3F,SRight,SLeft,tS);

end