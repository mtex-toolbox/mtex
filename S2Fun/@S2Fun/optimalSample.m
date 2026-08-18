function [v,c] = optimalSample(sF,n,varargin)
% optimal discrete sampling points of a spherical density function
%
% Description
%
% |optimalSample| behaves similarly as <S2Fun.discreteSample.html
% |discreteSample|> with the difference, that the sampling points are
% optimized to reproduce the input density function as perfect as possible.
% The price you pay is time. |optimalSample| computes the sampling points by
% solving a minimization problem, which becomes harder the more points you
% want to generate.
%
% The density function is represented by the discrete measure
%
% $$ \mu = \lambda \, \sum_{j=1}^M c_j \, \delta_{v_j}, \qquad \lambda = \int_{S^2} f(v) \,dv, $$
%
% and the directions $v_j$ are moved such that the kernel discrepancy
%
% $$ J(v,c) = \| \mu - f \|_{\psi}^2 = \sum_{n=1}^N \frac{4\pi A_n}{2n+1} \sum_{k=-n}^{n} | \hat{\mu}_n^{k} - \hat{f}_n^{k} |^2 $$
%
% becomes small. Here $A_n$ are the Legendre coefficients of the
% <S2RestrictedDistanceKernel.html restricted distance kernel> and $N$ is the
% |bandwidth|, i.e. only the harmonic degrees up to $N$ are taken into
% account - choose it to match the intended use of the points. The
% minimization is done by a limited memory BFGS iteration along the
% geodesics of the sphere together with an Armijo line search.
%
% *Why L-BFGS and not gradient descent.* $J$ is badly conditioned and the
% convergence rate of gradient descent degrades with exactly that condition
% number, while collecting the curvature of the steps already taken costs
% nothing beyond a few vectors of memory. In contrast to the rotation group
% the sphere is no group, so the tangent plane turns with the node and the
% stored steps have to be parallel transported along every step before they
% may be used again.
%
% Note that the sum above starts at degree 1. The restricted distance kernel
% is only conditionally positive definite, its Legendre coefficient of degree
% 0 being negative, $A_0 = -\frac43 < 0$. Since $Y_0^0$ is constant, the
% degree 0 term of $\mu - f$ equals $\lambda (\sum_j c_j - 1)/\sqrt{4\pi}$
% and hence vanishes for weights that sum up to 1 - which is why it is simply
% dropped.
%
% *Optimizing the weights.* By default the weights are fixed, $c_j = 1/M$,
% and the directions are the only unknowns. If the weights are asked for as a
% second output
%
%   [v,c] = optimalSample(sF,n)
%
% they are optimized alongside the directions. Since a fixed set of
% directions gains an additional $M$ degrees of freedom this way, far fewer
% points are needed to represent $f$ up to a given accuracy. The resulting
% weights are volume fractions and may be passed on directly, e.g. by
% |calcDensity(v,'weights',c)|.
%
% The weights are then restricted to the probability simplex, i.e.
%
% $$ c_j \ge 0, \qquad \sum_{j=1}^M c_j = 1 . $$
%
% This is not merely a cosmetic normalization. Keeping the weights on the
% simplex removes the only degree with a negative kernel coefficient, see
% above - without the constraint $\sum_j c_j = 1$ the functional would be
% unbounded from below and the iteration would simply inflate the weights.
%
% The problem is solved by alternating minimization. For fixed directions $J$
% is a convex least squares functional in $c$ and is decreased with
% <mlsq.html |mlsq|>, which preserves both $\sum_j c_j$ and $c_j \ge 0$. For
% fixed weights the directions are moved as described above.
%
% *The first |warmUp| iterations move the points only.* The update of |mlsq|
% is multiplicative, so a weight that reaches 0 stays 0 - and since the
% gradient with respect to $v_j$ carries the factor $c_j$, such a node is
% frozen in place as well and is lost for good. Started on a grid that
% ignores the density, e.g. <equispacedS2Grid.html |equispacedS2Grid|>, the
% first weight step is drastic and kills a fifth of the nodes before the
% points ever had a chance to move: on the three Gaussian example below with
% 214 nodes and bandwidth 64, 16 weights drop below $10^{-5}$ in iteration 1
% alone, and the method then ends up *worse* than with fixed weights despite
% optimizing over a strictly larger set. Letting the points settle first
% avoids this - with the warm up no weight dies and $J$ ends up about 10
% percent below the unweighted optimum.
%
% *The weights help most where the points are far from optimal.* On
% |abs(S2Fun.smiley)| with 200 points and bandwidth 64 the weights alone
% reduce $J$ by a factor of 16 on the raw <S2Fun.discreteSample.html
% |discreteSample|> nodes, while on nodes that are already driven to
% convergence they only add a few percent - the points have then essentially
% solved the problem on their own. The benefit of the weights is therefore
% that a given accuracy is reached with fewer points and fewer iterations,
% not that the converged optimum is much lower.
%
% Note that the weights buy their accuracy up to |bandwidth| partly at the
% expense of the higher degrees, since concentrating the mass on fewer points
% makes the sample less uniform. Increasing |innerIter| beyond its default of
% 5 spends more work on the weights per outer iteration and does lower $J$
% noticeably, at the price of two additional transforms per inner iteration.
%
% For more details, see
%
% Gräf, Manuel; Potts, Daniel; Steidl, Gabriele (2012). Quadrature Errors, Discrepancies, and Their Relations to Halftoning on the Torus and the Sphere. SIAM Journal on Scientific Computing, 34(5), A2760–A2791. doi:10.1137/100814731
%
% Knezevic, Marko; Landry, Nicholas W. (2015). Procedures for reducing large datasets of crystal orientations using generalized spherical harmonics. Mechanics of Materials, 88, 73–86. doi:10.1016/j.mechmat.2015.04.014
%
% Syntax
%   v = optimalSample(sF,n)
%   v = optimalSample(sF,v)
%   v = optimalSample(sF,n,'bandwidth',128)
%   v = optimalSample(sF,n,'maxIter',1000,'tol',0.005*degree)
%
%   [v,c] = optimalSample(sF,n)                   % optimize the weights, too
%   [v,c] = optimalSample(sF,n,'minWeight',1e-4)
%
% Input
%  sF - @S2Fun
%  n  - number of sampling points
%  v  - @vector3d (starting nodes)
%
% Output
%  v - @vector3d
%  c - weights of the sampling points (non negative, sum up to 1)
%
% Options
%  bandwidth  - harmonic degree to approximate (default = 128), see above
%  maxIter    - number of (outer) iterations (default = 1000)
%  tol        - termination tolerance for the directions (default = 0.01*degree)
%  memory     - secant pairs kept by the L-BFGS iteration (default = 5)
%  weights    - starting weights, fixed if they are not optimized (default = ones(M,1)/M)
%
% The following options apply only if the weights are optimized
%
%  warmUp     - outer iterations that move the points only (default = maxIter/5)
%  innerIter  - mlsq iterations per weight step (default = 5)
%  tolWeights - termination tolerance for the weights (default = 1e-3/M)
%  minWeight  - discard directions with a smaller weight (default = 0, i.e. keep all)
%
% See also
% S2Fun/discreteSample mlsq S2RestrictedDistanceKernel

