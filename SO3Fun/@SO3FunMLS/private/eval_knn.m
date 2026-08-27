function [vals, warnings, conds, info] = eval_knn(SO3F, ori, varargin)

% Evaluate one KNN batch. Warning flags are returned to eval and emitted there
% only once after all batches have been processed.

ori = ori(:);
N = numel(ori);
numf = numel(SO3F);
supportMargin = 1.10;
candidateTol = 1e-4;
wantConds = nargout > 2;
wantInfo = nargout > 3;
warnings = initWarnings;

% Smooth support radii need a candidate buffer because many candidates should
% lie outside the final compact support.
nn = candidate_count_SO3(SO3F);

[ind, dist] = SO3F.nodes.find(ori, nn, varargin{:});
if SO3F.subsample
  ind = SO3F.find_optimal_subset(ind, ori, varargin{:});
  nn = SO3F.dim;
end

% ind is N × nn, the local systems are the pages of nn × ... × N books
nn_total = nn * N;
grid_id = reshape(ind', nn_total, 1);
center_id = repelem((1:N)', nn);

if SO3F.subsample
  dist = angle(ori.subSet(center_id), SO3F.nodes.subSet(grid_id));
  dist = reshape(dist, nn, N)';
end


% local basis values, as nn_total × dim
if ~SO3F.centered
  % without crystal symmetry no neighbor has to be projected to the
  % fundamental region of its center, so the basis can be reused
  if (SO3F.CS.id == 1) && (nn_total > numel(SO3F.nodes))
    G = eval_basis_functions(SO3F);
    G = G(grid_id, :);

    if SO3F.antipodal && mod(SO3F.degree, 2) == 1
      I = sum(ori.subSet(center_id).abcd .* ...
        SO3F.nodes.subSet(grid_id).abcd, 2) < 0;
      G(I,:) = -G(I,:);
    end
  else
    projected = project2FundamentalRegion( ...
      SO3F.nodes.subSet(grid_id), ori.subSet(center_id));
    G = eval_basis_functions(SO3F, projected);
  end

  g_book = permute(eval_basis_functions(SO3F, ori), [2, 3, 1]);

  % the geometry score describes the local node cloud in the tangent space, so
  % the diagnostic needs local coordinates even for a non-centered basis
  if wantInfo
    [~, ~, bloc, cloc, dloc] = ...
      local_coordinates_SO3(ori, center_id, SO3F.nodes, grid_id);
  end
else
  if wantInfo
    [rotneighbors, aloc, bloc, cloc, dloc] = ...
      local_coordinates_SO3(ori, center_id, SO3F.nodes, grid_id);
  else
    [rotneighbors, aloc] = ...
      local_coordinates_SO3(ori, center_id, SO3F.nodes, grid_id);
  end

  G = eval_basis_functions(SO3F, rotneighbors);

  if SO3F.antipodal && mod(SO3F.degree, 2) == 1
    I = aloc < 0;
    G(I,:) = -G(I,:);
  end

  % in centered coordinates evaluation is always at the identity
  g_book = eval_basis_functions(SO3F, orientation.id).';
end

G_book = permute(reshape(G, nn, N, SO3F.dim), [1, 3, 2]);
clear G center_id aloc rotneighbors projected;
if ~wantInfo, clear bloc cloc dloc; end


% compact local weights
if SO3F.use_smooth_delta
  deltas = supportMargin * get_option(varargin, 'smoothDelta', []);
  deltas = max(real(deltas(:)), realmin);

  % Enlarge the smooth radius only where it would leave fewer than dim
  % positive-weight rows in the local least-squares problem.
  weights = SO3F.w(dist ./ deltas);
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

  % the KNN cutoff may truncate the compact support, but only a candidate with a
  % numerically relevant weight actually contributes
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

% ind has the N × nn layout of the weights, no reordering is needed here
weights = weights .* SO3F.vor_weights(ind) * pi^2 / numel(SO3F.nodes);

if SO3F.detectOutliers
  weights = weights .* exp(-SO3F.outlierIndicators(ind));
end

weights = max(real(weights), 0);
W_book = permute(weights, [2, 3, 1]);

% local geometry of the weighted neighborhoods, as it enters the local systems
if wantInfo
  geometryScore = local_geometry_score_SO3( ...
    reshape(bloc, nn, N), reshape(cloc, nn, N), reshape(dloc, nn, N), ...
    weights.');
end

clear ind weights dist deltas bloc cloc dloc;


% set up the local function values
grid_vals = reshape(SO3F.values(:), numel(SO3F.nodes), numf);
f_book = permute(reshape(grid_vals(grid_id,:), nn, N, numf), [1, 3, 2]);
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
  info.geometryScore = geometryScore;
elseif wantConds
  [c_book, conds] = ...
    solve_lsq_book_constsize(W_book, G_book, f_book, solve_args{:});
else
  c_book = solve_lsq_book_constsize( ...
    W_book, G_book, f_book, solve_args{:});
end
clear W_book G_book f_book solve_args;

% evaluate the local coefficient vectors
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
