function [c_book, conds, info] = ...
    solve_lsq_book_constsize(W_book, G_book, f_book, varargin)
%
% Each page defines one weighted local least-squares problem. The columns of
% the weighted design matrix are normalized before diagnostics and regularization.
%
% input:
%   W_book : nn  x 1    x N      local weights
%   G_book : nn  x dim  x N      local basis values
%   f_book : nn  x numf x N      local function values
%
% output:
%   c_book : dim x numf x N      local coefficient vectors
%   conds  : N x 1               conditions of the solved normalized Gram systems
%   info   : struct              additional regularization diagnostics
%
% options:
%   regularize
%   mincond            center amplification where activation starts
%   maxcond            center amplification where full correction is used
%   targetcond         inverse-amplification bound reached at full correction
%   basis_degrees      degree assigned to every basis column
%   degree_laplace_shift shift in ell*(ell+shift); 1 on S2, 2 on S3
%   eval_vector        basis values at the evaluation point (dim x 1 x N)
%   numerical_cond_max condition cap for the nuisance block (default 1e10)
%
% flags:
%   centered_evaluation  the evaluation vector is the first basis direction
%
% The local systems are solved from the normalized normal equations, with one
% step of iterative refinement wherever no regularization is active. The
% evaluation direction is protected and only its orthogonal complement is
% regularized; one scalar parameter is chosen by bisection to reach the
% inverse-amplification target.
%

regularize = check_option(varargin, {'regularize', 'regularization'});
centeredEvaluation = check_option(varargin, ...
  {'centered_evaluation', 'centered evaluation'});

colNormTol = 1e-14;
eigFloorRel = 1e-14;

% Degree weights are proportional to [ell(ell+shift)]^s. The smallest positive
% weight is normalized to one; s = 1 gives a moderate first hierarchy.
degreeExponent = 1;
degreeLaplaceShift = get_option(varargin, ...
  {'degree_laplace_shift', 'degree laplace shift'}, 1, 'double');
if isempty(degreeLaplaceShift), degreeLaplaceShift = 1; end
degreeLaplaceShift = max(real(degreeLaplaceShift), 0);
numericalCondMax = get_option(varargin, ...
  {'numerical_cond_max', 'numerical cond max'}, 1e10, 'double');
if isempty(numericalCondMax), numericalCondMax = 1e10; end
numericalCondMax = max(real(numericalCondMax), 10);

% matrix dimensions
dim = size(G_book, 2);
N = size(G_book, 3);

% form weighted design matrices and normalize the mean weight on every page
W_book = max(real(W_book), 0);
meanW = max(mean(W_book, 1), realmin);
sqrtW_book = sqrt(W_book ./ meanW);

B_book = sqrtW_book .* G_book;
fw_book = sqrtW_book .* f_book;
clear G_book f_book W_book sqrtW_book;

% normalize columns; regularization therefore does not depend on basis scaling
% vecnorm avoids the two full-size temporaries of sqrt(sum(abs(B).^2))
s_book = vecnorm(B_book, 2, 1);
pageScale = max(s_book, [], 2);
s_floor = max(realmin, colNormTol .* pageScale);
s_book = max(s_book, s_floor);
B_book = B_book ./ s_book;
s_book = permute(s_book, [2, 1, 3]);

% The ordinary unregularized path remains the rectangular least-squares solve.
% Only diagnostics requested through the third output require the Gram matrix.
if ~regularize && nargout <= 2
  c_book = pagemldivide(B_book, fw_book) ./ s_book;

  if nargout > 1
    singval = pagesvd(B_book);
    [conds, ~, ~] = conditionsFromSingularValues(singval, eigFloorRel);
  end
  return;
end

% normalized Gram matrices and right-hand sides
% the transpose flag of pagemtimes keeps the adjoint book from being formed
H_book = pagemtimes(B_book, 'ctranspose', B_book, 'none');
H_book = (H_book + conj(permute(H_book, [2, 1, 3]))) / 2;

if regularize
  rhs_book = pagemtimes(B_book, 'ctranspose', fw_book, 'none');
