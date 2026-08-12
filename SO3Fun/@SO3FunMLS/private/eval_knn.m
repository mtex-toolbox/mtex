function [vals, warnings, conds, info] = eval_knn(SO3F, ori, varargin)

% Evaluate one KNN batch. Warning flags are returned to eval and emitted there
% only once after all batches have been processed.

ori = ori(:);
N = numel(ori);
supportMargin = 1.10;
candidateTol = 1e-4;
wantConds = nargout > 2;
wantInfo = nargout > 3;
warnings = initWarnings;

% Smooth support radii need a candidate buffer because many candidates should
% lie outside the final compact support.
nn = candidate_count_SO3(SO3F);
nn_total = nn * N;

[ind, dist] = SO3F.nodes.find(ori, nn, varargin{:}, ...
  'searcher', SO3F.searcher);
if SO3F.subsample
  ind = SO3F.find_optimal_subset(ind, ori, varargin{:});
  nn = SO3F.dim;
  nn_total = nn * N;
end

grid_id = reshape(ind', nn_total, 1);
ori_id = repelem((1:N)', nn);

if SO3F.subsample
  dist = angle(ori.subSet(ori_id), SO3F.nodes.subSet(grid_id));
  dist = reshape(dist, SO3F.dim, N)';
end


% evaluate the local basis
if ~SO3F.centered
  if (SO3F.CS.id == 1) && (nn_total > numel(SO3F.nodes))
    G = eval_basis_functions(SO3F);
    G = G(grid_id, :).';

    if SO3F.antipodal && mod(SO3F.degree, 2) == 1
      I = sum(ori.subSet(ori_id).abcd .* ...
        SO3F.nodes.subSet(grid_id).abcd, 2) < 0;
      G(:,I) = -G(:,I);
    end
  else
    projected = project2FundamentalRegion( ...
      SO3F.nodes(grid_id), ori(ori_id));
    G = eval_basis_functions(SO3F, projected).';
  end

  g_book = reshape(eval_basis_functions(SO3F, ori).', ...
    SO3F.dim, 1, N);
else
  [rotneighbors, aloc] = ...
    local_coordinates_SO3(ori, ori_id, SO3F.nodes, grid_id);

  G = eval_basis_functions(SO3F, rotneighbors).';

  if SO3F.antipodal && mod(SO3F.degree, 2) == 1
    I = aloc < 0;
    G(:,I) = -G(:,I);
  end

  % In centered coordinates evaluation is always at the identity.
  g_book = eval_basis_functions(SO3F, orientation.id).';
end

G_book = permute(reshape(G, SO3F.dim, nn, N), [2, 1, 3]);
clear G ori_id aloc rotneighbors projected;


% compute compact local weights
if SO3F.use_smooth_delta
  deltas = supportMargin * get_option(varargin, 'smoothDelta', []);
  deltas = max(real(deltas(:)), realmin);
  weights = SO3F.w(dist ./ deltas);

  % Enlarge the smooth radius only where it would leave fewer than dim
  % positive-weight rows. Fewer than the nominal SO3F.nn rows are allowed.
  deltaFallback = sum(weights > 0, 2) < SO3F.dim;
  if any(deltaFallback)
    if SO3F.subsample
      fallbackDelta = supportMargin * max(dist, [], 2);
    else
      fallbackDelta = supportMargin * dist(:,SO3F.dim);
    end

    deltas(deltaFallback) = max( ...
      deltas(deltaFallback), fallbackDelta(deltaFallback));
    weights(deltaFallback,:) = ...
      SO3F.w(dist(deltaFallback,:) ./ deltas(deltaFallback));
  end

  positiveCount = sum(weights > 0, 2);
  warnings.smoothTooFew = any(deltaFallback | ...
    (positiveCount < SO3F.dim));

  % If every fetched candidate has positive weight, the artificial KNN cutoff
  % may truncate the intended compact support. Only a candidate that still
  % carries a numerically relevant weight actually contributes to the local
  % system; smooth weight functions have decayed to rounding level at the
  % support boundary, where dropping a node changes nothing.
  candidateLimit = ~SO3F.subsample & (positiveCount == nn) & ...
    (min(weights, [], 2) > candidateTol * max(weights, [], 2));
  warnings.smoothAllCandidates = any(candidateLimit);
else
  deltas = supportMargin * max(dist, [], 2);
  deltas = max(real(deltas(:)), realmin);
  weights = SO3F.w(dist ./ deltas);
  deltaFallback = false(N, 1);
  candidateLimit = false(N, 1);
end

vor_weights = reshape(SO3F.vor_weights(grid_id), nn, N)';
weights = weights .* vor_weights * pi^2 / numel(SO3F.nodes);

if SO3F.detectOutliers
  oI = SO3F.outlierIndicators;
  if isempty(oI), oI = SO3F.compute_outlier_indicators; end
  oI = reshape(oI(grid_id), nn, N)';
  weights = weights .* exp(-oI);
end

W_book = permute(max(real(weights), 0), [2, 3, 1]);
clear weights dist deltas vor_weights oI;


% set up local function values
grid_vals = reshape(SO3F.values(:), numel(SO3F.nodes), numel(SO3F));
f_book = permute(reshape(grid_vals(grid_id,:), ...
  nn, N, numel(SO3F)), [1, 3, 2]);
clear grid_id grid_vals;


% solve the local systems
solve_args = {'eval_vector', g_book};
if SO3F.centered
  solve_args = [solve_args, {'centered_evaluation'}];
end
if SO3F.regularize
  solve_args = [solve_args, {'regularize', ...
    'mincond', SO3F.mincond, 'maxcond', SO3F.maxcond, ...
    'targetcond', SO3F.targetcond, ...
    'basis_degrees', basis_degrees_SO3(SO3F), ...
    'degree_laplace_shift', 2}];
end
solve_args = [solve_args, varargin];

if wantInfo
  [c_book, conds, info] = ...
    solve_lsq_book_constsize(W_book, G_book, f_book, solve_args{:});
  info.deltaFallback = deltaFallback;
  info.candidateLimit = candidateLimit;
elseif wantConds
  [c_book, conds] = ...
    solve_lsq_book_constsize(W_book, G_book, f_book, solve_args{:});
else
  c_book = solve_lsq_book_constsize( ...
    W_book, G_book, f_book, solve_args{:});
end
clear f_book G_book W_book solve_args;

vals = permute(sum(c_book .* g_book, 1), [3, 2, 1]);
if isalmostreal(SO3F.values), vals = real(vals); end

end


function warnings = initWarnings
  warnings = struct;
  warnings.rangeTooFew = false;
  warnings.rangeTooMany = false;
  warnings.smoothTooFew = false;
  warnings.smoothAllCandidates = false;
end
