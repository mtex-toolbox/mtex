function vals = eval_const(S2F, v, varargin)

% evaluate degree-zero MLS directly as a weighted average

v = v(:);
N = numel(v);
numf = numel(S2F);
supportMargin = 1.10;

grid_vals = reshape(S2F.values(:), numel(S2F.nodes), numf);

% =====================================
% KNN-search mode
% =====================================
if (S2F.delta == 0)
  nn = S2F.nn * (1 + S2F.use_smooth_delta);
  [ind, dist] = S2F.nodes.find(v, nn, varargin{:});

  if S2F.use_smooth_delta
    deltas = supportMargin * get_option(varargin, 'smoothDelta', []);
    deltas = max(deltas(:), supportMargin * dist(:,S2F.nn));
  else
    deltas = supportMargin * max(dist, [], 2);
  end

  deltas = max(real(deltas(:)), realmin);
  weights = S2F.w(dist ./ deltas);
  weights = weights .* S2F.vor_weights(ind);

  if S2F.detectOutliers
    weights = weights .* exp(-S2F.outlierIndicators(ind));
  end

  weights = max(real(weights), 0);
  Wsum = sum(weights, 2);

  if numf == 1
    vals = sum(weights .* grid_vals(ind), 2) ./ max(Wsum, realmin);
  else
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

  I = sub2ind(size(dist), v_id, grid_id);
  weights = S2F.w(dist(I) ./ S2F.delta);
  weights = weights .* S2F.vor_weights(grid_id);

  if S2F.detectOutliers
    weights = weights .* exp(-S2F.outlierIndicators(grid_id));
  end

  weights = max(real(weights), 0);
  Wsum = accumarray(v_id, weights, [N, 1], @sum, 0);

  if numf == 1
    vals = accumarray(v_id, weights .* grid_vals(grid_id), ...
      [N, 1], @sum, 0);
    vals = vals ./ max(Wsum, realmin);
  else
    A = sparse(v_id, grid_id, weights, N, numel(S2F.nodes));
    vals = A * grid_vals;
    vals = vals ./ max(Wsum, realmin);
  end
end

if isalmostreal(S2F.values)
  vals = real(vals);
end

end
