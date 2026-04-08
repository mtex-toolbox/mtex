function SO3VF = interpolate(nodes, values, varargin)
% Approximate a vector field on the rotation group (SO(3)) in its
% RBF-Kernel representation from some given orientations with corresponding 
% tangent vectors and maybe some noise.
%
% We compute this vector field componentwise, i.e. we compute three
% SO3FunRBFs individually by interpolation. 
%
% Syntax
%   SO3F = SO3VectorFieldRBF.interpolate(nodes,y)
%   SO3F = SO3VectorFieldRBF.interpolate(nodes,y,'halfwidth',1*degree)
%   SO3F = SO3VectorFieldRBF.interpolate(nodes,y,'kernel',psi)
%   SO3F = SO3VectorFieldRBF.interpolate(nodes,y,'kernel',psi,'exact')
%   SO3F = SO3VectorFieldRBF.interpolate(nodes,y,'kernel',psi,'resolution',5*degree)
%   SO3F = SO3VectorFieldRBF.interpolate(nodes,y,'kernel',psi,'SO3Grid',S3G)
%   SO3F = SO3VectorFieldRBF.interpolate(nodes,y,'mlsq','tol',1e-3,'maxit',100,'density')
%
% Input
%  nodes - rotational grid @SO3Grid, @orientation, @rotation or harmonic coefficents
%  y     - function values on the grid (maybe multidimensional) or empty
%  psi   - @SO3Kernel of the approximated SO3FunRBF (default: SO3DeLaValleePoussinKernel('halfwidth',5*degree))
%  S3G   - @rotation
%
% Output
%  SO3F     - @SO3VectorFieldRBF
%
% Options
%  halfwidth        - halfwidth of the SO3Kernel of the result SO3FunRBF
%  kernel           - SO3Kernel of the result SO3FunRBF
%  SO3Grid          - center of the result SO3FunRBF
%  resolution       - resolution of the @SO3Grid which is the center of the result SO3FunRBF
%  approxresolution - resolution of the approximation grid, which is used to evaluate the input odf, if we use the spatial method (not the harmonic method)
%  tol              - tolerance as termination condition for lsqr/mlsq/...
%  maxit            - maximum number of iterations as termination condition for lsqr/mlsq/...
%
% Flags
%  'exact'    - if rotations are given, then use nodes as center of result SO3FunRBF and try to do exact computations
%  'density'  - ensure that result SO3FunRBF is a density function (i.e. positiv and mean is 1)
%  LSQRsolver - ('lsqr'|'lsqnonneg'|'lsqlin'|'nnls'|'mlsq'|'mlrl') specify least square solver for spatial method --> default: lsqr
%
% LSQR-Solvers
%  lsqr             - least squares (MATLAB)
%  lsqnonneg        - non negative least squares (MATLAB, fast)
%  lsqlin           - interior point non negative least squares (optimization toolbox, slow)
%  nnls             - non negative least squares (W.Whiten)
%  mlsq             - modified least squares (with positivity condition and normalization to mean 1)
%  mlrl             - maximum likelihood estimate (with positivity condition and normalization to mean 1)
%
% See also
% rotation/interp SO3FunRBF/interpolate 



% -------------------------------------------------------------------------

% extract data (rot, val, tS)
if isa(nodes,'SO3TangentVector')
  
  if nargin>1
    varargin = {values,varargin{:}};
  end
  
  tS = SO3TangentSpace.extract(varargin{:},nodes.tangentSpace);
  % Maybe change tangent space
  nodes = transformTangentSpace(nodes,tS);
  
  rot = nodes.rot;
  val = vector3d(nodes);
  varargin = {nodes.hiddenCS, nodes.hiddenSS, varargin{:}};

elseif isa(nodes,'rotation') && isa(values,'SO3TangentVector')
  
  tS = SO3TangentSpace.extract(varargin{:},values.tangentSpace);
  % Maybe change tangent space
  values = transformTangentSpace(values,tS);
  
  % check for same rotations & same symmetries
  r = values.rot;
  if isa(nodes,'orientation')
    r.CS = nodes.CS; r.SS = nodes.SS;
  end
  if any(r(:) ~= nodes(:))
    error('The input nodes have to be the same as the rotations which define the tangent spaces of the tangent vectors.')
  end
  
  rot = values.rot;
  val = vector3d(values);
  varargin = { values.hiddenCS , values.hiddenSS , varargin{:} };

elseif isa(nodes,'rotation') && ( isa(values,'vector3d') || isa(values,'spinTensor'))

  rot = nodes;
  tS = SO3TangentSpace.extract(varargin{:});
  val = vector3d(values);
  % It will be ensured later, that one of the symmetries of the input 
  % orientation has id=1 (dependent on the tangent space representation) 

end

% Check input values
if isnumeric(val)
  error('The input values have to be of class vector3d.')
end
if numel(val) ~= numel(rot)
  error('The numbers of nodes and values do not match.')
end


% extract symmetries
[SRight,SLeft] = extractSym(varargin);
if isa(rot,'orientation')
  if SRight.id==1
    SRight = rot.CS;
  end
  if SLeft.id==1
    SLeft = rot.SS;
  end
else
  rot = orientation(rot,SRight,SLeft);
end


% For interpolation, one of the symmetries needs to have id=1.
% This depends on the tangent space representation 
if tS.isRight
  rot.CS = ID1(rot.CS);
else
  rot.SS = ID1(rot.SS);
end


% do interpolation
SO3F = SO3FunRBF.interpolate(rot(:),val.xyz,varargin{:});
SO3VF = SO3VectorFieldRBF(SO3F,SRight,SLeft,tS);

end