end

% evaluation direction in normalized coefficient coordinates
[g_book, centeredEvaluation] = getEvaluationVector( ...
  dim, N, B_book, centeredEvaluation, varargin);

if centeredEvaluation
  [H_num, H_perp, C0_book, b_book, a_book, ...
      numericalRidge, centerAmplification] = ...
    analyzeCenteredDirection(H_book, numericalCondMax, eigFloorRel);
else
  % Evaluation uses g.'*c, hence conj(g) is its Riesz vector for complex bases.
  q_book = conj(g_book) ./ s_book;
  qnorm = sqrt(sum(abs(q_book).^2, 1));
  u_book = q_book ./ max(qnorm, realmin);
  [H_num, H_perp, numericalRidge, centerAmplification] = ...
    analyzeGeneralDirection(H_book, u_book, numericalCondMax, eigFloorRel);
  C0_book = [];
  b_book = [];
  a_book = [];
end

% condition diagnostics of the unregularized Gram matrix
if nargout > 1
  eigUnreg = pageeig(H_book);
  [conds_unreg, maxeig, mineig] = ...
    conditionsFromEigenvalues(eigUnreg, eigFloorRel);
end

% unregularized coefficient solve, but return the directional diagnostics used
% by the automatic parameter calibration
if ~regularize
  c_book = pagemldivide(B_book, fw_book) ./ s_book;
  conds = conds_unreg;

  if nargout > 2
    info = makeInfo(conds_unreg, conds_unreg, maxeig, mineig, ...
      maxeig, mineig, centerAmplification, centerAmplification, ...
      numericalRidge, zeros(N,1), false(N,1));
  end
  return;
end

% smooth activation and conservative inverse-amplification calibration
mincond = get_option(varargin, {'mincond','minCond','min_cond'}, 30);
maxcond = get_option(varargin, {'maxcond','maxCond','max_cond'}, 1e3);
targetcond = get_option(varargin, ...
  {'targetcond','targetCond','target_cond', ...
   'target amplification','targetamp'}, mincond);
if isempty(mincond), mincond = 30; end
if isempty(maxcond), maxcond = 1e3; end
if isempty(targetcond), targetcond = mincond; end

mincond = real(mincond);
maxcond = real(maxcond);
targetcond = real(targetcond);
if mincond < 1
  error('mincond must be at least 1.');
end
if targetcond < 1 || targetcond > mincond
  error('targetcond must satisfy 1 <= targetcond <= mincond.');
end
if maxcond <= mincond
  error('maxcond must be strictly larger than mincond.');
end

% First compute the conservative equal-scaling amount. The degree-weighted
% method below is calibrated to produce exactly the same coupling reduction.
[etaReference, centerAmplificationRegBound] = ...
  shapeRegularizationAmount(centerAmplification, ...
    mincond, maxcond, targetcond, eigFloorRel);

H_reg = H_num + reshape(etaReference, 1, 1, N) .* H_perp;
shapeRegularization = etaReference;

% degree weighting is applied in the C0-metric, equal multipliers recover the former method
basisDegrees = get_option(varargin, ...
  {'basis_degrees', 'basis degrees', 'basisdegrees'}, []);
if centeredEvaluation && dim > 1 && ~isempty(basisDegrees)
  degreeMultipliers = makeDegreeMultipliers( ...
    basisDegrees, dim, degreeExponent, degreeLaplaceShift);

  [H_reg, shapeRegularization, centerAmplificationRegBound] = ...
    applyDegreeWeightedScaling(H_reg, C0_book, b_book, a_book, ...
      etaReference, degreeMultipliers, ...
      centerAmplificationRegBound, eigFloorRel);
end

H_reg = (H_reg + conj(permute(H_reg, [2, 1, 3]))) / 2;

% On an inactive page no regularization is applied at all, so H_reg is exactly
% the normalized Gram matrix and one solve covers both kinds of page.
active = (numericalRidge > 0) | (shapeRegularization > 0);
c_scaled = pagemldivide(H_reg, rhs_book);

