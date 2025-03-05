function [SO3F,iter] = approximate(f, varargin)
% Approximate an SO3FunRBF from some given orientation dependent function.
%
% 1) Spatial Method: Choose a grid of orientations $R_i$ and evaluate $f$. 
% Do SO3FunRBF.interpolation afterwards.
%
% 2) Harmonic Method: Compute the weights of the SO3FunRBF such that the 
% Fourier coefficients are similar to the Fourier coefficients of the given
% odf.
%
%
% The spatial method is well suited for sharp functions (i.e. high
% bandwidth), whereas the harmonic method is better suited for low
% bandwidth, since the system matrix becomes very large for high
% bandwidths.
%
% For the spatial method, instead of modified least squares (mlsq) also the
% maximum-likelihood estimate (mlrl) can be computed. Note that both of this
% methods have the condition that we approximate a odf (the mean of the
% SO3Fun is 1). We can also use some standard least squares methods (for 
% example lsqr).
%
% Syntax
%   SO3F = SO3FunRBF.approximate(f)
%   SO3F = SO3FunRBF.approximate(f,'kernel',psi)
%   SO3F = SO3FunRBF.approximate(f,'SO3Grid',S3G)
%   SO3F = SO3FunRBF.approximate(f,'kernel',psi,'SO3Grid',S3G)
%   SO3F = SO3FunRBF.approximate(f,'kernel',psi,'resolution',5*degree)
%   SO3F = SO3FunRBF.approximate(f,'kernel',psi,'resolution',5*degree,'approxresolution',2*degree)
%   SO3F = SO3FunRBF.approximate(f,'mlsq','tol',1e-3,'maxit',100,'density')
%
%   SO3F = SO3FunRBF.approximate(f,'harmonic')
%   SO3F = SO3FunRBF.approximate(f,'harmonic','tol',1e-3,'maxit',100)
%   SO3F = SO3FunRBF.approximate(f,'harmonic','kernel',psi,'SO3Grid',S3G,'density')
%
%   [SO3F,lsqrIter] = SO3FunRBF.approximate(___)
%
% Input
%  f     - @SO3Fun
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
%  'density'  - ensure that result SO3FunRBF is a density function (i.e. positiv and mean is 1)
%  LSQRsolver - ('lsqr'|'mlsq'|'mlrl') specify least square solver for spatial method --> default: lsqr
%  'harmonic' - if an SO3Fun is given, then use harmonic method for approximation, see above (spatial method is default)
%
% LSQR-Solvers
%  lsqr             - least squares (MATLAB)
%  mlsq             - modified least squares (with positivity condition and normalization to mean 1)
%  mlrl             - maximum likelihood estimate (with positivity condition and normalization to mean 1)
%
% See also
% SO3FunRBF SO3FunHarmonic/approximate


if isa(f,'function_handle')
  [SRight,SLeft] = extractSym(varargin);
  f = SO3FunHandle(f,SRight,SLeft);
end

% get kernel of approximated SO3FunRBF
hw = get_option(varargin,'resolution',5*degree);
hw = get_option(varargin,'halfwidth',hw);
psi = get_option(varargin,'kernel',SO3DeLaValleePoussinKernel('halfwidth',hw));

% get center of approximated SO3FunRBF
res = get_option(varargin,'resolution',max(0.75*degree,psi.halfwidth));
SO3G = get_option(varargin,'SO3Grid',equispacedSO3Grid(f.CS,f.SS,'resolution',res));
try
  res = SO3G.resolution;
end

% maybe we have to normalize at the end
% TODO: Computation of mean might be time consuming
varargin = [varargin,'mean',f.mean];
% mean does not say anything about f(g) < 0 -> no density

if check_option(varargin,'harmonic')
  y0 = f.eval(SO3G); % initial guess for coefficients
  f.bandwidth = psi.bandwidth;
  fhat = calcFourier(f,'bandwidth',psi.bandwidth);
  % LEAST-SQUARES-PROBLEM
  [chat,iter] = harmonicMethod(SO3G,psi,fhat,y0,varargin{:});
else
  approxres = get_option(varargin,'approxresolution',res/2);
  nodes = get_option(varargin,'SO3Grid',equispacedSO3Grid(f.CS,f.SS,'resolution',approxres));
  y = f.eval(nodes);
  % LEAST-SQUARES-PROBLEM   -->  SO3FunRBF.interpolate
  [chat,iter] = spatialMethod(SO3G,psi,nodes,y,varargin{:});
end
  
% construct SO3FunRBF
if check_option(varargin,'density') && numel(f)>1
  sz = size(chat);
  SO3F = SO3FunRBF(SO3G,psi,chat,zeros([sz(2:end) 1]));
  m = 1;
elseif check_option(varargin,'density')
  SO3F = unimodalODF(SO3G,psi,'weights',chat,varargin{:}); % remove to small values
  m = 1;
else
  SO3F = SO3FunRBF(SO3G,psi,chat);
  m = get_option(varargin,'mean',[]);
end

% normalize odf
if ~isempty(m)
  sz = size(SO3F);
  SO3F.weights = reshape(m,[1,sz]) .* SO3F.weights ./ sum(SO3F.weights,1) .* (1-reshape(SO3F.c0,[1,sz])) /psi.A(1);
end

end
