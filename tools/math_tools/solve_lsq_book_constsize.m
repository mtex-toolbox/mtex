function [c_book, conds, info] = ...
    solve_lsq_book_constsize(W_book, G_book, f_book, varargin)
%
% Each page of the input arrays defines one local least-squares problem.
% Those are solved in parallel using MATLAB page functions.
%
% input:
%   W_book : nn  x 1    x N      local weights
%   G_book : nn  x dim  x N      local basis values
%   f_book : nn  x numf x N      local function values
%
% output:
%   c_book : dim x numf x N      local coefficient vectors
%   conds  : N x 1               condition numbers of the solved Gram systems
%   info   : struct              additional regularization diagnostics
%
% options:
%   regularize
%   basis_weights
%   mincond
%   maxcond
%   basis_weights_scale
%   lambda_geom_rel
%   geometryScore
%
% flags:
%   condition_geometry       geometry is condition-scaled (used by SO3FunMLS)
%
% Regularization consists of a geometry contribution followed by a condition-
% based top-up. SO3FunMLS may request condition-scaled geometry through the
% condition_geometry flag; without that flag the original S2FunMLS geometry
% ridge is retained. The domain-specific score is computed by the caller.
%
% IMPORTANT ASSUMPTION:
%   The first basis function is the constant function, or the basis function
%   that should play the unregularized constant role locally.
%
% =============================================================================


% this function has two modes: with regularization or without regularization
regularize = check_option(varargin, {'regularize', 'regularization'});


% =============================================
% 0 - variables that are needed for both modes
% =============================================
colNormTol = 1e-14;
eigFloorRel = 1e-14;

% matrix dimensions
dim = size(G_book, 2);
N   = size(G_book, 3);

% form the weighted design matrices
W_book = max(W_book, 0); % avoid negative weights from rounding errors
meanW = max(mean(W_book, 1), realmin);
W_book = W_book ./ meanW; % normalize mean weight to one on every page
W_book = sqrt(W_book);

B_book = W_book .* G_book;
clear G_book;

% normalize columns before computing conditions and regularization
s_book = sqrt(sum(abs(B_book).^2, 1));
pageScale = max(s_book, [], 2);
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

  if nargout > 1
    singval = pagesvd(B_book);

    maxeig = reshape(max(singval, [], 1), [], 1).^2;
    mineig = reshape(min(singval, [], 1), [], 1).^2;
    mineig = max(real(mineig), 0);
    mineig_safe = max(mineig, eigFloorRel .* max(maxeig, 1));

    conds = maxeig ./ mineig_safe;

    if nargout > 2
      geometryScore = get_option(varargin, 'geometryScore', zeros(N, 1));
      geometryScore = min(max(real(geometryScore(:)), 0), 1);
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

% SO3 may use geometry only as a fraction of the condition-derived correction.
% Without this flag the original independent S2 geometry ridge is unchanged.
conditionGeometry = check_option(varargin, ...
  {'condition_geometry', 'condition geometry', 'conditioned_geometry'});

mincond = max(real(mincond), 1 + 10*eps);
maxcond = max(real(maxcond), mincond * (1 + 10*eps));
basis_weights_scale = max(real(basis_weights_scale), 0);
lambda_geom_rel = max(real(lambda_geom_rel), 0);

% build the normalized unregularized Gram systems and right-hand sides
B_book_transposed = permute(B_book, [2, 1, 3]);
Gram_book = pagemtimes(B_book_transposed, B_book);
Gram_book = (Gram_book + permute(Gram_book, [2, 1, 3])) / 2;
rhs_book = pagemtimes(B_book_transposed, fw_book);
clear B_book_transposed;

% construct the common degree-selective diagonal penalty profile
basis_weights = max(real(basis_weights(:)), 0);
if max(basis_weights) > 0
  basis_weights = basis_weights ./ max(basis_weights);
else
  basis_weights = zeros(size(basis_weights));
end
basis_weights = 1 + basis_weights_scale .* basis_weights;