% TODO: Symmetries, i.e. S2FunHarmonicSym

% polynomials should be integrated exactly until this bandwidth
bw = get_option(varargin,'bandwidth',128);

% optimalSample works only for S2FunHarmonic
sF = S2FunHarmonic(sF,'bandwidth',bw);
sF.bandwidth = bw;

% The weights are optimized only if they are asked for. Otherwise they stay
% at their starting value and the directions are the only unknowns.
optWeights = nargout == 2;

% get starting points
if isa(n,'vector3d')
  v = n;
elseif sF.antipodal
  v = equispacedS2Grid('points',n,'antipodal');
else
  v = equispacedS2Grid('points',n);
end
M = numel(v);
v = v(:);
% the nodes have to carry the antipodal flag of sF, since the difference
% mu - sF of the discrete measure and the density function is formed below
v.antipodal = sF.antipodal;

% specify parameters for the (alternating) descent method
maxIter = get_option(varargin,'maxIter',1000);
tol = get_option(varargin,'tol',0.01*degree);
mem = get_option(varargin,'memory',5);
innerIter = get_option(varargin,'innerIter',5);
warmUp = get_option(varargin,'warmUp',ceil(maxIter/5));
tolWeights = get_option(varargin,'tolWeights',1e-3/M);
minWeight = get_option(varargin,'minWeight',0);