% one step of iterative refinement for the pages that solve the plain problem
if ~all(active)
  residual = fw_book - pagemtimes(B_book, c_scaled);
  correction = pagemldivide(H_reg, ...
    pagemtimes(B_book, 'ctranspose', residual, 'none'));
  correction(:,:,active) = 0;
  c_scaled = c_scaled + correction;
end

c_book = c_scaled ./ s_book;
clear c_scaled rhs_book B_book fw_book s_book H_num H_perp;
clear C0_book b_book a_book etaReference;

if nargout > 1
  eigReg = pageeig(H_reg);
  [conds, maxeig_reg, mineig_reg] = ...
    conditionsFromEigenvalues(eigReg, eigFloorRel);

  if nargout > 2
    info = makeInfo(conds, conds_unreg, maxeig, mineig, ...
      maxeig_reg, mineig_reg, centerAmplification, ...
      centerAmplificationRegBound, numericalRidge, ...
      shapeRegularization, active);
  end
end

end


% obtain basis evaluation vectors in a canonical dim x 1 x N layout
function [g_book, centeredEvaluation] = getEvaluationVector( ...
    dim, N, prototype, centeredEvaluation, options)

  g_book = get_option(options, ...
    {'eval_vector', 'evaluation_vector', 'center_vector'}, []);

  if isempty(g_book)
    g_book = zeros(dim, 1, 1, 'like', prototype);
    g_book(1) = 1;
    centeredEvaluation = true;
    return;
  end

  if isvector(g_book) && numel(g_book) == dim
    g_book = reshape(g_book, dim, 1, 1);
  elseif ismatrix(g_book) && size(g_book,1) == dim && size(g_book,2) == N
    g_book = reshape(g_book, dim, 1, N);
  end
end


% optimized block analysis for centered bases, where evaluation is e_1
function [H_num, H_perp, C0, b, a, lambda, chi] = ...
    analyzeCenteredDirection(H, kappaMax, eigFloorRel)

  dim = size(H,1);
  N = size(H,3);

  if dim == 1
    H_num = H;
    H_perp = zeros(size(H), 'like', H);
    C0 = zeros(0, 0, N, 'like', H);
    b = zeros(0, 1, N, 'like', H);
    a = reshape(real(H(1,1,:)), [], 1);
    lambda = zeros(N,1);
    chi = ones(N,1);
    return;
  end

  C = H(2:end,2:end,:);
  eigC = pageeig(C);
  muMax = reshape(max(real(eigC), [], 1), [], 1);
  muMin = reshape(min(real(eigC), [], 1), [], 1);
  muMin = max(muMin, 0);
  clear eigC;

  % This high condition cap is a numerical safeguard, not the approximation
  % criterion. It acts only in the nonconstant coefficient space.
  lambdaCond = max(0, ...
    (muMax - kappaMax .* muMin) ./ (kappaMax - 1));
  lambdaAbs = max(0, eigFloorRel .* max(muMax, 1) - muMin);
  lambda = max(lambdaCond, lambdaAbs);

  Iperp = eye(dim-1, 'like', H);
  C0 = C + reshape(lambda, 1, 1, N) .* Iperp;

  b = H(2:end,1,:);
  z = pagemldivide(C0, b);
  r = reshape(real(sum(conj(b) .* z, 1)), [], 1);
  r = max(r, 0);
  a = reshape(real(H(1,1,:)), [], 1);

  schurFloor = eigFloorRel .* max(a, 1);
  schur = max(a - r, schurFloor);
  chi = min(max(a ./ schur, 1), 1/eigFloorRel);

  H_num = H;
  H_num(2:end,2:end,:) = C0;

  H_perp = zeros(size(H), 'like', H);
  H_perp(2:end,2:end,:) = C0;
end


