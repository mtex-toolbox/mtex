function [vals, warnings, conds, info] = eval_knn(S2F, v, varargin)

% Evaluate one KNN batch. Warning flags are returned to eval and emitted there
% only once after all batches have been processed.

v = v(:);
N = numel(v);
supportMargin = 1.10;
candidateTol = 1e-4;
wantConds = nargout > 2;
wantInfo = nargout > 3;
warnings = initWarnings;

% Smooth support radii need a candidate buffer because many candidates should
% lie outside the final compact support.
nn = candidate_count_S2(S2F);
nn_total = nn * N;

[ind, dist] = S2F.nodes.find(v, nn, varargin{:});
if S2F.subsample
  ind = S2F.find_optimal_subset(ind, v, varargin{:});
  nn = S2F.dim;
  nn_total = nn * N;
end

grid_id = reshape(ind', nn_total, 1);
v_id = repelem((1:N)', nn);

if S2F.subsample
  dist = angle(v.subSet(v_id), S2F.nodes.subSet(grid_id));
  dist = reshape(dist, S2F.dim, N)';
end

% local basis values
if ~S2F.centered
  if nn_total > numel(S2F.nodes.x)
    G = eval_basis_functions(S2F);
    G = G(grid_id, :).';
  else
    G = eval_basis_functions(S2F, S2F.nodes(grid_id)).';
  end

  if S2F.antipodal && mod(S2F.degree, 2) == 1
    I = sum(v.subSet(v_id).xyz .* ...
      S2F.nodes.subSet(grid_id).xyz, 2) < 0;
    G(:,I) = -G(:,I);
  end

  g_book = reshape(eval_basis_functions(S2F, v).', S2F.dim, 1, N);

  % the geometry score describes the local node cloud in the tangent frame, so
  % the diagnostic needs local coordinates even for a non-centered basis
  if wantInfo
    [xloc, yloc] = local_coordinates_S2(v, v_id, S2F.nodes, grid_id);
  end
else
  [xloc, yloc, zloc] = ...
    local_coordinates_S2(v, v_id, S2F.nodes, grid_id);

  G = eval_basis_functions(S2F, vector3d(xloc, yloc, zloc)).';

  if S2F.antipodal && mod(S2F.degree, 2) == 1
    I = zloc < 0;
    G(:,I) = -G(:,I);
  end

  g_book = eval_basis_functions(S2F, vector3d.Z).';
end

G_book = permute(reshape(G, S2F.dim, nn, N), [2, 1, 3]);
clear G v_id zloc;
if ~wantInfo, clear xloc yloc; end

% compact local weights
if S2F.use_smooth_delta
  deltas = supportMargin * get_option(varargin, 'smoothDelta', []);
  deltas = max(real(deltas(:)), realmin);

  % Enlarge the smooth radius only where it would leave fewer than dim
  % positive-weight rows in the local least-squares problem.
  weights = S2F.w(dist ./ deltas);
  deltaFallback = sum(weights > 0, 2) < S2F.dim;

  if any(deltaFallback)
    if S2F.subsample
      fallbackDelta = supportMargin * max(dist, [], 2);
    else
      fallbackDelta = supportMargin * dist(:,S2F.dim);
    end

    deltas(deltaFallback) = max( ...
      deltas(deltaFallback), fallbackDelta(deltaFallback));
    weights(deltaFallback,:) = ...
      S2F.w(dist(deltaFallback,:) ./ deltas(deltaFallback));
  end

  positiveCount = sum(weights > 0, 2);
  warnings.smoothTooFew = any(deltaFallback | ...
    (positiveCount < S2F.dim));

  % If every fetched candidate has positive weight, the artificial KNN cutoff
  % may truncate the intended compact support. Only a candidate that still
  % carries a numerically relevant weight actually contributes to the local
  % system; smooth weight functions have decayed to rounding level at the
  % support boundary, where dropping a node changes nothing.
  candidateLimit = ~S2F.subsample & (positiveCount == nn) & ...
    (min(weights, [], 2) > candidateTol * max(weights, [], 2));
  warnings.smoothAllCandidates = any(candidateLimit);
else
  deltas = supportMargin * max(dist, [], 2);
  deltas = max(real(deltas(:)), realmin);
  weights = S2F.w(dist ./ deltas);
  deltaFallback = false(N, 1);
  candidateLimit = false(N, 1);
end

vor_weights = reshape(S2F.vor_weights(grid_id), nn, N)';
weights = weights .* vor_weights * 4*pi / numel(S2F.nodes);

if S2F.detectOutliers
  oI = reshape(S2F.outlierIndicators(grid_id), nn, N)';
  weights = weights .* exp(-oI);
end

weights = max(real(weights), 0);
W_book = permute(weights, [2, 3, 1]);

% local geometry of the weighted neighborhoods, as it enters the local systems
if wantInfo
  geometryScore = local_geometry_score( ...
    reshape(xloc, nn, N), reshape(yloc, nn, N), weights.');
end

clear weights dist deltas vor_weights xloc yloc;

% local function values
grid_vals = reshape(S2F.values(:), numel(S2F.nodes), numel(S2F));
f_book = permute(reshape(grid_vals(grid_id,:), ...
  nn, N, numel(S2F)), [1, 3, 2]);
clear grid_id grid_vals;

% solve the local systems
solve_args = {'eval_vector', g_book};
if S2F.centered
  solve_args = [solve_args, {'centered_evaluation'}];
end
if S2F.regularize
  solve_args = [solve_args, {'regularize', ...
    'mincond', S2F.mincond, 'maxcond', S2F.maxcond, ...
    'targetcond', S2F.targetcond, ...
    'basis_degrees', basis_degrees_S2(S2F)}];
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
  c_book = solve_lsq_book_constsize(W_book, G_book, f_book, solve_args{:});
end

vals = permute(sum(c_book .* g_book, 1), [3, 2, 1]);
if isalmostreal(S2F.values), vals = real(vals); end

end


function warnings = initWarnings
  warnings = struct;
  warnings.rangeTooFew = false;
  warnings.rangeTooMany = false;
  warnings.smoothTooFew = false;
  warnings.smoothAllCandidates = false;
end
