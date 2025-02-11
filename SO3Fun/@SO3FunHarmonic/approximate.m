function [SO3F,lsqrParameters] = approximate(nodes, y, varargin)
% Approximate an SO3FunHarmonic by given function values at given nodes 
% w.r.t. some noise.
%
% For $M$ given orientations $R_i$ and corresponding function values $y_i$ 
% we compute the SO3FunHarmonic $f$ of an specific bandwidth which 
% minimizes the least squares problem
%
% $$\sum_{i=1}^M|f(R_i)-y_i|^2.$$
%
% If the oversampling factor is small (high bandwidth) it may be necessary
% to assure decay of the harmonic coefficients. Therefore we regularize the
% least squares problem by the Sobolev norm of f, i.e we minimize
%
% $$\sum_{i=1}^M|f(R_i)-y_i|^2 + \lambda \|f\|^2_{H^s}$$
%
% where $\lambda$ is the regularization parameter and $s$ the Sobolev
% index. The Sobolev norm of an SO3FunHarmonic with harmonic coefficients 
% $\hat{f}$ reads as
%
% $$\|f\|^2_{H^s} = \sum_{n=0}^N (2n+1)^{2s} \, \sum_{k,l=-n}^n|\hat{f}_n^{k,l}|^2.$$
%
% We can also use the approximation command to approximate an SO3FunHarmonic 
% from some given SO3Fun by evaluating on some specific grid and doing quadrature.
%
% Syntax
%   SO3F = SO3FunHarmonic.approximate(odf)                 % exact computation by quadrature
%   SO3F = SO3FunHarmonic.approximate(odf,'bandwidth',48)  % exact computation by quadrature
%   SO3F = SO3FunHarmonic.approximate(nodes,y)
%   SO3F = SO3FunHarmonic.approximate(nodes,y,'bandwidth',48)
%   SO3F = SO3FunHarmonic.approximate(nodes,y,'weights','Voronoi')
%   SO3F = SO3FunHarmonic.approximate(nodes,y,'bandwidth',48,'weights',W,'tol',1e-6,'maxit',200)
%   SO3F = SO3FunHarmonic.approximate(nodes,y,'regularization',0) % no regularization
%   SO3F = SO3FunHarmonic.approximate(nodes,y,'regularization',1e-4,'SobolevIndex',2)
%   [SO3F,lsqrParameters] = SO3FunHarmonic.approximate(___)
%
% Input
%  odf   - @SO3Fun
%  nodes - grid of @rotation
%  y     - function values on the grid (maybe multidimensional)
%
% Output
%  SO3F - @SO3FunHarmonic
%  lsqrParameters - double
%
% Options
%  bandwidth       - maximal harmonic degree (Be careful by setting the bandwidth by yourself, since it may yields undersampling)
%  weights         - corresponding to the nodes (default is 'equal': all nodes are weighted similar; 'Voronoi': Voronoi volumes; numeric array W: specific weights for every node)
%  tol             - tolerance as termination condition for lsqr
%  maxit           - maximum number of iterations as termination condition for lsqr
%  regularization  - the energy functional of the lsqr solver is regularized by the Sobolev norm of SO3F with regularization parameter lambda (default: 1e-4)(0: no regularization)
%  SobolevIndex    - for regularization (default = 2)
%  cutOffParameter - cut off parameter m of the window functions in NFFT
%
% See also
% rotation/interp SO3FunHarmonic/quadrature SO3VectorFieldHarmonic/approximate

if isa(nodes,'function_handle')
  [SRight,SLeft] = extractSym(varargin);
  nodes = SO3FunHandle(nodes,SRight,SLeft);
end

if isa(nodes,'SO3Fun')
  if nargin>1, varargin = [y,varargin]; end
  f_hat = calcFourier(nodes,varargin{:});
  SO3F = SO3FunHarmonic(f_hat,nodes.SRight,nodes.SLeft,varargin{:});
  return
end
if isa(nodes,'quadratureSO3Grid')
  SO3F = SO3FunHarmonic.quadrature(nodes,y,varargin{:});
  return
end

nodes = nodes(:);
y = reshape(y,length(nodes),[]);

if isa(nodes,'orientation')
  SRight = nodes.CS; SLeft = nodes.SS;
  if nodes.antipodal
    nodes.antipodal = 0;
    nodes = [nodes(:);inv(nodes)];
    y = [y;y];
    varargin{end+1} = 'antipodal';
  end
else
  [SRight,SLeft] = extractSym(varargin);
  nodes = orientation(nodes,SRight,SLeft);
end

% make points unique
s = size(y);
y = reshape(y, length(nodes), []);
if numel(nodes)>2e5
  [nodes,~,ind] = unique(nodes(:),'tolerance',0.02,'stable');
else
  [nodes,~,ind] = unique(nodes(:),'tolerance',0.02);
