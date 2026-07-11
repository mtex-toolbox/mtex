function [c_book, conds, info] = ...
    solve_lsq_book_constsize(W_book, G_book, f_book, varargin)
%
% Each page of the input arrays defines one local least-squares problem.
% Those are solved in parallel using Matlabs pagefuns.
%
% input:
%   W_book : nn  x 1    x N      local weights
%   G_book : nn  x dim  x N      local basis values
%   f_book : nn  x numf x N      local function values
%
% output:
%   c_book : dim x numf x N      local coefficient vectors
%   conds  : N x 1               condition numbers of the solved systems
%   info   : struct              additional data for regularization setup
%
% options:
%    regularize               given be varargin
%    basis_weights            given be varargin
%    mincond                  given be varargin
%    maxcond                  given be varargin
%    basis_weights_scale      given be varargin
%    lambda_geom_rel          given be varargin
%    geometryScore            given be varargin
%
%    targetcond               default: mincond
%
% flags:
%    condition_geometry       geometry may only activate a fraction of the
%                             condition regularization that is actually needed
%
%
% IMPORTANT ASSUMPTION:
%   The first basis function is assumed to be the constant function.
%     1 - For MLS on S^2 we have: - even degree -> 1
%                             - odd degree -> z (~const near north pole)
%     2 - For MLS on SO(3) this is similar.
%
% =============================================================================


% this function has 2 modes: with regularization or without regularization
regularize = check_option(varargin, {'regularize', 'regularization'});


% =============================================
% 0 - variables that are needed for both modes:
% =============================================
% Internal numerical constants.
colNormTol = 1e-14;
eigFloorRel = 1e-14;

% matrix dimensions
dim = size(G_book, 2);
N   = size(G_book, 3);

% least squares stuff
W_book = max(W_book, 0); % avoid negative weights from rounding errors
meanW = mean(W_book, 1);
meanW = max(meanW, realmin);
W_book = W_book ./ meanW; % normalize the mean weight to be 1
W_book = sqrt(W_book); % for computing B_book, the root of the gram matrix

B_book = W_book .* G_book;
clear G_book;

s_book = sqrt(sum(abs(B_book).^2, 1));   % 1 x dim x N
pageScale = max(s_book, [], 2);          % 1 x 1 x N
s_floor = max(realmin, colNormTol .* pageScale);
s_book = max(s_book, s_floor);

B_book = B_book ./ s_book;
fw_book = W_book .* f_book;
clear f_book W_book;
s_book = permute(s_book, [2, 1, 3]);

% ==========================
% 1 - without regularization
% ==========================
if ~regularize
  c_book = pagemldivide(B_book, fw_book) ./ s_book;
  clear fw_book s_book;

  if nargout > 1
    eigs = pagesvd(B_book);

    maxeig = reshape(max(eigs, [], 1), [], 1);
    maxeig = maxeig.^2;

    mineig = reshape(min(eigs, [], 1), [], 1);
    mineig = max(mineig.^2, 0);
    mineig_safe = max(mineig, eigFloorRel .* max(maxeig, 1));

    conds = maxeig ./ mineig_safe;

    if nargout > 2
      geometryScore = get_option(varargin, 'geometryScore', zeros(N, 1));
      geometryScore = geometryScore(:);
      geometryScore = min(max(real(geometryScore), 0), 1);

      meanEig = reshape(mean(sum(abs(B_book).^2, 1), 2), [], 1);

      info = struct;
      info.conds_reg = conds;
      info.conds_unreg = conds;
      info.geometryScore = geometryScore;
      info.maxeig = maxeig;
      info.mineig = mineig;
      info.meanEig = meanEig;
    end
  end

  return;
end


% =======================
% 2 - with regularization
% =======================

% external regularization parameters
basis_weights       = get_option(varargin, {'basis_weights','basisweights'}, ones(dim, 1));
mincond             = get_option(varargin, {'mincond','minCond','min_cond'}, 1e2);
maxcond             = get_option(varargin, {'maxcond','maxCond','max_cond'}, 1e4);
basis_weights_scale = get_option(varargin, 'basis_weights_scale', 4, 'double');
lambda_geom_rel     = get_option(varargin, 'lambda_geom_rel', 4, 'double');
targetcond          = get_option(varargin, 'targetcond', mincond);

% on SO(3), geometry is used only to strengthen condition regularization
%   instead of adding a dimension-dependent ridge term of its own
conditionGeometry = check_option(varargin, ...
  {'condition_geometry', 'condition geometry', 'conditioned_geometry'});

