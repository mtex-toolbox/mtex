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
%   mincond            normalized center amplification where activation starts
%   maxcond            normalized center amplification for full correction
%   targetcond         amplification approached at full correction
%   eval_vector        basis values at the evaluation point (dim x 1 x N)
%   numerical_cond_max condition cap for the nuisance block (default 1e10)
%
% flags:
%   centered_evaluation  the evaluation vector is the first basis direction
%
% The regularizer protects the evaluation direction and penalizes only its
% orthogonal complement in normalized coefficient coordinates. In a centered
% basis this is the constant-preserving block form
%
%       H = [a b'; b C]  ->  H_reg = [a b'; b (1+eta)(C+lambda_num I)].
%
% Activation and correction strength are separate: mincond/maxcond determine
% where the smooth transition acts, while targetcond determines the final
% directional amplification. No pointwise parameter search is used.
%

regularize = check_option(varargin, {'regularize', 'regularization'});
centeredEvaluation = check_option(varargin, ...
  {'centered_evaluation', 'centered evaluation'});

colNormTol = 1e-14;
eigFloorRel = 1e-14;
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
s_book = sqrt(sum(abs(B_book).^2, 1));
pageScale = max(s_book, [], 2);
s_floor = max(realmin, colNormTol .* pageScale);
s_book = max(s_book, s_floor);
B_book = B_book ./ s_book;
s_book = permute(s_book, [2, 1, 3]);

% The ordinary unregularized path remains the original rectangular LSQ solve.
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
B_adj = conj(permute(B_book, [2, 1, 3]));
H_book = pagemtimes(B_adj, B_book);
H_book = (H_book + conj(permute(H_book, [2, 1, 3]))) / 2;

if regularize
  rhs_book = pagemtimes(B_adj, fw_book);
end
clear B_adj;

% evaluation direction in normalized coefficient coordinates
[g_book, centeredEvaluation] = getEvaluationVector( ...
  varargin, dim, N, B_book, centeredEvaluation);

if centeredEvaluation
  [H_num, H_perp, numericalRidge, centerAmplification] = ...
    analyzeCenteredDirection(H_book, numericalCondMax, eigFloorRel);
else
  % Evaluation uses g.'*c, hence conj(g) is its Riesz vector for complex bases.
  q_book = conj(g_book) ./ s_book;
  qnorm = sqrt(sum(abs(q_book).^2, 1));
  u_book = q_book ./ max(qnorm, realmin);
  [H_num, H_perp, numericalRidge, centerAmplification] = ...
    analyzeGeneralDirection(H_book, u_book, numericalCondMax, eigFloorRel);
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

% smooth activation and closed-form amount of the shape regularization
mincond = get_option(varargin, {'mincond','minCond','min_cond'}, 30);
maxcond = get_option(varargin, {'maxcond','maxCond','max_cond'}, 1e3);
targetcond = get_option(varargin, ...
  {'targetcond','targetCond','target_cond', ...
   'target amplification','targetamp'}, mincond);
if isempty(mincond), mincond = 30; end
if isempty(maxcond), maxcond = 1e3; end
if isempty(targetcond), targetcond = mincond; end

% The ideal target one cannot be reached with a finite nuisance-block scaling.
% targetcond may be lower than mincond, which separates final correction
% strength from the point where regularization begins.
mincond = max(real(mincond), 1.1);
maxcond = max(real(maxcond), 10 * mincond);
targetcond = min(max(real(targetcond), 1.1), mincond);

[shapeRegularization, centerAmplificationRegBound] = ...
  shapeRegularizationAmount(centerAmplification, ...
    mincond, maxcond, targetcond);

H_reg = H_num + reshape(shapeRegularization, 1, 1, N) .* H_perp;
H_reg = (H_reg + conj(permute(H_reg, [2, 1, 3]))) / 2;

% Exactly inactive pages retain the more accurate rectangular least-squares solve.
active = (numericalRidge > 0) | (shapeRegularization > 0);
numf = size(fw_book, 2);
c_scaled = zeros(dim, numf, N, 'like', fw_book);

if any(~active)
  c_scaled(:,:,~active) = ...
    pagemldivide(B_book(:,:,~active), fw_book(:,:,~active));
end
if any(active)
  c_scaled(:,:,active) = ...
    pagemldivide(H_reg(:,:,active), rhs_book(:,:,active));
end

c_book = c_scaled ./ s_book;
clear c_scaled rhs_book B_book fw_book s_book H_num H_perp;

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
    varargin, dim, N, prototype, centeredEvaluation)

  g_book = get_option(varargin, ...
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
function [H_num, H_perp, lambda, chi] = ...
    analyzeCenteredDirection(H, kappaMax, eigFloorRel)

  dim = size(H,1);
  N = size(H,3);

  if dim == 1
    H_num = H;
    H_perp = zeros(size(H), 'like', H);
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
  a = reshape(real(H(1,1,:)), [], 1);

  schurFloor = eigFloorRel .* max(a, 1);
  schur = max(a - r, schurFloor);
  chi = max(a ./ schur, 1);

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

  u_adj = conj(permute(u, [2, 1, 3]));
  uu = pagemtimes(u, u_adj);
  P = eye(dim, 'like', H) - uu;

  Hu = pagemtimes(H, u);
  a = reshape(real(sum(conj(u) .* Hu, 1)), [], 1);
  PHP = H - pagemtimes(Hu, u_adj) - ...
    pagemtimes(u, conj(permute(Hu, [2, 1, 3]))) + ...
    reshape(a, 1, 1, N) .* uu;
  PHP = (PHP + conj(permute(PHP, [2, 1, 3]))) / 2;

  % P*H*P has one exact zero eigenvalue in the protected direction.
  eigPerp = sort(real(pageeig(PHP)), 1, 'ascend');
  muMax = reshape(eigPerp(end,:,:), [], 1);
  if dim > 1
    muMin = reshape(eigPerp(2,:,:), [], 1);
  else
    muMin = zeros(N,1);
  end
  muMin = max(muMin, 0);

  lambdaCond = max(0, ...
    (muMax - kappaMax .* muMin) ./ (kappaMax - 1));
  lambdaAbs = max(0, eigFloorRel .* max(muMax, 1) - muMin);
  lambda = max(lambdaCond, lambdaAbs);

  H_num = H + reshape(lambda, 1, 1, N) .* P;
  H_perp = PHP + reshape(lambda, 1, 1, N) .* P;

  % This tiny diagnostic floor only caps values beyond meaningful double
  % precision; it is not part of the solved regularized system.
  H_indicator = H_num + ...
    reshape(eigFloorRel .* max(a,1), 1, 1, N) .* uu;
  z = pagemldivide(H_indicator, u);
  invdir = reshape(real(sum(conj(u) .* z, 1)), [], 1);
  chi = min(max(a .* invdir, 1), 1/eigFloorRel);
end

% compute smooth activation and the exact block scaling needed at full strength
function [eta, chiReg] = ...
    shapeRegularizationAmount(chi, chiOn, chiFull, chiTarget)
  logWidth = log10(chiFull) - log10(chiOn);
  x = (log10(chi) - log10(chiOn)) ./ logWidth;
  t = smoothstepC3(x);

  rho = max(1 - 1 ./ chi, 0);
  rhoTarget = 1 - 1 / chiTarget;
  etaFull = max(rho ./ rhoTarget - 1, 0);
  eta = t .* etaFull;
  eta(eta <= 1e-14) = 0;

  % This is the inverse-amplification bound. The actual regularized shape norm
  % is no larger because H is bounded above by the regularized Gram matrix.
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