% invariant version for a page-dependent evaluation direction
function [H_num, H_perp, lambda, chi] = ...
    analyzeGeneralDirection(H, u, kappaMax, eigFloorRel)

  dim = size(H,1);
  N = size(H,3);

  if dim == 1
    H_num = H;
    H_perp = zeros(size(H), 'like', H);
    lambda = zeros(N,1);
    chi = ones(N,1);
    return;
  end

  u_adj = conj(permute(u, [2, 1, 3]));
  uu = pagemtimes(u, u_adj);
  P = eye(dim, 'like', H) - uu;

  Hu = pagemtimes(H, u);
  a_complex = sum(conj(u) .* Hu, 1);
  a = reshape(real(a_complex), [], 1);

  coupling = Hu - u .* a_complex;
  coupling = pagemtimes(P, coupling);

  PHP = H - pagemtimes(Hu, u_adj) - ...
    pagemtimes(u, conj(permute(Hu, [2, 1, 3]))) + ...
    reshape(a, 1, 1, N) .* uu;
  PHP = (PHP + conj(permute(PHP, [2, 1, 3]))) / 2;

  % P*H*P has one exact zero eigenvalue in the protected direction.
  eigPerp = sort(real(pageeig(PHP)), 1, 'ascend');
  muMax = reshape(eigPerp(end,:,:), [], 1);
  muMin = reshape(eigPerp(2,:,:), [], 1);
  muMin = max(muMin, 0);

  lambdaCond = max(0, ...
    (muMax - kappaMax .* muMin) ./ (kappaMax - 1));
  lambdaAbs = max(0, eigFloorRel .* max(muMax, 1) - muMin);
  lambda = max(lambdaCond, lambdaAbs);

  H_num = H + reshape(lambda, 1, 1, N) .* P;
  H_perp = PHP + reshape(lambda, 1, 1, N) .* P;

  % Add a harmless protected component only to make this auxiliary solve
  % invertible; it does not affect vectors in u^perp.
  nuisanceSolve = H_perp + ...
    reshape(max(muMax, 1), 1, 1, N) .* uu;
  z = pagemldivide(nuisanceSolve, coupling);
  r = reshape(real(sum(conj(coupling) .* z, 1)), [], 1);
  r = max(r, 0);

  schurFloor = eigFloorRel .* max(a, 1);
  schur = max(a - r, schurFloor);
  chi = min(max(a ./ schur, 1), 1/eigFloorRel);
end


% build increasing degree multipliers for the nuisance coordinates
function multipliers = makeDegreeMultipliers( ...
    basisDegrees, dim, exponent, laplaceShift)

  basisDegrees = real(basisDegrees(:));
  if numel(basisDegrees) ~= dim
    error('basis_degrees must contain one entry per basis function.');
  end
  if any(diff(basisDegrees) < 0)
    error('basis_degrees must follow the ordering of the basis columns.');
  end

  degrees = max(basisDegrees(2:end), 0);
  laplaceWeights = degrees .* (degrees + laplaceShift);
  positive = laplaceWeights > 0;

  multipliers = ones(dim-1, 1);
  if any(positive)
    firstWeight = min(laplaceWeights(positive));
    multipliers(positive) = ...
      (laplaceWeights(positive) / firstWeight) .^ exponent;
  end
end


