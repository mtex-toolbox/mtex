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
% where $f$ may be any nonnegative function - it does not have to be
% normalized, since scaling $f$ multiplies the functional below by
% $\lambda^2$ and leaves both the optimal directions and the optimal weights
% exactly where they are.
%
% The directions $v_j$ are moved such that the kernel discrepancy
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
% Plain gradient descent is the same iteration with an empty memory,
%
%   v = optimalSample(sF,n,'memory',0)
%
% which |'method','steepestDescent'| says as well.
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
% The weights have to stay on the probability simplex, i.e.
%
% $$ c_j \ge 0, \qquad \sum_{j=1}^M c_j = 1 . $$
%
% This is not merely a cosmetic normalization. Keeping the weights there
% removes the only degree with a negative kernel coefficient, see above -
% without the constraint $\sum_j c_j = 1$ the functional would be unbounded
% from below and the iteration would simply inflate the weights.
%
% Both constraints are met by construction, since the weights enter through a
% softmax, $c_j = \exp(z_j) / \sum_k \exp(z_k)$. The unknowns are then $(v,z)$
% without any constraint left, and directions and weights are moved by *one*
% L-BFGS iteration - parallel transport concerns the directions, the softmax
% block is euclidean. The gradient with respect to the weights,
%
% $$ \frac{\partial J}{\partial c_j} = 2 \lambda \, (\psi * (\mu - f))(v_j), $$
%
% is the value of the very convolution whose gradient moves the directions
% and costs one additional transform per iteration.
%
% *The first |warmUp| iterations move the points only.* Started on a grid
% that ignores the density, e.g. <equispacedS2Grid.html |equispacedS2Grid|>,
% the weights would otherwise concentrate on the few points that happen to
% lie well before the points ever had a chance to move. Letting the points
% settle first is measurably better: on |abs(S2Fun.smiley)| with 100 points
% and bandwidth 32 the warm up buys a factor 2.5 in $J$.
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
% makes the sample less uniform.
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
%   v = optimalSample(sF,n,'method','steepestDescent')
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
%  maxIter    - number of iterations (default = 1000)
%  tol        - termination tolerance for the directions (default = 0.01*degree)
%  method     - 'lbfgs' (default), or 'steepestDescent' for an empty memory
%  memory     - secant pairs kept by the L-BFGS iteration (default = 5)
%  weights    - starting weights, fixed if they are not optimized (default = ones(M,1)/M)
%
% The following options apply only if the weights are optimized
%
%  warmUp     - iterations that move the points only (default = maxIter/5)
%  tolWeights - termination tolerance for the weights (default = 1e-3/M)
%  tolJ       - terminate below this relative decrease of J (default = 1e-4)
%  minWeight  - discard directions with a smaller weight (default = 0, i.e. keep all)
%
% See also
% S2Fun/discrepancy S2Fun/discreteSample S2RestrictedDistanceKernel

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

% specify parameters for the descent method
maxIter = get_option(varargin,'maxIter',1000);
tol = get_option(varargin,'tol',0.01*degree);
mem = get_option(varargin,'memory',5);