if ~optWeights && ( check_option(varargin,'warmUp') || ...
    check_option(varargin,'innerIter') || check_option(varargin,'tolWeights') ...
    || check_option(varargin,'minWeight') )
  warning(['The options warmUp, innerIter, tolWeights and minWeight apply ' ...
    'only if the weights are optimized. Ask for them as a second output, ' ...
    'i.e. [v,c] = optimalSample(sF,n).'])
end

% Define Restricted Distance Kernel
psi = S2RestrictedDistanceKernel(bw+1);

% for antipodal functions the odd degrees vanish anyway
if sF.antipodal, psi.A(2:2:end) = 0; end

% get integral (mean) weight lambda
lambda = sum(sF);

% starting weights - they have to form a probability distribution, see above
c = get_option(varargin,'weights',ones(M,1)/M);
c = c(:);
if numel(c)~=M
  error('The number of weights does not match the number of points.')
end
if any(c<0)
  error('The weights have to be non negative.')
end
c = c/sum(c);

% The discrepancy J is the squared euclidean norm of the harmonic
% coefficients of mu - sF, weighted by w.^2 = 4*pi*A_n/(2n+1) in degree n.
% Note that w is zero in degree 0, i.e. the degree with the negative kernel
% coefficient is dropped. It does not contribute anyway, as long as
% sum(c) == 1, but dropping it keeps J and its gradients consistent by
% construction. In contrast to SO3 no additional scaling of the coefficients
% is needed, since the spherical harmonics of MTEX are already orthonormal
% with respect to the (unnormalized) surface measure.
w = zeros((bw+1)^2,1);
for l = 1:bw
  w(l^2+1:(l+1)^2) = sqrt( 4*pi * psi.A(l+1)/(2*l+1) );
end

% right hand side of the linear system Psi*c = I solved in the weight step
I = w .* sF.fhat;

% the same kernel without its degree 0 part, used for the gradient w.r.t. v
psi0 = S2Kernel([0;psi.A(2:end)]);

% The nodes change in every iteration, hence the NFSFT plans are set up once
% and the nodes are updated in place. The onCleanup makes sure that they are
% freed, also if the user interrupts with Ctrl-C.
nfsft = nfsftPlan(bw,M);
freePlans = onCleanup(@() nfsft.finalize());

% Step size of the line search along the steepest descent direction, i.e. as
% long as the L-BFGS memory is still empty. It is carried over between the
% iterations and doubled before every line search, so that it can grow as
% well as shrink. Starting each line search at 1 instead would tie the length
% of a step to the magnitude of the gradient, which is proportional to the
% weights and hence of the order 1/M - the nodes would then crawl. Once the
% memory is filled the direction carries that scaling itself and the unit
% step is the natural trial step.
stepSize = 1;

% L-BFGS memory. The columns of S hold the steps taken, those of Y the
% corresponding changes of the gradient, both as plain 3M vectors [x;y;z].
% In contrast to SO(3) the sphere is no group, i.e. there is no global
% trivialization of the tangent bundle: the tangent plane turns with the
% node. The stored pairs are therefore parallel transported along the
% geodesic of every step, see transport below - without that they would be
% added up across different tangent planes and the curvature information
% would be nonsense.
S = []; Y = [];

