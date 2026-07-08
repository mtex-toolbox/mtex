function vals = eval_const(S2F, v, varargin)

% evaluate degree zero MLS directly as weighted average
% this avoids setting up and solving local least squares systems

% get parameters
v = v(:);
N = numel(v);
numf = numel(S2F);

% reshape function values to node x function format
grid_vals = reshape(S2F.values(:), numel(S2F.nodes), numf);

% distinguish between knn-search and range-search

% =====================================
% knn-search mode
% =====================================
if (S2F.delta == 0)
  % if delta should be smooth, we first draw more neighbors than necessary
  %   (some of the weights will turn out to be zero after computing delta(x))
  nn = S2F.nn * (1 + S2F.use_smooth_delta);

  [ind, dist] = S2F.nodes.find(v, nn, varargin{:});

  % compute distances and weights, or get the precomputed smoothDelta-values
  if S2F.use_smooth_delta
    deltas = get_option(varargin, 'smoothDelta', []);
  else
    deltas = 1.05 * max(dist, [], 2);
  end

  % compute weights
  deltas = max(real(deltas(:)), realmin);
  weights = S2F.w(dist ./ deltas);

  % apply voronoi weights
  weights = weights .* S2F.vor_weights(ind);

  if (S2F.detectOutliers == true)
    oI = computeOutlierIndicators(S2F);
    weights = weights .* exp(-oI(ind));
    clear oI;
  end

  weights = max(real(weights), 0);
  Wsum = sum(weights, 2);

  % compute weighted average
  if numf == 1
    vals = sum(weights .* grid_vals(ind), 2) ./ max(Wsum, realmin);
  else
    % sparse matrix contains all local averaging weights
    % this avoids looping over all components of S2F.values
    v_id = repmat((1:N)', nn, 1);
    A = sparse(v_id, ind(:), weights(:), N, numel(S2F.nodes));
    vals = A * grid_vals;
    vals = vals ./ max(Wsum, realmin);
  end

  
% =====================================
% range-search mode
% =====================================
else
  [ind, dist] = S2F.nodes.find(v, S2F.delta);
  [grid_id, v_id] = find(ind');

  % compute weights
  % dist(find(ind)) instead of nonzeros(dist), since elements of v might be
  %   contained in S2F.nodes ==> distance 0, but in neighborhood
  I = sub2ind(size(dist), v_id, grid_id);
  weights = S2F.w(dist(I) ./ S2F.delta);

  % apply voronoi weights
  weights = weights .* S2F.vor_weights(grid_id);

  if (S2F.detectOutliers == true)
    oI = S2F.outlierIndicators(grid_id);
    weights = weights .* exp(-oI(grid_id));
    clear oI;
  end

  weights = max(real(weights), 0);
  Wsum = accumarray(v_id, weights, [N, 1], @sum, 0);

  % compute weighted average
  if numf == 1
    vals = accumarray(v_id, weights .* grid_vals(grid_id), ...
      [N, 1], @sum, 0);
    vals = vals ./ max(Wsum, realmin);
  else
    % sparse matrix contains all local averaging weights
    % this is convenient for variable-size neighborhoods
    A = sparse(v_id, grid_id, weights, N, numel(S2F.nodes));
    vals = A * grid_vals;
    vals = vals ./ max(Wsum, realmin);
  end
end

if isalmostreal(S2F.values)
  vals = real(vals);
end

end