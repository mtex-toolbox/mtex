function SO3F = approximation(nodes, y, varargin)
% approximate an SO3FunRBF by given function values at given nodes
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
% with specific kernel $\psi$ centered at $N$ nodes weighted by $w_j,\sum_{j}^{N}w_{j}=1$
% as described by [1].
%
% We can also use the approximation command to approximate an SO3FunRBF
% from some given SO3Fun.
%
% Two methods are implemented, referred to as spatial method and harmonic
% method. The spatial method sets up a (sparse) system matrix
% $\Psi\in\mathbb{R}^{M\times N}$ with entries
%
% $$ \Psi_{i,j}=\psi(\omega(R_i,R_j)) $$
%
% of the kernel values of the angle between the evaluation nodes
% $R_i,i=1,...,M$ and grid nodes $R_j,j=1,...,N$. The harmonic method
% computes a system matrix $\Psi\in\mathbb{C}^{L\times M}$, where the
% columns refer to the WignerD function of each grid node $R_j$. Both
% systems are solved by a modified least squares gradient descent.
%
% The spatial method is well suited for sharp functions (i.e. high
% bandwidth), whereas the harmonic method is better suited for low
% bandwidth, since the system matrix becomes very large for high
% bandwidths.
%
% For the spatial method, instead of least squares also the
% maximum-likelihood estimate can be computed. Note that both of this
% methods have the condition that we approximate a odf (the mean of the
% SO3Fun is 1). Hence we can also use some standard least squares methods.
%
% Reference: [1] Schaeben, H., Bachmann, F. & Fundenberger, JJ.
% Construction of weighted crystallographic orientations capturing a given
% orientation density function. J Mater Sci 52, 2077–2090 (2017).
% https://doi.org/10.1007/s10853-016-0496-1
%
% Syntax
%   SO3F = SO3FunRBF.approximation(SO3Grid, f)
%   SO3F = SO3FunRBF.approximation(SO3Grid, f, 'resolution',5*degree)
%   SO3F = SO3FunRBF.approximation(SO3Grid, f, 'kernel', psi)
%   SO3F = SO3FunRBF.approximation(SO3Grid, f, 'density')
%   SO3F = SO3FunRBF.approximation(SO3Grid, f, 'bandwidth', bandwidth, 'tol', TOL, 'maxit', MAXIT)
%   SO3F = SO3FunRBF.approximation(SO3Fun,'kernel',psi)
%
% Input
%  nodes   - rotational grid @SO3Grid, @orientation, @rotation or harmonic
%            coefficents
%  y       - function values on the grid (maybe multidimensional) or empty
%
% Output
%  SO3F - @SO3FunRBF
%
% Options
%  kernel           - @SO3Kernel
%  halfwidth        - use @SO3DeLaValleePoussinKernel with halfwidth
%  resolution       - resolution of the grid nodes of the @SO3Grid
%  approxresolution - if input it @SO3Fun, evaluate function on an  approximation grid with resolution specified
%  bandwidth        - maximum degree of the Wigner-D functions used to approximate the function (Be careful by setting the bandwidth by yourself, since it may yields undersampling)
%  tol              - tolerance for mlsq/ml
%  iter_max         - maximum number of iterations for mlsq/ml
%  SO3Grid
%
% Flags
%  lsqr             - least squares (MATLAB)
%  lsqnonneg        - non negative least squares (MATLAB, fast)
%  lsqlin           - interior point non negative least squares (optimization toolbox, slow)
%  nnls             - non negative least squares (W.Whiten)
%  mlsq             - modified least squares (default)
%  likelihood/mlm   - maximum likelihood estimate for spatial method
%  spatial/spm      - spatial method (default, not specified)
%  harmonic/fourier - harmonic method
%  noThinning       - keep all approximation nodes, irrespective of the associated weight
%  odf              - ensure that SO3FunRBF is a density
%
% See also
% SO3Fun/interpolate SO3FunHarmonic/approximation WignerD


% Tests
% check_WignerD
% check_SO3FunRBFApproximation

if isa(nodes,'SO3Fun') && nargin>1, varargin = {y,varargin{:}}; end