% harmonic coefficients D of mu - sF and the resulting discrepancy
[resOld,D] = J(nfsft,v,c,sF,w,lambda);

% gradient of the functional with respect to the directions
g = grad_J(nfsft,v,c,D,psi0,lambda);

pC = progressCounter(maxIter);
for i = 1:maxIter

  % ------------------------ (1) optimize weights -------------------------
  % for fixed directions this is a convex least squares problem, which mlsq
  % decreases while maintaining sum(c) = 1 and c >= 0
  cOld = c;
  % During the warm up the weights are left alone, see above. For a single
  % direction the simplex degenerates to the point c = 1, so there is nothing
  % to optimize either - and mlsq would divide by the length of a vanishing
  % search direction.
  if optWeights && M > 1 && i > warmUp
    cNew = mlsq(@(x,flag) Psi(x,flag,nfsft,v,w,lambda),I,c,innerIter,0);
    % guard against the same degeneracy for M > 1, which occurs if the
    % gradient happens to be constant along the simplex
    if all(isfinite(cNew)) && all(cNew>=0) && sum(cNew)>0
      c = cNew/sum(cNew); % also compensates round off in the mass constraint
    end
    % the weights changed, hence the discrepancy and the gradient have to be
    % recomputed
    [resOld,D] = J(nfsft,v,c,sF,w,lambda);
    g = grad_J(nfsft,v,c,D,psi0,lambda);
  end

  % ------------------------ (2) optimize points --------------------------
  % the gradient of the functional with respect to the directions is computed
  % at the end of the previous iteration, resp. above if the weight step has
  % changed the functional in between
  gVec = [g.x(:);g.y(:);g.z(:)];

  gNorm = sqrt(sum(norm(g).^2));

  % a vanishing gradient cannot be improved by any step size
  if gNorm == 0, break, end

  % L-BFGS direction, i.e. the inverse Hessian approximation built from the
  % memory applied to the gradient. With an empty memory this is the negative
  % gradient and the iteration below is plain gradient descent.
  d = twoLoop(gVec,S,Y);

  dir = vector3d(d(1:M),d(M+1:2*M),d(2*M+1:3*M));

  % The direction has to be tangential to v, otherwise the geodesic step
  % below leaves the tangent plane it is meant to follow. The two loop
  % recursion mixes in gradients transported from earlier iterates and hence
  % gives away a little of that, so the normal components are dropped here.
  dir = dir - dot(dir,v).*v;

  dVec = [dir.x(:);dir.y(:);dir.z(:)];

  % the directional derivative of J along dir
  slope = dVec.' * gVec;

  % Safeguard. The memory may have gone stale - the weight step changes the
  % functional the pairs were taken from - and then produce a direction that
  % does not decrease J at all. Drop it and fall back to gradient descent.
  if slope >= 0
    S = []; Y = [];
    dir = -g;
    dVec = -gVec;
    slope = -gNorm.^2;
  end

  % Line search with Armijo, capped such that no node travels more than half
  % a turn - without the cap the step size would keep doubling once the
  % gradient becomes small and every line search would waste its first
  % dozens of trials. Doubling is what pays off along the gradient: starting
  % each line search directly at the cap does lower J per iteration, but the
  % extra backtracking costs more than it gains per second.
  if isempty(S)
    stepSize = min(2*stepSize, pi/max(norm(dir)));
  else
    stepSize = min(1, pi/max(norm(dir)));
  end

  lineSearchFailed = false;
  while true

    % step along the geodesics through v in direction dir
    vNew = geodesicStep(v,dir,stepSize);

    [resNew,DNew] = J(nfsft,vNew,c,sF,w,lambda);

    if resNew < resOld + 1e-4*stepSize*slope % Armijo Condition
      break;
    end

    stepSize = 0.5*stepSize;

    % --- Local Termination ---
    % This is not an error. The weight step may already have brought us to a
    % point where the directions cannot be improved any further, in which
    % case we are simply done.
    if stepSize < 1e-16
      lineSearchFailed = true;
      vNew = v;
      break;
    end
  end

  % --- Global Termination ---
  if lineSearchFailed || ...
      ( max(angle(v,vNew)) < tol && max(abs(c-cOld)) < tolWeights )
    v = vNew;
    break;
  end

  % The gradient in the new nodes. It is taken under the same weights as gVec
  % above, hence the two form a secant pair of one and the same functional -
  % which is what the memory has to consist of.
  gNew = grad_J(nfsft,vNew,c,DNew,psi0,lambda);

  % Everything collected so far lives in the tangent planes of v and has to
  % be carried along to those of vNew before it may be combined with a
  % gradient taken there.
  nDir = norm(dir);
  t = stepSize * nDir;
  V = [v.x(:) v.y(:) v.z(:)];
  U = zeros(M,3);
  ind = nDir > 0;
  U(ind,:) = [dir.x(ind) dir.y(ind) dir.z(ind)] ./ nDir(ind);
  sinT = sin(t(:));
  cosT1 = 1 - cos(t(:));

  sVec = transport(stepSize*dVec,V,U,sinT,cosT1);
  yVec = [gNew.x(:);gNew.y(:);gNew.z(:)] - transport(gVec,V,U,sinT,cosT1);

  if ~isempty(S)
    S = transport(S,V,U,sinT,cosT1);
    Y = transport(Y,V,U,sinT,cosT1);
  end

  % Keep the pair only if it carries positive curvature. Otherwise the
  % inverse Hessian approximation would lose its positive definiteness and
  % with it the guarantee that the next direction is one of descent.
  if sVec.'*yVec > 1e-12 * norm(sVec) * norm(yVec)
    S = [S,sVec]; Y = [Y,yVec]; %#ok<AGROW>
    if size(S,2) > mem, S(:,1) = []; Y(:,1) = []; end
  end

  % update
  v = vNew;
  D = DNew;
  resOld = resNew;
  g = gNew;

  pC.show(i)