% replace equal nuisance scaling by a degree-weighted scaling with the same
% conservative Schur-coupling reduction
function [Hreg, tau, chiReg] = applyDegreeWeightedScaling( ...
    Hreg, C0, b, a, etaReference, multipliers, chiReg, eigFloorRel)

  active = find(etaReference > 0);
  tau = etaReference;
  if isempty(active) || all(abs(multipliers - 1) <= 10*eps)
    return;
  end

  for page = reshape(active, 1, [])
    C = C0(:,:,page);
    C = (C + C') / 2;
    [R, flag] = chol(C, 'upper');

    % C0 is already numerically regularized and should be positive definite.
    % Retain the former equal scaling as a safe fallback if Cholesky fails.
    if flag ~= 0
      continue;
    end

    % C0 = R'*R and v = R'^(-1)b, i.e. the degree-layer components of the coupling
    v = R' \ b(:,1,page);
    energy = abs(v).^2;
    r0 = real(sum(energy));
    if r0 <= realmin
      continue;
    end

    rTarget = r0 / (1 + etaReference(page));
    tauPage = couplingBisection( ...
      energy, multipliers, rTarget, etaReference(page));

    rowScale = sqrt(1 + tauPage .* multipliers);
    Rreg = rowScale .* R;
    Creg = Rreg' * Rreg;
    Hreg(2:end,2:end,page) = (Creg + Creg') / 2;
    tau(page) = tauPage;

    rReg = real(sum(energy ./ (1 + tauPage .* multipliers)));
    schur = max(a(page) - rReg, eigFloorRel * max(a(page), 1));
    chiReg(page) = max(a(page) / schur, 1);
  end
end


% solve sum_j energy_j/(1+tau*mu_j) = rTarget by bisection in log(1+tau)
function tau = couplingBisection(energy, multipliers, rTarget, tauUpper)

  if tauUpper <= 0
    tau = 0;
    return;
  end

  lower = 0;
  upper = log1p(tauUpper);

  % Forty-eight steps give ample accuracy even when targetcond = 1 makes the
  % upper bracket very large. Bisection in log(1+tau) resolves all scales well.
  for iter = 1 : 48
    middle = (lower + upper) / 2;
    tauMiddle = expm1(middle);
    rMiddle = sum(energy ./ (1 + tauMiddle .* multipliers));

    if rMiddle > rTarget
      lower = middle;
    else
      upper = middle;
    end
  end

  tau = expm1(upper);
end


% compute smooth activation and the conservative nuisance scaling
function [eta, chiReg] = ...
    shapeRegularizationAmount(chi, chiOn, chiFull, chiTarget, eigFloorRel)

  logWidth = log10(chiFull) - log10(chiOn);
  x = (log10(chi) - log10(chiOn)) ./ logWidth;
  t = smoothstepC3(x);

  rho = max(1 - 1 ./ chi, 0);

  % The limiting target one requires infinite scaling. Use the same numerical
  % floor as in the eigenvalue diagnostics when it is requested explicitly.
  rhoTarget = max(1 - 1 / chiTarget, eigFloorRel);
  etaFull = max(rho ./ rhoTarget - 1, 0);
  eta = t .* etaFull;
  eta(eta <= eigFloorRel) = 0;

  % Inverse-amplification bound after nuisance-block scaling.
  chiReg = 1 ./ max(1 - rho ./ (1 + eta), realmin);
end


% C3 transition with value and first three derivatives zero at both endpoints
function t = smoothstepC3(x)
  x = min(max(x, 0), 1);
  t = x.^4 .* (35 - 84*x + 70*x.^2 - 20*x.^3);
end


function [conds, maxeig, mineig] = ...
    conditionsFromSingularValues(singval, eigFloorRel)
  maxeig = reshape(max(real(singval), [], 1), [], 1).^2;
  mineig = reshape(min(real(singval), [], 1), [], 1).^2;
  mineig = max(mineig, 0);
  mineigSafe = max(mineig, eigFloorRel .* max(maxeig, 1));
  conds = maxeig ./ mineigSafe;
end


function [conds, maxeig, mineig] = ...
    conditionsFromEigenvalues(eigval, eigFloorRel)
  maxeig = reshape(max(real(eigval), [], 1), [], 1);
  mineig = reshape(min(real(eigval), [], 1), [], 1);
  mineig = max(mineig, 0);
  mineigSafe = max(mineig, eigFloorRel .* max(maxeig, 1));
  conds = maxeig ./ mineigSafe;
end


function info = makeInfo(conds_reg, conds_unreg, maxeig, mineig, ...
    maxeig_reg, mineig_reg, chi, chiReg, numericalRidge, eta, active)
  info = struct;
  info.conds_reg = conds_reg;
  info.conds_unreg = conds_unreg;
  info.maxeig = maxeig;
  info.mineig = mineig;
  info.maxeig_reg = maxeig_reg;
  info.mineig_reg = mineig_reg;
  info.centerAmplification = chi;
  info.centerAmplificationRegBound = chiReg;
  info.numericalRidge = numericalRidge;
  info.shapeRegularization = eta;
  info.regularizationActive = active;
end