% get kernel
if check_option(varargin,'kernel')
  psi = get_option(varargin,'kernel');
  hw = psi.halfwidth;
else
  hw = get_option(varargin,'halfwidth',5*degree);
  psi = SO3DeLaValleePoussinKernel('halfwidth',hw);
end

% get center of approximated SO3FunRBF
if check_option(varargin,'exact') && isa(nodes,'rotation')
  SO3G = nodes;
else
  res = get_option(varargin,'resolution',max(0.75*degree,hw));
  SO3G = extract_SO3grid(nodes,varargin{:},'resolution',res);
  res = SO3G.resolution;
end


% if input is a SO3Fun, either set up an nodes/y or fourier coeff
if isa(nodes,'SO3Fun')

  f = nodes;

  % maybe we have to normalize at the end
  % TODO: Computation of mean might be time consuming
  varargin = [varargin,'mean',f.mean];
  % %mean does not say anything about f(g) < 0 -> no odf

  if check_option(varargin,{'harmonic','fourier'})
    y0 = f.eval(SO3G); % initial guess for coefficients
    fhat = calcFourier(f,'bandwidth',psi.bandwidth);
    % compute weights
    chat = harmonicMethod(SO3G,psi,fhat,y0,varargin{:});
  else
    approxres = get_option(varargin,'approxresolution',res/2);
    nodes = extract_SO3grid(f,varargin{:},'resolution',approxres);
    y = f.eval(nodes);
    % compute weights
    chat = spatialMethod(SO3G,psi,nodes,y,varargin{:});
  end
  
else

  if length(nodes) ~= numel(y)
    error('Approximation of a SO3FunRBF is only possible for univariate functions.')
  end
  if ~isa(nodes,'orientation') % preserve SO3Grid structure
    nodes = orientation(nodes);
  end
  % compute weights
  chat = spatialMethod(SO3G,psi,nodes,y,varargin{:});

end

% Note: In case of interpolation we may construct the uniform portion first
%       This does not make sense in case of approximation of noisy data
% y = y(:);
% m = min(y);
% if abs(m) < 1e-4*abs(max(y))
%   m=0;
% end
% y = y - m;
% SO3F = m * uniformODF(nodes.CS,nodes.SS);

% construct SO3FunRBF
if check_option(varargin,{'odf'}) || all(chat>=0)
  SO3F = unimodalODF(SO3G,psi,'weights',chat,varargin{:});
else
  SO3F = SO3FunRBF(SO3G,psi,chat);
end

% normalize odf
if abs(sum(chat)*psi.A(1)+SO3F.c0-1)<0.1 || check_option(varargin,'mean')
  m = get_option(varargin,'mean',1);
  SO3F.weights = m * SO3F.weights / sum(SO3F.weights(:)) * (1-SO3F.c0)/psi.A(1);
end

end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      spatial Method - LSQR solver
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function chat = spatialMethod(SO3G,psi,nodes,y,varargin)

Psi = createSummationMatrix(psi,SO3G,nodes,varargin{:});

if check_option(varargin,{'odf'}) || ...
    (check_option(varargin,{'mean'}) && (all(y(:) >= 0) || all(y(:) <= 0)))
  varargin = ['mlsq',varargin];
end

