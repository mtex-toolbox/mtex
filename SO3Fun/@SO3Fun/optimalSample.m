function [ori,c] = optimalSample(f,n,varargin)
% optimal discrete sampling points of an orientation density function
%
% Description
%
% |optimalSample| behaves similarly as <SO3Fun.discreteSample.html
% |discreteSample|> with the difference, that the sampling points are
% optimized to reproduce the input density function as perfect as possible.
% The price you pay is time. |optimalSample| computes the sampling points by
% solving a minimization problem, which becomes harder the more points you
% want to generate.
%
% The density function is represented by the discrete measure
%
% $$ \mu = \lambda \, \sum_{j=1}^M c_j \, \delta_{R_j}, \qquad \lambda = \int_{SO(3)} f(R) \,dR, $$
%
% and the orientations $R_j$ are moved such that the kernel discrepancy
%
% $$ J(R,c) = \| \mu - f \|_{\psi}^2 = \sum_{n=1}^N \frac{8\pi^2 A_n}{2n+1} \sum_{k,l=-n}^{n} | \hat{\mu}_n^{k,l} - \hat{f}_n^{k,l} |^2 $$
%
% becomes small. Here $A_n$ are the Chebyshev coefficients of the
% <SO3RestrictedDistanceKernel.html restricted distance kernel> and $N$ is
% the |bandwidth|, i.e. only the harmonic degrees up to $N$ are taken into
% account - choose it to match the intended use of the orientations. The
% minimization is done by gradient descent with Armijo line search.
%
% Note that the sum above starts at degree 1. The restricted distance kernel
% is only conditionally positive definite, its Chebyshev coefficient of
% degree 0 being negative, $A_0 = -\frac{16\sqrt2}{3\pi} < 0$. Since $D_0$ is
% constant, the degree 0 term of $\mu - f$ equals
% $\lambda (\sum_j c_j - 1)/(\sqrt{8}\pi)$ and hence vanishes for weights
% that sum up to 1 - which is why it is simply dropped.
%
% *Optimizing the weights.* By default the weights are fixed, $c_j = 1/M$,
% and the orientations are the only unknowns. If the weights are asked for as
% a second output
%
%   [ori,c] = optimalSample(f,n)
%
% they are optimized alongside the orientations. Since a fixed set of
% orientations gains an additional $M$ degrees of freedom this way, far fewer
% orientations are needed to represent $f$ up to a given accuracy. The
% resulting weights are volume fractions and may be passed on directly, e.g.
% by |calcDensity(ori,'weights',c)|.
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
% The problem is solved by alternating minimization. For fixed orientations
% $J$ is a convex least squares functional in $c$ and is decreased with
% <mlsq.html |mlsq|>, which preserves both $\sum_j c_j$ and $c_j \ge 0$. For
% fixed weights the orientations are moved as described above.
%
% *Choose the bandwidth to match the intended use.* The weights buy their
% accuracy up to |bandwidth| partly at the expense of the higher degrees,
% since concentrating the mass on fewer orientations makes the sample less
% uniform. On the |SO3Fun.dubna| ODF with 200-300 orientations the weighted
% sample beats the equally weighted one in the L1 error of the reconstructed
% density by 4-8 percent at every kernel halfwidth between 5 and 12 degree -
% but only if |bandwidth| is chosen large enough (64 in that test). With the
% default of 32 the advantage is present for halfwidth 10 degree and above
% and turns into a disadvantage below. Note also that the improvement is in
% the L1 error; measured in the L2 error, which punishes the deviation of the
% peaks much harder, the equally weighted sample can remain the better choice
% at halfwidths well below the optimized bandwidth.
%
% *Starting from a grid that ignores the density* - e.g.
% <equispacedSO3Grid.html |equispacedSO3Grid|> instead of the default
% <SO3Fun.discreteSample.html |discreteSample|> - the first weight step is
% drastic and kills nodes before they ever had a chance to move. Since the
% update of |mlsq| is multiplicative, a weight that reaches 0 stays 0, and
% since the gradient with respect to $R_j$ carries the factor $c_j$, such a
% node is frozen in place as well and is lost for good. Use |warmUp| to move
% the orientations only for the first iterations in that case.
%
% For more details, see
%
% Gräf, Manuel; Potts, Daniel; Steidl, Gabriele (2012). Quadrature Errors, Discrepancies, and Their Relations to Halftoning on the Torus and the Sphere. SIAM Journal on Scientific Computing, 34(5), A2760–A2791. doi:10.1137/100814731
%
% Knezevic, Marko; Landry, Nicholas W. (2015). Procedures for reducing large datasets of crystal orientations using generalized spherical harmonics. Mechanics of Materials, 88, 73–86. doi:10.1016/j.mechmat.2015.04.014
%
% Syntax
%   ori = optimalSample(f,n)
%   ori = optimalSample(f,ori)
%   ori = optimalSample(f,n,'bandwidth',32)
%   ori = optimalSample(f,n,'maxIter',1000,'tol',0.05*degree)
%
%   [ori,c] = optimalSample(f,n)                    % optimize the weights, too
%   [ori,c] = optimalSample(f,n,'minWeight',1e-4)
%
% Input
%  f - @SO3Fun
%  n - number of sampling points
%  ori - @rotation (starting nodes)
%
% Output
%  ori - @rotation
%  c - weights of the sampling points (non negative, sum up to 1)
%
% Options
%  bandwidth  - harmonic degree to approximate (default = 32), see above
%  maxIter    - number of (outer) iterations (default = 100)
%  tol        - termination tolerance for the orientations (default = 0.1*degree)
%  weights    - starting weights, fixed if they are not optimized (default = ones(M,1)/M)
%
% The following options apply only if the weights are optimized
%
%  warmUp     - outer iterations that move the orientations only (default = 0)
%  innerIter  - mlsq iterations per weight step (default = 5)
%  tolWeights - termination tolerance for the weights (default = 1e-3/M)
%  minWeight  - discard orientations with a smaller weight (default = 0, i.e. keep all)
%
% See also
% SO3Fun/discreteSample mlsq SO3RestrictedDistanceKernel