end
% take the mean over duplicated nodes
for k = 1:size(y,2)
  yy(:,k) = accumarray(ind,y(:,k),[],@mean); %#ok<AGROW>
end
y = reshape(yy, [length(nodes) s(2:end)]);



tol = get_option(varargin, 'tol', 1e-3);
maxit = get_option(varargin, 'maxit', 100);

% regularization options
lambda = get_option(varargin,'regularization',5e-7);
SobolevIndex = get_option(varargin,'SobolevIndex',2);
regularize = lambda > 0;

% decide bandwidth
bw = chooseBandwidth(nodes,y,SRight,SLeft,varargin{:});

% extract weights
W = get_option(varargin, 'weights');
if strcmp(W,'Voronoi') || (isempty(W) && numel(nodes)<1e4)
  W = calcVoronoiVolume(nodes);  % --> Time Consuming
  W = W./sum(W);
elseif isempty(W) || strcmp(W,'equal')
  W = 1/length(nodes);
else
  if length(W)>1, W = accumarray(ind,W); end
end
W = sqrt(W(:));

b = W.*y;
if regularize
  b = [b;zeros(deg2dim(bw+1),size(b,2))];
end

% create plan
% SO3FunHarmonic([1;1]).eval(nodes,'createPlan','nfsoft')
% SO3FunHarmonic.quadrature(nodes,1,'createPlan','nfsoft','bandwidth',bw)

% least squares solution
for index = 1:size(y,2)
  [fhat(:, index),flag(index),relres(index),iter(index),resvec{index},lsvec{index}] ...
    = lsqr( @(x, transp_flag) afun(transp_flag, x, nodes, W,bw,regularize,lambda,SobolevIndex,varargin),...
    b(:, index), tol, maxit);
end
if any(flag == 1)
  warning('lsqr:itermax','Maximum number of iterations reached, result may not have converged to the optimum yet.');
end
lsqrParameters = {flag,relres,iter,resvec,lsvec};

% kill plan
% SO3FunHarmonic.quadrature(1,'killPlan','nfsoft')
% SO3FunHarmonic(1).eval(1,'killPlan','nfsoft')

SO3F = SO3FunHarmonic(fhat,SRight,SLeft);

% TODO: antipodal is lost

end

function y = afun(transp_flag, x, nodes, W,bw,regularize,lambda,SobolevIndex,varargin)

cutOff = get_option(varargin,'cutOffParameter',1);

if strcmp(transp_flag, 'transp')
  
  if regularize
    u = x(length(nodes)+1:end);
    x = x(1:length(nodes));
  end
  x = x .* W;
  %   F = SO3FunHarmonic.quadrature(nodes,x,'keepPlan','nfsoft','bandwidth',bw);
  F = SO3FunHarmonic.adjoint(nodes,x,'bandwidth',bw,'cutoffParameter',cutOff);
  y = F.fhat;
  if regularize
    F = SO3FunHarmonic(u);
    SO3F = conv(F,sqrt(lambda)*(2*(0:bw)+1).'.^SobolevIndex);
    y = y+SO3F.fhat;
  end
 
elseif strcmp(transp_flag, 'notransp')

  F = SO3FunHarmonic(x,nodes.CS,nodes.SS);
  F.bandwidth = bw;
  %   y = F.eval(nodes,'keepPlan','nfsoft');
  y = F.eval(nodes,'cutoffParameter',cutOff);
  y = y .* W;
  if regularize
    SO3F = conv(F,sqrt(lambda)*(2*(0:bw)+1).'.^SobolevIndex);
    y = [y;SO3F.fhat];
  end

end

end


% We have to decide which bandwidth we are using dependent from the
% oversampling factor.
function bw = chooseBandwidth(nodes,y,SRight,SLeft,varargin)

bw = get_option(varargin,'bandwidth');
nSym = numSym(SRight.properGroup)*numSym(SLeft.properGroup)*(isalmostreal(y)+1);

% assume there is some bandwidth given
if ~isempty(bw)
  % degrees of freedom in frequency space 
  numFreq = deg2dim(bw+1)/nSym;
  % TODO: False oversampling factor, see corrosion data example in paper (cubic symmetry)
  oversamplingFactor = length(nodes)/numFreq;
  if oversamplingFactor<1.9 && get_option(varargin,'regularization',1)==0
    warning(['The oversampling factor in the approximation process is ', ...
      num2str(oversamplingFactor),'. This could lead to a bad approximation. ' ...
      'You may should not set the regularization parameter to 0 in the ' ...
      'approximation method.'])
  end
  return
end

% Choose an fixed oversampling factor of 2
oversamplingFactor = 2;
bw = dim2deg(round( length(nodes)*nSym/oversamplingFactor ));

bw = min(bw,getMTEXpref('maxSO3Bandwidth'));

end





% Possibly split the quadrature and eval functions. Therefore do the
% precomputations before the lsqr-Method.

% TODO: Try Cross-Vallidation, if there are to much points 

