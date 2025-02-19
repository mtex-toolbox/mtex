function [SO3F,iter] = interpolate(nodes, y, varargin)
% Approximate an SO3FunRBF by given function values at given nodes
% w.r.t. some noise as described by [1].
%
% For $M$ given orientations $R_i$ and corresponding function values $y_i$
% we compute the SO3FunRBF $f$ which minimizes the least squares problem
%
% $$\sum_{i=1}^M|f(R_i)-y_i|^2.$$
%
% where $f$ is
%
% $$ f(R)=\sum_{j=1}^{N}w_j\psi(\omega(R_j,R)) $$
%
% with specific kernel $\psi$ centered at $N$ nodes weighted by
% $w_j,\sum_{j}^{N}w_{j}=1$ as described by [1].
%
% Therefore we set up a (sparse) system matrix $\Psi\in\mathbb{R}^{M\times
% N}$ with entries
%
% $$ \Psi_{i,j}=\psi(\omega(R_i,R_j)) $$
%
% of the kernel values of the angle between the evaluation nodes
% $R_i,i=1,...,M$ and grid nodes $R_j,j=1,...,N$. This system is solved by 
% least squares gradient descent.
%
% Instead of modified least squares (mlsq) also the maximum-likelihood
% estimate (mlrl) can be computed. Note that both of this methods have the
% condition that we approximate a odf (the mean of the SO3Fun is 1). We can
% also use some standard least squares methods (for example lsqr).
%
% Reference: [1] Schaeben, H., Bachmann, F. & Fundenberger, JJ.
% Construction of weighted crystallographic orientations capturing a given
% orientation density function. J Mater Sci 52, 2077–2090 (2017).
% https://doi.org/10.1007/s10853-016-0496-1
%
% Syntax
%   SO3F = SO3FunRBF.interpolate(nodes,y)
%   SO3F = SO3FunRBF.interpolate(nodes,y,'halfwidth',1*degree)
%   SO3F = SO3FunRBF.interpolate(nodes,y,'kernel',psi)
%   SO3F = SO3FunRBF.interpolate(nodes,y,'kernel',psi,'exact')
%   SO3F = SO3FunRBF.interpolate(nodes,y,'kernel',psi,'resolution',5*degree)
%   SO3F = SO3FunRBF.interpolate(nodes,y,'kernel',psi,'SO3Grid',S3G)
%   SO3F = SO3FunRBF.interpolate(nodes,y,'mlsq','tol',1e-3,'maxit',100,'density')
%
%   [SO3F,lsqrIter] = SO3FunRBF.interpolate(___)
%
% Input
%  nodes - rotational grid @SO3Grid, @orientation, @rotation or harmonic coefficents
%  y     - function values on the grid (maybe multidimensional) or empty
%  psi   - @SO3Kernel of the approximated SO3FunRBF (default: SO3DeLaValleePoussinKernel('halfwidth',5*degree))
%  S3G   - @rotation
%
% Output
%  SO3F     - @SO3FunRBF
%  lsqrIter - number of iterations of the LSQR-Solver
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
% rotation/interp SO3FunHarmonic/interpolate


% get kernel of approximated SO3FunRBF
hw = get_option(varargin,'resolution',5*degree);
hw = get_option(varargin,'halfwidth',hw);
psi = get_option(varargin,'kernel',SO3DeLaValleePoussinKernel('halfwidth',hw));

% get center of approximated SO3FunRBF
res = get_option(varargin,'resolution',max(0.75*degree,psi.halfwidth));
if isa(nodes,'quaternion') && ~isa(nodes,'orientation')
  [CS,SS] = extractSym(varargin);
  nodes = orientation(nodes,CS,SS);
end
SO3G = get_option(varargin,'SO3Grid',equispacedSO3Grid(nodes.CS,nodes.SS,'resolution',res));
try
  res = SO3G.resolution;
end
if isa(nodes,'rotation') && check_option(varargin,'exact')
  SO3G = nodes;
end

% check multivariate
if length(nodes) ~= numel(y)
  error('Approximation of a SO3FunRBF is only possible for univariate functions.')
end

% LEAST-SQUARES-PROBLEM
[chat,iter] = spatialMethod(SO3G,psi,nodes,y,varargin{:});

% Note: In case of exact interpolation we may construct the uniform portion first
%       This does not make sense in case of approximation of noisy data
% y = y(:); 
% m = min(y);
% if abs(m) < 1e-4*abs(max(y))
%   m=0;
% end
% y = y - m;
% SO3F = m * uniformODF(nodes.CS,nodes.SS);

% construct SO3FunRBF
if check_option(varargin,'density')
  SO3F = unimodalODF(SO3G,psi,'weights',chat,varargin{:});   % remove to small values
  m = 1;
else
  SO3F = SO3FunRBF(SO3G,psi,chat);
  m = get_option(varargin,'mean',[]);
end

% normalize odf
if ~isempty(m)
  SO3F.weights = m * SO3F.weights / sum(SO3F.weights(:)) * (1-SO3F.c0)/psi.A(1);
end

end

