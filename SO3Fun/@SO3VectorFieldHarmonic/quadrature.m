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

if isa(f,'rotation')
  v = f;
  y = getClass(varargin,'vector3d'); % function values
  if isa(y,'SO3TangentVector') 
    tS = y.tangentSpace;
  else
    tS = 'left';
    warning(['The given vector3d values v are assumed to describe elements w.r.t. ' ...
             'the left side tangent space. If you want them to be right sided ' ...
             'use SO3TangentVector(v,''right'') instead.'])
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
  if strcmp(tS,'right')
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
  warning(['The given function_handle is assumed to describe elements w.r.t. ' ...
           'the left side tangent space. If you want them to be right sided ' ...
           'use SO3VectorFieldHandle(fun,SRight,SLeft,''right'') instead.'])
  tS = 'left';
  v = f(rotation.id);
  if isnumeric(v) && numel(v)==3
    f = SO3FunHandle(f,SRight,SLeft);
  elseif isa(v,'vector3d')
    f = SO3FunHandle(@(rot) f(rot).xyz,SRight,SLeft);
  else
    error('The given function handle do not fit to an SO3VectorField.')
  end
end

% Do quadrature without specimenSymmetry and set SLeft afterwards 
% (if left sided tangent space) clear crystalSymmetry otherwise 
if strcmp(tS,'right')
  f.CS = crystalSymmetry;
else
  f.SS = specimenSymmetry;
end
SO3F = SO3FunHarmonic.quadrature(f,varargin{:});
SO3VF = SO3VectorFieldHarmonic(SO3F,SRight,SLeft,tS);

end