% make all scalar parameters usable at one central place
mincond = max(real(mincond), 1 + 10*eps);
maxcond = max(real(maxcond), mincond * (1 + 10*eps));
targetcond = max(real(targetcond), 1 + 10*eps);
basis_weights_scale = max(real(basis_weights_scale), 0);
lambda_geom_rel = max(real(lambda_geom_rel), 0);

% build unregularized Gram system
B_book_transposed = permute(B_book, [2, 1, 3]);
Gram_book = pagemtimes(B_book_transposed, B_book);
Gram_book = (Gram_book + permute(Gram_book, [2, 1, 3])) / 2;
rhs_book = pagemtimes(B_book_transposed, fw_book);
clear B_book_transposed;

% apply stronger penalty to higher polynomial degrees
%   basis_weights_scale changes the degree selectivity, not the overall amount
% the first coefficient is always unregularized to preserve constants
basis_weights = basis_weights(:);
basis_weights = max(real(basis_weights), 0);
if max(basis_weights) > 0
  basis_weights = basis_weights ./ max(basis_weights);
else
  basis_weights = zeros(size(basis_weights));
end
basis_weights = 1 + basis_weights_scale .* basis_weights;

% Preserve constants: the first basis function is assumed to be constant
basis_weights(1) = 0;
bw_pos = basis_weights > 0;
if any(bw_pos)
  basis_weights(bw_pos) = basis_weights(bw_pos) ./ mean(basis_weights(bw_pos));
end

% compute indices of pagewise diagonal entries
diag_idx = pageDiagIndices(dim, N);

% compute average eigenvalue scale of each page
%   (after column normalization, this is analytically 1)
meanEig = ones(N, 1);

% compute eigenvalues and conditions of the unregularized Gram matrices
%   these are needed both for diagnostics and for the regularization amount
eigval = pageeig(Gram_book);
maxeig_unreg = reshape(max(real(eigval), [], 1), [], 1);
mineig_unreg = reshape(min(real(eigval), [], 1), [], 1);
mineig_unreg = max(mineig_unreg, 0);
clear eigval;

mineig_safe = max(mineig_unreg, eigFloorRel .* max(maxeig_unreg, 1));
conds_unreg = maxeig_unreg ./ mineig_safe;

% local geometry score of the actual neighbors
geometryScore = get_option(varargin, 'geometryScore', zeros(N, 1));
geometryScore = geometryScore(:);
geometryScore = min(max(real(geometryScore), 0), 1);


% =======================================================
% 2a - condition-aware geometry regularization for SO(3)
% =======================================================
if conditionGeometry
  % smooth condition-based activation between mincond and maxcond
  tCond = conditionTransition(conds_unreg, mincond, maxcond);

  % smallest scalar ridge that would approximately obtain targetcond
  %   for an isotropic penalty
  lambdaNeeded = max(0, ...
    (maxeig_unreg - targetcond .* mineig_unreg) ./ (targetcond - 1));

  % geometry may activate part of the still missing condition regularization
  %   but it cannot regularize a system for which lambdaNeeded is zero
  geometryFraction = lambda_geom_rel .* geometryScore;
  geometryFraction = min(max(geometryFraction, 0), 1);

  lambdaCond = tCond .* lambdaNeeded;
  lambdaGeom = (1 - tCond) .* geometryFraction .* lambdaNeeded;

  % apply the geometry contribution first, for meaningful diagnostics
  if any(lambdaGeom ~= 0)
    diagOffsets = basis_weights * lambdaGeom.';
    if (dim == 1)
      Gram_book = Gram_book + reshape(diagOffsets, [1, 1, N]);
    else
      Gram_book(diag_idx) = Gram_book(diag_idx) + diagOffsets(:);
    end

    if nargout > 2
      eigGeom = pageeig(Gram_book);
      maxeigGeom = reshape(max(real(eigGeom), [], 1), [], 1);
      mineigGeom = reshape(min(real(eigGeom), [], 1), [], 1);
      mineigGeom = max(mineigGeom, 0);
      clear eigGeom;

      mineigGeomSafe = max(mineigGeom, eigFloorRel .* max(maxeigGeom, 1));
      conds_geom = maxeigGeom ./ mineigGeomSafe;
    end
  elseif nargout > 2
    conds_geom = conds_unreg;
  end

  % apply the ordinary condition contribution as a top-up
  if any(lambdaCond ~= 0)
    diagOffsets = basis_weights * lambdaCond.';
    if (dim == 1)
      Gram_book = Gram_book + reshape(diagOffsets, [1, 1, N]);
    else
      Gram_book(diag_idx) = Gram_book(diag_idx) + diagOffsets(:);
    end
  end


