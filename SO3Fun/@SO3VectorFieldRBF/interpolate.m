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

if isa(values,'SO3TangentVector') 
  tS = values.tangentSpace;
else
  tS = SO3TangentSpace.extract(varargin);
  if sign(tS)>0
    warning(['The given vector3d values v are assumed to describe elements w.r.t. ' ...
             'the left side tangent space. If you want them to be right sided ' ...
             'use SO3TangentVector(v,SO3TangentSpace.rightVector) instead.'])
  end
end

if isa(nodes,'orientation')
  SRight = nodes.CS; SLeft = nodes.SS;
else
  [SRight,SLeft] = extractSym(varargin);
  nodes = orientation(nodes,SRight,SLeft);
end

% Do interpolation without specimenSymmetry and set SLeft afterwards
% (if left sided tangent space) clear crystalSymmetry otherwise
if tS.isRight
  nodes.CS = crystalSymmetry;
else
  nodes.SS = specimenSymmetry;
end

if isa(values,'vector3d')
  values = values.xyz;
end

if any(size(values) ~= [numel(nodes),3])
  error('The shape of the array of values does not match.')
end

SO3F = SO3FunRBF.interpolate(nodes(:),values,varargin{:});
SO3VF = SO3VectorFieldRBF(SO3F,SRight,SLeft,tS);

end
