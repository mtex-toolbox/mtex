function [c_book, conds] = solve_lsq_book_constsize(W_book, G_book, f_book, varargin)
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
%
% options:
%    regularize               given be varargin
%    basis_weights            given be varargin
%    mincond                  given be varargin
%    maxcond                  given be varargin
% 
%    targetcond               default: mincond
%    basis_weights_scale      default: 4
%    useOnesideRegularization default: true
%    sideMin                  default: 0.35
%    sideMax                  default: 0.85
%    sideLambdaRel            default: 1e-2
%
%
% IMPORTANT ASSUMPTION:
%   The first basis function is assumed to be the constant function.
%     1 - For MLS on S^2 we have: - even degree -> 1
%                             - odd degree -> z (~konst near north pole)
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
W_book = W_book ./ mean(W_book, 1); % normalize the mean weight to be 1
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
    clear B_book;
    conds = max(eigs, [], 1) ./ min(eigs, [], 1);
    conds = conds(:);
  end

  return;
end


% =======================
% 2 - with regularization
% =======================

% external regularization parameters
basis_weights = get_option(varargin, {'basis_weights','basisweights'}, ones(dim, 1));
mincond       = get_option(varargin, {'mincond','minCond','min_cond'}, 1e2);
maxcond       = get_option(varargin, {'maxcond','maxCond','max_cond'}, 1e4);

% internal regularization parameters
targetcond = mincond;
basis_weights_scale = 4;
useOnesideRegularization = false; % only captures locality along axis direction, 
                                  %   but not along diagonal directions
sideMin = 0.3;
sideMax = 0.8;
sideLambdaRel = .1; % side regularization strength as part of maxeig

% build unregularized Gram system
Gram_book = pagemtimes(pagetranspose(B_book), B_book);
Gram_book = (Gram_book + pagetranspose(Gram_book)) / 2;
rhs_book = pagemtimes(pagetranspose(B_book), fw_book);
clear fw_book B_book;

% eigenvalues of the unregularized scaled Gram matrix
eigval = pagesvd(Gram_book);
maxeig = reshape(max(eigval, [], 1), [], 1);
mineig = reshape(min(eigval, [], 1), [], 1);
mineig = max(mineig, 0);
mineig_safe = max(mineig, eigFloorRel .* max(maxeig, 1));
cond = maxeig ./ mineig_safe;
clear eigval;

% compute regularization parameter from condition of unregularized Gram matrix
targetcond = max(targetcond, 1 + 10*eps);
t = (log10(cond) - log10(mincond)) ./ (log10(maxcond) - log10(mincond));
t = smoothstepC3(t);
% compute lambda such that target condition is obtained 
lambdaNeeded = max(0, (maxeig - targetcond .* mineig) ./ (targetcond - 1));
% apply regularization, but not more than is needed for the target condition
lambdaCond = t .* lambdaNeeded;

% a strong correlation between column 1 and nonconstant columns indicates that
%   neighbors are on one side w.r.t. the center
% we check this and, if needed, apply additional regularization
lambdaOneside = zeros(N, 1);
if useOnesideRegularization && dim > 1
  % compute maximal inner product of const function with the other ones
  sideScore = reshape(max(abs(Gram_book(1, 2:end, :)), [], 2), [], 1);
  % map to [0,1], apply smoothing function
  Oneside = smoothstepC3((sideScore - sideMin) ./ (sideMax - sideMin));
  % compute regularization parameter for Oneside problem
  lambdaOneside = sideLambdaRel .* Oneside .* 1; 
  %   (after column normalization, the mean eigenvalue is 1, and we scale by it)
end

% compute the total regulariation strength
lambdaTotal = lambdaCond + lambdaOneside;

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

% apply the regularization 
diag_idx = pageDiagIndices(dim, N);
diagOffsets = reshape(basis_weights, dim, 1, 1) .* reshape(lambdaTotal, 1, 1, N);
Gram_book(diag_idx) = Gram_book(diag_idx) + diagOffsets(:);
Gram_book = (Gram_book + pagetranspose(Gram_book)) / 2;

% solve for scaled coeffs, then 'unscale' to obtain the original coeffs
c_book = pagemldivide(Gram_book, rhs_book) ./ pagetranspose(s_book);

% compute condition numbers, if they are needed for the output
if nargout > 1
  eigReg = pagesvd(Gram_book);
  maxeigReg = reshape(max(eigReg, [], 1), [], 1);
  mineigReg = reshape(min(eigReg, [], 1), [], 1);
  conds = maxeigReg ./ mineigReg;
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
  diagInPage = (1 : dim+1 : dim^2).';
  pageOffset = (0 : N-1) .* dim^2;
  idx = reshape(diagInPage + pageOffset, [], 1);
end