% TODO: Symmetries and input is orientation
% TODO: antipodal

% polynomials should be integrated exactly until this bandwidth
bw = get_option(varargin,'bandwidth',32);

% load density function
f = SO3FunHarmonic(f,'bandwidth',bw);
f.bandwidth = bw;

% The weights are optimized only if they are asked for. Otherwise they stay
% at their starting value and the orientations are the only unknowns.
optWeights = nargout == 2;

% get starting points
if isa(n,'rotation')
  ori = n;
else
  ori = equispacedSO3Grid(f.CS,f.SS,'points',n);
end
M = numel(ori);
% the nodes have to carry the symmetries of f, since the difference mu - f of
% the discrete measure and the density function is formed below
ori = orientation(ori(:),f.CS,f.SS);

% specify parameters for the (alternating) gradient method
maxIter = get_option(varargin,'maxIter',100);
tol = get_option(varargin,'tol',0.1*degree);
innerIter = get_option(varargin,'innerIter',5);
warmUp = get_option(varargin,'warmUp',0);
tolWeights = get_option(varargin,'tolWeights',1e-3/M);
minWeight = get_option(varargin,'minWeight',0);

if ~optWeights && ( check_option(varargin,'warmUp') || ...
    check_option(varargin,'innerIter') || check_option(varargin,'tolWeights') ...
    || check_option(varargin,'minWeight') )
  warning(['The options warmUp, innerIter, tolWeights and minWeight apply ' ...
    'only if the weights are optimized. Ask for them as a second output, ' ...
    'i.e. [ori,c] = optimalSample(f,n).'])
end

% Define Restricted Distance Kernel
psi = SO3RestrictedDistanceKernel(bw+1);

% get integral (mean) weight lambda
lambda = sum(f);

% starting weights - they have to form a probability distribution, see above
c = get_option(varargin,'weights',ones(M,1)/M);
c = c(:);
if numel(c)~=M
  error('The number of weights does not match the number of orientations.')
end
if any(c<0)
  error('The weights have to be non negative.')
end
c = c/sum(c);

% J is the squared euclidean norm of the Wigner coefficients of mu - f,
% weighted by w.^2 = 8*pi^2*A_n/(2n+1) - degree 0 is dropped, it does not contribute
w = zeros(deg2dim(bw+1),1);
for l = 1:bw
  w(deg2dim(l)+1:deg2dim(l+1)) = sqrt( 8*pi^2 * psi.A(l+1)/(2*l+1) );
end

% right hand side of the linear system Psi*c = I solved in the weight step
I = w .* ((sqrt(8)*pi) * f.fhat);

% the same kernel without its degree 0 part, used for the gradient w.r.t. ori
psi0 = SO3Kernel([0;psi.A(2:end)]);

% carry the step size over and double it, so that it can grow as well as shrink
stepSize = 1;

% Wigner coefficients D of mu - f and the resulting discrepancy
[resOld,D] = J(ori,c,f,w,lambda,bw);