% ==================================================
% 2b - original independent geometry regularization
% ==================================================
else
  % compute geometry regularization relative to the normalized Gram scale
  lambdaGeom = lambda_geom_rel .* geometryScore .* meanEig;

  % apply geometry regularization first
  if any(lambdaGeom ~= 0)
    diagOffsets = basis_weights * lambdaGeom.';
    if (dim == 1)
      Gram_book = Gram_book + reshape(diagOffsets, [1, 1, N]);
    else
      Gram_book(diag_idx) = Gram_book(diag_idx) + diagOffsets(:);
    end
  end

  % eigenvalues after geometry regularization are used for the condition top-up
  if any(lambdaGeom ~= 0)
    eigGeom = pageeig(Gram_book);
    maxeigGeom = reshape(max(real(eigGeom), [], 1), [], 1);
    mineigGeom = reshape(min(real(eigGeom), [], 1), [], 1);
    mineigGeom = max(mineigGeom, 0);
    clear eigGeom;
  else
    maxeigGeom = maxeig_unreg;
    mineigGeom = mineig_unreg;
  end

  mineigGeomSafe = max(mineigGeom, eigFloorRel .* max(maxeigGeom, 1));
  conds_geom = maxeigGeom ./ mineigGeomSafe;

  % compute remaining regularization from the geometry-regularized condition
  tCond = conditionTransition(conds_geom, mincond, maxcond);
  lambdaNeeded = max(0, ...
    (maxeigGeom - targetcond .* mineigGeom) ./ (targetcond - 1));
  lambdaCond = tCond .* lambdaNeeded;

  if any(lambdaCond ~= 0)
    diagOffsets = basis_weights * lambdaCond.';
    if (dim == 1)
      Gram_book = Gram_book + reshape(diagOffsets, [1, 1, N]);
    else
      Gram_book(diag_idx) = Gram_book(diag_idx) + diagOffsets(:);
    end
  end
end


% solve inactive pages by the original least-squares formulation
%   this makes regularize=true an exact no-op wherever both lambdas vanish
active = (lambdaGeom + lambdaCond) > 0;
numf = size(rhs_book, 2);
c_scaled = zeros(dim, numf, N, 'like', rhs_book);

if any(~active)
  c_scaled(:,:,~active) = pagemldivide(B_book(:,:,~active), fw_book(:,:,~active));
end
if any(active)
  c_scaled(:,:,active) = pagemldivide(Gram_book(:,:,active), rhs_book(:,:,active));
end

% unscale to obtain coefficients of the original basis
c_book = c_scaled ./ s_book;
clear c_scaled rhs_book B_book fw_book s_book;

% compute condition numbers, if they are needed for the output
if nargout > 1
  eigReg = pageeig(Gram_book);
  maxeigReg = reshape(max(real(eigReg), [], 1), [], 1);
  mineigReg = reshape(min(real(eigReg), [], 1), [], 1);
  mineigReg = max(mineigReg, eigFloorRel .* max(maxeigReg, 1));
  conds = maxeigReg ./ mineigReg;

  if nargout > 2
    info = struct;
    info.conds_reg = conds;
    info.conds_unreg = conds_unreg;
    info.geometryScore = geometryScore;
    info.maxeig = maxeig_unreg;
    info.mineig = mineig_unreg;
    info.meanEig = meanEig;
    info.conds_geom = conds_geom;
    info.lambdaGeom = lambdaGeom;
    info.lambdaCond = lambdaCond;
  end
end

end


% ======================
% Local helper functions
% ======================

% C3 function with f(0) = 0 and f(1) = 1
function t = smoothstepC3(x)
  x = min(max(x, 0), 1);
  t = x.^4 .* (35 - 84*x + 70*x.^2 - 20*x.^3);
end

% smooth activation between two condition thresholds
function t = conditionTransition(conds, mincond, maxcond)
  logMincond = log10(mincond);
  logMaxcond = max(log10(maxcond), logMincond + 10*eps);
  x = (log10(conds) - logMincond) ./ (logMaxcond - logMincond);
  t = smoothstepC3(x);
end

% compute linear indices of all pagewise diagonal entries
function idx = pageDiagIndices(dim, N)
  if dim == 1
    idx = (1 : N)';
    return;
  end
  diagInPage = (1 : dim+1 : dim^2).';
  pageOffset = (0 : N-1) .* dim^2;
  idx = reshape(diagInPage + pageOffset, [], 1);
end