switch get_flag(varargin,{'lsqr','lsqlin','lsqnonneg','nnls','mlm','likelihood','maximumlikelihood','mlrl','mlsq'},'lsqr')

  case 'lsqlin'
      
    tolCon = get_option(varargin,'lsqlin_tolCon',1e-10);
    tolX = get_option(varargin,'lsqlin_tolX',1e-14);
    tolFun = get_option(varargin,'lsqlin_tolFun',1e-10);
    
    options = optimoptions('lsqlin','Algorithm','interior-point',...
      'Display','iter','TolCon',tolCon,'TolX',tolX,'TolFun',tolFun);
    
    n2 = size(Psi,1);
    
    chat = lsqlin(Psi',y,-eye(n2,n2),zeros(n2,1),[],[],[],[],[],options);
    
  case 'nnls'
    
    chat = nnls(full(Psi).',y,struct('Iter',1000));
    
  case 'lsqnonneg'
    
    chat = lsqnonneg(Psi',y);
    
  case 'lsqr'
    
    tol = get_option(varargin,{'tol','tolerance'},1e-2);
    iters = get_option(varargin,{'iter','iter_max','iters'},30);
    [chat,flag] = lsqr(Psi',y,tol,iters);
    
    % In case a user wants the best possible tolerance, just keep
    % increasing tolerance
    cnt=0;
    while flag > 0
      tol = tol*1.3;
      disp(['   lsqr tolerance cut back: ',xnum2str(max(tol))])
      [chat,flag] = lsqr(Psi',y,tol,50);
      cnt=cnt+1;
      if cnt > 5
        disp('   more than 5 lsqr tolerance cut backs')
        disp('   consider using a larger tolerance')
        break
      end
    end
    
  case {'mlm','likelihood','maximumlikelihood','mlrl','mlsq'}  % we have constraints that
    
    m = get_option(varargin,'mean',1.0);
    % initial guess for coefficients
    c0 = Psi*y(:);
    if check_option(varargin,'odf')
      c0(c0<eps) = eps; % all weights must be positive
    else
      cx = abs(c0)<=eps;
      c0(cx) = sign(c0(cx))*eps;
    end
    c0 = m*c0./sum(c0(:));
    
    itermax = get_option(varargin,{'iter','iter_max','iters'},100);
    tol = get_option(varargin,{'tol','tolerance'},1e-3);
    
    if check_option(varargin,{'mlm','likelihood','maximumlikelihood','mlrl'})
      chat = mlrl(Psi.',y(:),c0(:),itermax,tol/size(Psi,2)^2);
    else
      chat = mlsq(Psi.',y(:),c0(:),itermax,tol);
    end
    
end

end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     harmonic Method - LSQR solver
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function chat = harmonicMethod(SO3G,psi,fhat,y,varargin)

assert(any(y(:) < 0) && any(0 < y(:)),...
  'SO3FunRBF:approximation','can not approximate non-density like functions with the harmonic method')

% if check_option(varargin,'mean') && (all(y > 0) || all(y < 0))
%     varargin = ['mlsq',varargin];
% end

bw = psi.bandwidth;

itermax = get_option(varargin,{'iter','iter_max','iters'},100);
tol = get_option(varargin,{'tol','tolerance'},1e-3);

% initial guess for coefficients
m = get_option(varargin,'mean',1.0);
c0 = y(:) ; %odf.eval(SO3G);
c0(c0<=eps) = eps;
c0 = m*c0./sum(c0(:));

if deg2dim(psi.bandwidth+1)*length(SO3G)*8 < 0.5*2^30 % use direct computation

  % get fourier coefficients for each node
  a = zeros(deg2dim(bw+1),1);
  for i=0:bw
    a(deg2dim(i)+1:deg2dim(i+1)) = psi.A(i+1)/sqrt(2*i+1);
  end
  Fstar = WignerD(SO3G,'bandwidth',bw).*a;
  
  % sparsify
  Fstar(abs(Fstar) < 10*eps) = 0;
  Fstar = sparse(Fstar);
  
  % lsqr
  chat = mlsq(conj(Fstar),fhat,c0(:),itermax,tol);
  
else % use NFFT-based matrix-vector multiplication
  
  % get weights
  W = zeros(deg2dim(bw+1),1);
  for i=0:bw
    W(deg2dim(i)+1:deg2dim(i+1)) = psi.A(i+1)/(2*i+1);
  end
  
  % lsqr
  chat = mlsq( @(x, transp_flag) afun(transp_flag, x, SO3G(:), W, bw), fhat,c0(:),itermax,tol);
  
end

end

function y = afun(transp_flag, x, nodes, W, bw)

if strcmp(transp_flag, 'transp')
  
  x = x .* W;
  F = SO3FunHarmonic(x,nodes.CS,nodes.SS);
  F.bandwidth = bw;
  y = F.eval(nodes);
  
elseif strcmp(transp_flag, 'notransp')
  
  F = SO3FunHarmonic.adjoint(nodes,x,'bandwidth',bw);
  y = F.fhat;
  y = y .* W;
end

end

