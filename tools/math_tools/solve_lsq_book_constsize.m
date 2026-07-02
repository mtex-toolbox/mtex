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


% ==========================
% 1 - without regularization
% ==========================
if ~regularize
  c_book = pagemldivide(B_book, fw_book) ./ pagetranspose(s_book);
  clear fw_book s_book;

  if nargout > 1
    eigs = pagesvd(B_book);
    sigmax = reshape(max(eigs, [], 1), [], 1);
    sigmin = reshape(min(eigs, [], 1), [], 1);
    clear eigs;

    maxeig = sigmax.^2;
    mineig = max(sigmin.^2, 0);
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

    clear B_book;
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

% internal regularization parameters
targetcond = mincond;

% build unregularized Gram system
Gram_book = pagemtimes(pagetranspose(B_book), B_book);
Gram_book = (Gram_book + pagetranspose(Gram_book)) / 2;
rhs_book = pagemtimes(pagetranspose(B_book), fw_book);
clear fw_book B_book;

% apply stronger penalty to higher polynomial degrees
% the first coefficient is always unregularized to preserve constants
basis_weights = basis_weights(:);
basis_weights = max(real(basis_weights), 0);
if max(basis_weights) > 0
  basis_weights = basis_weights ./ max(basis_weights);
else
  basis_weights = zeros(size(basis_weights));
end
basis_weights = 1 + basis_weights_scale .* basis_weights;

% Preserve constants: the first basis function is assumed to be constant.
basis_weights(1) = 0;
bw_pos = basis_weights > 0;
if any(bw_pos)
  basis_weights(bw_pos) = basis_weights(bw_pos) ./ mean(basis_weights(bw_pos));
end

% compute indices of pagewise diagonal entries
diag_idx = pageDiagIndices(dim, N);

% compute average eigenvalue scale of each page
%   (after column normalization, this is usually close to 1)
diagGram = reshape(real(Gram_book(diag_idx)), dim, N);
meanEig = mean(diagGram, 1).';

% compute condition numbers of the unregularized Gram matrix, if they are needed
%   these are returned in info and are used for automatic parameter selection
have_eigs = false;
if nargout > 2
  eigval = pageeig(Gram_book);
  maxeig_unreg = reshape(max(real(eigval), [], 1), [], 1);
  mineig_unreg = reshape(min(real(eigval), [], 1), [], 1);
  mineig_unreg = max(mineig_unreg, 0);
  mineig_safe = max(mineig_unreg, eigFloorRel .* max(maxeig_unreg, 1));
  conds_unreg = maxeig_unreg ./ mineig_safe;
  clear eigval;

  maxeig = maxeig_unreg;
  mineig = mineig_unreg;
  have_eigs = true;
end

% compute regularization parameter from local geometry score of the neighbors
%   (this must be computed outside of this solver from the actual coordinates of
%    the neighbors)
geometryScore = get_option(varargin, 'geometryScore', zeros(N, 1));
geometryScore = geometryScore(:);
geometryScore = min(max(real(geometryScore), 0), 1);

% compute geometry regularization strength
lambdaGeom = lambda_geom_rel .* geometryScore .* meanEig;

% apply geometry regularization first
%   this damps systems with bad local node geometry before condition regularization
if any(lambdaGeom ~= 0)
  diagOffsets = basis_weights * lambdaGeom.';
  if (dim == 1)
    Gram_book = Gram_book + reshape(diagOffsets, [1, 1, N]);
  else
    Gram_book(diag_idx) = Gram_book(diag_idx) + diagOffsets(:);
  end

  % eigenvalues from the unregularized system are not valid anymore
  have_eigs = false;
end

% eigenvalues after geometry regularization
%   these are used to compute the remaining condition-based regularization
if ~have_eigs
  eigval = pageeig(Gram_book);
  maxeig = reshape(max(real(eigval), [], 1), [], 1);
  mineig = reshape(min(real(eigval), [], 1), [], 1);
  mineig = max(mineig, 0);
  clear eigval;
end

mineig_safe = max(mineig, eigFloorRel .* max(maxeig, 1));
conds_geom = maxeig ./ mineig_safe;

% compute remaining regularization parameter from condition of geometry-regularized Gram matrix
targetcond = max(targetcond, 1 + 10*eps);
t = (log10(conds_geom) - log10(mincond)) ./ (log10(maxcond) - log10(mincond));
t = smoothstepC3(t);

% compute lambda such that target condition is approximately obtained
lambdaNeeded = max(0, (maxeig - targetcond .* mineig) ./ (targetcond - 1));

% apply only the remaining condition-based regularization
lambdaCond = t .* lambdaNeeded;

% apply condition regularization as a top-up
if any(lambdaCond ~= 0)
  diagOffsets = basis_weights * lambdaCond.';
  Gram_book(diag_idx) = Gram_book(diag_idx) + diagOffsets(:);
end

% solve for scaled coeffs, then 'unscale' to obtain the original coeffs
c_book = pagemldivide(Gram_book, rhs_book) ./ pagetranspose(s_book);

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