end

% Since the weight update of mlsq is multiplicative, a weight that reached 0
% stays 0, i.e. the corresponding direction does not contribute to the sample
% any longer. Optionally discard those directions.
if optWeights && minWeight > 0
  keep = c >= minWeight;
  if ~any(keep)
    warning(['minWeight is larger than every computed weight, hence no ' ...
      'direction is discarded.'])
  else
    v = v(keep);
    c = c(keep);
    c = c/sum(c);
  end
end

% return the sample in the reference frame of the function - in a crystal
% frame it comes back as Miller, with the trivial group when the function
% carries no symmetry (ADR 0003, orientation without symmetry)
if isa(sF,'S2FunHarmonicSym') && isa(sF.CS,'crystalSymmetry')
  v = Miller(v,sF.CS);
elseif ~isa(v,'Miller')
  if isa(sF.frame,'crystalFrame')
    v = Miller(v, crystalSymmetry(sF.frame));
  else
    v.frame = sF.frame;
  end
end

end


function vNew = geodesicStep(v,d,stepSize)
% move every node along the geodesic through v in direction d, i.e.
% vNew = exp_v(stepSize*d). Note that d is tangential to v, hence this stays
% on the sphere. Nodes with a vanishing direction are left untouched.

t = stepSize * norm(d);

vNew = v;
ind = t>0;
vNew(ind) = normalize( cos(t(ind)).*v(ind) + sin(t(ind)).*d(ind)./norm(d(ind)) );

end


function d = twoLoop(g,S,Y)
% The two loop recursion of L-BFGS. It applies the inverse Hessian
% approximation built from the secant pairs in S and Y to the gradient g,
% without ever forming a matrix - only inner products of the stored vectors
% are needed. An empty memory gives the negative gradient.

k = size(S,2);

if k == 0, d = -g; return, end

rho = zeros(k,1);
a = zeros(k,1);