% leave the constant component unpenalized
basis_weights(1) = 0;
bw_pos = basis_weights > 0;
if any(bw_pos)
  basis_weights(bw_pos) = basis_weights(bw_pos) ./ mean(basis_weights(bw_pos));
end

% pagewise diagonal indices
diag_idx = pageDiagIndices(dim, N);

% after column normalization, the average eigenvalue is one
meanEig = ones(N, 1);

% condition of the unregularized normalized Gram matrix
eigval = pageeig(Gram_book);
maxeig_unreg = reshape(max(real(eigval), [], 1), [], 1);
mineig_unreg = reshape(min(real(eigval), [], 1), [], 1);
mineig_unreg = max(mineig_unreg, 0);
clear eigval;

mineig_safe = max(mineig_unreg, eigFloorRel .* max(maxeig_unreg, 1));
conds_unreg = maxeig_unreg ./ mineig_safe;

% domain-specific local geometry score supplied by S2FunMLS or SO3FunMLS
geometryScore = get_option(varargin, 'geometryScore', zeros(N, 1));
geometryScore = min(max(real(geometryScore(:)), 0), 1);


% ===================================
% 2a - geometry contribution
% ===================================
if conditionGeometry
  % SO(3): geometry applies only a fraction of the correction suggested by
  % the unregularized condition. Well-conditioned pages therefore receive
  % exactly zero geometry regularization and remain on the rectangular solve.
  lambdaNeededUnreg = max(0, ...
    (maxeig_unreg - mincond .* mineig_unreg) ./ (mincond - 1));

  geometryFraction = min(lambda_geom_rel .* geometryScore, 1);
  lambdaGeom = geometryFraction .* lambdaNeededUnreg;
else
  % S2 and legacy behavior: independent geometry ridge on the normalized scale.
  lambdaGeom = lambda_geom_rel .* geometryScore .* meanEig;
end

if any(lambdaGeom ~= 0)
  diagOffsets = basis_weights * lambdaGeom.';
  if dim == 1
    Gram_book = Gram_book + reshape(diagOffsets, [1, 1, N]);
  else
    Gram_book(diag_idx) = Gram_book(diag_idx) + diagOffsets(:);
  end

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


% =================================
% 2b - condition-based ridge top-up
% =================================
% Activate smoothly in log-condition space after the geometry contribution.
tCond = conditionTransition(conds_geom, mincond, maxcond);

% Scalar ridge needed to reach mincond for an isotropic penalty. The actual
% degree-weighted profile uses this as its inexpensive pagewise scale.
lambdaNeeded = max(0, ...
  (maxeigGeom - mincond .* mineigGeom) ./ (mincond - 1));
lambdaCond = tCond .* lambdaNeeded;

if any(lambdaCond ~= 0)
  diagOffsets = basis_weights * lambdaCond.';
  if dim == 1
    Gram_book = Gram_book + reshape(diagOffsets, [1, 1, N]);
  else
    Gram_book(diag_idx) = Gram_book(diag_idx) + diagOffsets(:);
  end
end


% solve inactive pages by the original rectangular least-squares formulation
active = (lambdaGeom + lambdaCond) > 0;
numf = size(rhs_book, 2);
c_scaled = zeros(dim, numf, N, 'like', rhs_book);

if any(~active)
  c_scaled(:,:,~active) = pagemldivide(B_book(:,:,~active), fw_book(:,:,~active));
end
if any(active)
  c_scaled(:,:,active) = pagemldivide(Gram_book(:,:,active), rhs_book(:,:,active));
end

% undo column normalization
c_book = c_scaled ./ s_book;
clear c_scaled rhs_book B_book fw_book s_book;

% final condition numbers and diagnostics
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
    idx = (1:N)';
    return;
  end
  diagInPage = (1:dim+1:dim^2).';
  pageOffset = (0:N-1) .* dim^2;
  idx = reshape(diagInPage + pageOffset, [], 1);
end