pC = progressCounter(maxIter);
for i = 1:maxIter

  % ------------------------ (1) optimize weights -------------------------
  % for fixed orientations this is a convex least squares problem, solved by mlsq
  cOld = c;
  % during the warm up, and for a single orientation, there is nothing to optimize
  if optWeights && M > 1 && i > warmUp
    cNew = mlsq(@(x,flag) Psi(x,flag,ori,f,w,lambda,bw),I,c,innerIter,0);
    % guard against the same degeneracy for M > 1, which occurs if the
    % gradient happens to be constant along the simplex
    if all(isfinite(cNew)) && all(cNew>=0) && sum(cNew)>0
      c = cNew/sum(cNew); % also compensates round off in the mass constraint
    end
    % the weights changed, hence the discrepancy has to be recomputed
    [resOld,D] = J(ori,c,f,w,lambda,bw);
  end

  % ---------------------- (2) optimize orientations ----------------------
  % compute gradient of the functional with respect to the orientations
  g = grad_J(ori,c,D,psi0,lambda);

  gNorm = sqrt(sum(norm(g).^2));

  % a vanishing gradient cannot be improved by any step size
  if gNorm == 0, break, end

  % line search with Armijo, capped so that nothing travels more than half a turn
  stepSize = min(2*stepSize, pi/max(norm(g)));

  lineSearchFailed = false;
  while true

    % gradient step
    oriNew = exp(-stepSize*g,ori);

    [resNew,DNew] = J(oriNew,c,f,w,lambda,bw);

    if resNew < resOld - 1e-4*stepSize*gNorm.^2 % Armijo Condition
      break;
    end

    stepSize = 0.5*stepSize;

    % --- local termination: the weight step may have left nothing to improve
    if stepSize < 1e-16
      lineSearchFailed = true;
      oriNew = ori;
      break;
    end
  end

  % --- Global Termination ---
  if lineSearchFailed || ...
      ( max(angle(ori,oriNew)) < tol && max(abs(c-cOld)) < tolWeights )
    ori = oriNew;
    break;
  end

  % update
  ori = oriNew;
  D = DNew;
  resOld = resNew;

  pC.show(i)

end

% the mlsq update is multiplicative, so a weight that reached 0 stays 0
if optWeights && minWeight > 0
  keep = c >= minWeight;
  if ~any(keep)
    warning(['minWeight is larger than every computed weight, hence no ' ...
      'orientation is discarded.'])
  else
    ori = ori(keep);
    c = c(keep);
    c = c/sum(c);
  end
end

end


function y = Psi(x,flag,ori,f,w,lambda,bw)
% The linear operator of the weight step and its adjoint, in the form
% expected by mlsq. It maps the weights to the kernel weighted Wigner
% coefficients of the discrete measure mu,
%
%   Psi = diag(w) * lambda/(sqrt(8)*pi) * adjointNFSOFT ,
%
% such that J = norm(Psi*c-I)^2. Note that Psi is never set up as a matrix -
% mlsq only needs its two directions, which are exactly the adjoint and the
% forward Wigner transform.

if strcmp(flag,'notransp')

  % adjoint NFSOFT
  mu = SO3FunHarmonic.adjointNFSOFT(ori,x,'bandwidth',bw);
  % the constructor truncates vanishing coefficients, so restore the length
  mu.bandwidth = bw;

  y = w .* ( (lambda/(sqrt(8)*pi)) * mu.fhat );

else

  % Psi' evaluates the w weighted coefficients, f is reused as a template
  G = f;
  G.fhat = w.*x;

  y = (lambda/(sqrt(8)*pi)) * real(G.eval(ori));

end

end


function [res,D] = J(ori,c,f,w,lambda,bw)
% Wigner coefficients D of mu - f and the resulting discrepancy. D is reused
% by the gradient below.

% adjoint NFSOFT
mu = SO3FunHarmonic.adjointNFSOFT(ori,c,'bandwidth',bw);
mu.bandwidth = bw;
% In case of symmetries: The output SO3FunHarmonic has to be symmetrised,
% which is already internally done in the construction of the SO3FunHarmonic.

D = (lambda/(sqrt(8)*pi)) * mu - (sqrt(8)*pi) * f;
D.bandwidth = bw;

res = sum(abs(w.*D.fhat).^2);

end


function tanV = grad_J(ori,c,D,psi0,lambda)
% gradient of the discrepancy with respect to the orientations

% convolute with the Distance kernel, degree 0 excluded
C = conv(D,(8*pi^2)*psi0);

% evaluate rotational gradient on ori
tanV = 2*lambda*real( (1/(sqrt(8)*pi)) * C.grad(ori) ).*c;
% In case of symmetries: The handling with the symmetries is slightly more
% difficult for the SO3VectorField-objects.

end


function Test %#ok<DEFNU>

setMTEXpref('EulerAngleConvention','Bunge')

f = SO3Fun.dubna;
f = SO3FunHarmonic(f);

ori = optimalSample(f,100);

% the same with optimized weights
[oriW,c] = optimalSample(f,100);

% compare the reconstructed densities
calcError(calcDensity(oriW,'weights',c,'halfwidth',12*degree),f)
calcError(calcDensity(ori,'halfwidth',12*degree),f)

plot3d(f,'AxisAngle','complete')
hold on
plot(oriW,'AxisAngle','all','MarkerSize',4)
hold off

end