q = g;
for j = k:-1:1
  rho(j) = 1./(Y(:,j).'*S(:,j));
  a(j) = rho(j)*(S(:,j).'*q);
  q = q - a(j)*Y(:,j);
end

% initial inverse Hessian, scaled by the most recent pair - this is the step
% length that makes the unit trial step of the line search the right one
q = q * (S(:,k).'*Y(:,k))/(Y(:,k).'*Y(:,k));

for j = 1:k
  b = rho(j)*(Y(:,j).'*q);
  q = q + S(:,j)*(a(j)-b);
end

d = -q;

end


function W = transport(W,V,U,sinT,cosT1)
% Parallel transport of tangent vectors along the geodesics of a step. Every
% column of W holds one tangent vector per node, stacked as [x;y;z], and V
% and U hold the nodes and the unit directions of the step as M x 3
% matrices. For the geodesic that leaves v in direction u by the angle t
% parallel transport is
%
%   P(w) = w - (u.w) ( sin(t) v + (1-cos(t)) u ) ,
%
% i.e. the component of w along u is turned with the geodesic while the one
% orthogonal to it stays where it is. Nodes that did not move have sin(t) = 0
% and 1-cos(t) = 0 and are left untouched by the same formula.

M = size(V,1);
k = size(W,2);

W = reshape(W,M,3,k);

% the projection of every stored vector onto the direction of the step
a = sum(W .* U,2);

W = W - a .* (sinT.*V + cosT1.*U);

W = reshape(W,3*M,k);

end


function y = Psi(x,flag,nfsft,v,w,lambda)
% The linear operator of the weight step and its adjoint, in the form
% expected by mlsq. It maps the weights to the kernel weighted harmonic
% coefficients of the discrete measure mu,
%
%   Psi = diag(w) * lambda * adjointNFSFT ,
%
% such that J = norm(Psi*c-I)^2. Note that Psi is never set up as a matrix -
% mlsq only needs its two directions, which are exactly the adjoint and the
% forward spherical Fourier transform.

nfsft.setNodes(v);

if strcmp(flag,'notransp')

  % adjoint NFSFT
  y = w .* (lambda * nfsft.adjoint(x));

else

  % Psi' is the evaluation of the w weighted coefficient vector at the nodes
  y = lambda * real(nfsft.trafo(w.*x));

end

end


function [res,D] = J(nfsft,v,c,sF,w,lambda)
% harmonic coefficients D of mu - sF and the resulting discrepancy. D is
% reused by the gradient below.

nfsft.setNodes(v);

% adjoint NFSFT gives the harmonic coefficients of the discrete measure mu.
% Use sF as a template to keep bandwidth, symmetry and plotting convention.
D = sF;
D.fhat = lambda * nfsft.adjoint(c) - sF.fhat;

res = sum(abs(w.*D.fhat).^2);

end


function tanV = grad_J(nfsft,v,c,D,psi0,lambda)
% gradient of the discrepancy with respect to the directions v

% convolute with the Distance kernel, degree 0 excluded. Since conv
% multiplies degree n by A_n/(2n+1), this yields exactly the weights w.^2.
C = conv(D,(4*pi)*psi0);

% evaluate spherical gradient on v
nfsft.setNodes(v);
tanV = 2*lambda*nfsft.grad(C).*c;

end


function Test %#ok<DEFNU>

% Example of the paper of Gräf, Potts, Steidl
q = [xvector,yvector,zvector];
sF = S2FunHandle(@(x) real(exp(-5*acos(dot(x,q(1))).^2) + exp(-5*acos(dot(x,q(2))).^2) + exp(-5*acos(dot(x,q(3))).^2)) );

% another example
% sF = abs(S2Fun.smiley);

v = optimalSample(sF,200,'bandwidth',64);

% the same with optimized weights
[vw,c] = optimalSample(sF,200,'bandwidth',64);

% plot solution
plot3d(sF,'upper')
hold on
scatter3d(v,'MarkerSize',3,'MarkerEdgeColor','k','MarkerFaceColor','k')
scatter3d(vw,c/max(c),'MarkerSize',5)
hold off

end