% plain gradient descent is the iteration with an empty memory, see above
method = lower(get_option(varargin,'method','lbfgs'));
switch method
  case {'lbfgs','l-bfgs','quasinewton'}
  case {'steepestdescent','gradientdescent','gradient','steepest'}
    mem = 0;
  otherwise
    error(['Unknown method ''%s''. optimalSample knows ''lbfgs'' and ' ...
      '''steepestDescent''.'],method)
end
warmUp = get_option(varargin,'warmUp',ceil(maxIter/5));

% the warm up has to leave one iteration for the weights, see above
warmUp = min(warmUp,maxIter-1);
tolWeights = get_option(varargin,'tolWeights',1e-3/M);
tolJ = get_option(varargin,'tolJ',1e-4);
minWeight = get_option(varargin,'minWeight',0);

% the kernel, and the weights its discrepancy puts on the harmonic coefficients
[w,psi] = kernelWeights(bw,sF.antipodal);

% The mass lambda of the density. Scaling f multiplies J by lambda^2 and
% leaves its minimizer where it is, so the sample does not depend on how f is
% scaled - but the step sizes of the descent would. Normalize the function
% and the iteration is the same one for any nonnegative input.
lambda = sum(sF);
if ~(lambda > 0)
  error(['optimalSample needs a nonnegative function with a positive ' ...
    'integral, this one integrates to %g.'],lambda)
end
sF.fhat = sF.fhat / lambda;

% starting weights - they have to form a probability distribution, see above
c = sampleWeights(M,varargin{:});

% the softmax variables behind the weights - the block is empty and the
% iteration is the one over the directions alone if the weights are fixed
if optWeights && M > 1, z = log(c); else, z = zeros(0,1); end

% the same kernel without its degree 0 part, used for the gradient w.r.t. v
psi0 = S2Kernel([0;psi.A(2:end)]);

% the nodes change in every iteration, so set the plans up once and update in place
nfsft = nfsftPlan(bw,M);
freePlans = onCleanup(@() nfsft.finalize());

% steepest descent step size, carried over and doubled so that it can grow as
% well as shrink - starting at 1 would tie it to the gradient, which is O(1/M)
stepSize = 1;

% L-BFGS memory. The columns of S hold the steps taken, those of Y the
% corresponding changes of the gradient, as the plain vectors [x;y;z;softmax].
% In contrast to SO(3) the sphere is no group, i.e. there is no global
% trivialization of the tangent bundle: the tangent plane turns with the
% node. The direction block of the stored pairs is therefore parallel
% transported along the geodesic of every step, see transport below - without
% that they would be added up across different tangent planes and the
% curvature information would be nonsense.
S = []; Y = [];

% harmonic coefficients D of mu - sF and the resulting discrepancy
[resOld,D] = J(nfsft,v,c,sF,w);

% whether g and gZ below still are the gradient in the current point. L-BFGS
% needs the gradient in the new point anyway, to form the secant pair, and
% carries it over to the next iteration; steepest descent does not and simply
% recomputes it.
gValid = false;
moveWeightsOld = false;

pC = progressCounter(maxIter);
for i = 1:maxIter

  % the weights join the iteration once the points have settled, see above
  moveWeights = ~isempty(z) && i > warmUp;

  % The iteration that lets the weights in starts a new problem: the gradient
  % carried over from the warm up has no weight block yet, the secant pairs
  % describe the directions alone, and the step size the line search shrank
  % for them is orders of magnitude too small for the softmax block.
  weightsEnter = moveWeights && ~moveWeightsOld;
  if weightsEnter, gValid = false; S = []; Y = []; end
  moveWeightsOld = moveWeights;

  % ------------------------------ gradient -------------------------------
  if ~gValid
    g = grad_J(nfsft,v,c,D,psi0);
    if moveWeights
      gZ = grad_z(nfsft,c,D,w);
    else
      gZ = zeros(numel(z),1);
    end
  end
  gValid = false;

  gVec = [g.x(:);g.y(:);g.z(:);gZ];

  gNorm = norm(gVec);

  % a vanishing gradient cannot be improved by any step size
  if gNorm == 0, break, end

  % L-BFGS direction - with an empty memory this is the negative gradient
  d = lbfgsTwoLoop(gVec,S,Y);

  dir = vector3d(d(1:M),d(M+1:2*M),d(2*M+1:3*M));

  % the two loop recursion mixes in transported gradients and gives away a
  % little of the tangentiality the geodesic step below relies on. The nodes
  % carry the antipodal flag of sF, for which dot returns |v.dir|.
  dir = dir - dot(dir,v,'noAntipodal').*v;

  dZ = d(3*M+1:end);
  if ~moveWeights, dZ = zeros(numel(z),1); end

  dVec = [dir.x(:);dir.y(:);dir.z(:);dZ];

  % the directional derivative of J along dir
  slope = dVec.' * gVec;

  % a stale memory may give a direction that does not decrease J - drop it
  if slope >= 0
    S = []; Y = [];
    dir = -g;
    dZ = -gZ;
    dVec = -gVec;
    slope = -gNorm.^2;
  end

  % cap the step so that no node travels more than half a turn and a single
  % step cannot saturate the softmax
  cap = pi/max(norm(dir));
  if any(dZ ~= 0), cap = min(cap, 1/max(abs(dZ))); end

  % line search with Armijo - a restart starts at the largest admissible step
  if weightsEnter
    stepSize = cap;
  elseif isempty(S)
    stepSize = min(2*stepSize, cap);
  else
    stepSize = min(1, cap);
  end

  lineSearchFailed = false;
  while true

    % step along the geodesics through v in direction dir
    vNew = geodesicStep(v,dir,stepSize);
    zNew = z + stepSize*dZ;
    cNew = softmax(zNew,c);

    [resNew,DNew] = J(nfsft,vNew,cNew,sF,w);

    if resNew < resOld + 1e-4*stepSize*slope % Armijo Condition
      break;
    end

    stepSize = 0.5*stepSize;

    % --- local termination: there may be nothing left to improve
    if stepSize < 1e-16
      lineSearchFailed = true;
      vNew = v; zNew = z; cNew = c;
      break;
    end
  end

  % --- Global Termination ---
  % Once the weights are unknowns as well, a small step is no longer a sign
  % of convergence: the weights approach their optimum in many steps that are
  % individually below tolWeights, and whether the very first of them happens
  % to fall under it is a matter of luck. Ask the functional itself instead.
  % The iteration that lets the weights in is a restart with an empty memory,
  % hence its step says nothing about convergence either.
  converged = ~weightsEnter && ...
    max(angle(v,vNew)) < tol && max(abs(cNew-c)) < tolWeights;
  if ~isempty(z)
    converged = converged && resOld - resNew < tolJ * resOld;
  end

  if lineSearchFailed || converged
    v = vNew; z = zNew; c = cNew;
    % During the warm up the weights are held fixed, hence c == cNew and the
    % test above reduces to the one on the directions alone. Returning here
    % would hand back the equal weights the caller asked to have optimized,
    % without the weights ever having moved - which is what happens as soon
    % as the directions converge in fewer iterations than the warm up is
    % long. End the warm up instead and let the weights in.
    if ~isempty(z) && i <= warmUp
      warmUp = i;
      [resOld,D] = J(nfsft,v,c,sF,w);
      % the nodes moved, hence the gradient carried over refers to the old ones
      gValid = false;
      continue
    else
      break;
    end
  end

  % The gradient in the new point. It is carried over to the next
  % iteration, so forming the secant pair costs nothing extra.
    gNew = grad_J(nfsft,vNew,cNew,DNew,psi0);
    if moveWeights
      gZNew = grad_z(nfsft,cNew,DNew,w);
    else
      gZNew = zeros(numel(z),1);
    end

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
    yVec = [gNew.x(:);gNew.y(:);gNew.z(:);gZNew] - transport(gVec,V,U,sinT,cosT1);

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

    g = gNew;
    gZ = gZNew;
    gValid = true;

  % update
  v = vNew;
  z = zNew;
  c = cNew;
  D = DNew;
  resOld = resNew;

  pC.show(i)

end

% drop the directions that carry next to no mass
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

% return the sample in the reference frame of the function
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


function c = softmax(z,c)
% the weights behind the softmax variables - fixed weights have no z at all

if isempty(z), return, end

z = z - max(z);
c = exp(z);
c = c/sum(c);

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

function W = transport(W,V,U,sinT,cosT1)
% Parallel transport of tangent vectors along the geodesics of a step. Every
% column of W holds one tangent vector per node, stacked as [x;y;z], followed
% by the softmax block, and V and U hold the nodes and the unit directions of
% the step as M × 3 matrices. For the geodesic that leaves v in direction u
% by the angle t parallel transport is
%
%   P(w) = w - (u.w) ( sin(t) v + (1-cos(t)) u ) ,
%
% i.e. the component of w along u is turned with the geodesic while the one
% orthogonal to it stays where it is. Nodes that did not move have sin(t) = 0
% and 1-cos(t) = 0 and are left untouched by the same formula. The softmax
% block is euclidean and passes through.

M = size(V,1);
k = size(W,2);

WZ = W(3*M+1:end,:);

W = reshape(W(1:3*M,:),M,3,k);

% the projection of every stored vector onto the direction of the step
a = sum(W .* U,2);

W = W - a .* (sinT.*V + cosT1.*U);

W = [reshape(W,3*M,k);WZ];

end


function [res,D] = J(nfsft,v,c,sF,w)
% harmonic coefficients D of mu - sF and the resulting discrepancy. D is
% reused by the gradients below.

nfsft.setNodes(v);

% adjoint NFSFT gives the harmonic coefficients of the discrete measure mu.
% Use sF as a template to keep bandwidth, symmetry and plotting convention.
D = sF;
D.fhat = nfsft.adjoint(c) - sF.fhat;

res = sum(abs(w.*D.fhat).^2);

end


function tanV = grad_J(nfsft,v,c,D,psi0)
% gradient of the discrepancy with respect to the directions v

% convolute with the Distance kernel, degree 0 excluded. Since conv
% multiplies degree n by A_n/(2n+1), this yields exactly the weights w.^2.
C = conv(D,(4*pi)*psi0);

% evaluate spherical gradient on v
nfsft.setNodes(v);
tanV = 2*nfsft.grad(C).*c;

end


function gZ = grad_z(nfsft,c,D,w)
% gradient with respect to the softmax variables. The nodes are the ones D
% was taken at, hence no setNodes is needed here.

% dJ/dc is the same convolution grad_J differentiates, evaluated at the nodes
gC = 2*real(nfsft.trafo(w.^2.*D.fhat));

% chain rule of the softmax
gZ = c .* (gC - c.'*gC);

end


function Test %#ok<DEFNU>

% Example of the paper of Gräf, Potts, Steidl
q = [xvector,yvector,zvector];
sF = S2FunHandle(@(x) real(exp(-5*acos(dot(x,q(1))).^2) + exp(-5*acos(dot(x,q(2))).^2) + exp(-5*acos(dot(x,q(3))).^2)) );

% another example
% sF = abs(S2Fun.smiley)

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
