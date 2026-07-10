function vals = eval_const(SO3F, ori, varargin)

% evaluate degree zero MLS directly as weighted average
% this avoids setting up and solving local least squares systems

% get parameters
ori = ori(:);
N = numel(ori);
numf = numel(SO3F);

% reshape function values to node x function format
grid_vals = reshape(SO3F.values(:), numel(SO3F.nodes), numf);

if SO3F.detectOutliers && isempty(SO3F.outlierIndicators)
  SO3F.outlierIndicators = SO3F.compute_outlier_indicators;
end

% distinguish between knn-search and range-search

% =====================================
% knn-search mode
% =====================================
if (SO3F.delta == 0)
  % if delta should be smooth, we first draw more neighbors than necessary
  %   (some of the weights will turn out to be zero after computing delta(x))
  nn = SO3F.nn * (1 + SO3F.use_smooth_delta);

  [ind, dist] = SO3F.nodes.find(ori, nn, varargin{:}, 'searcher', SO3F.searcher);

  % compute distances and weights, or get the precomputed smoothDelta-values
  if SO3F.use_smooth_delta
    deltas = real(get_option(varargin, 'smoothDelta', []));
    deltas = deltas(:);

    % guarantee at least SO3F.dim positive-weight neighbors locally
    m = min(SO3F.dim, size(dist, 2));
    deltaSafe = 1.05 * dist(:,m);
    adjusted = deltas < deltaSafe;

    if any(adjusted)
      warning('SO3FunMLS:smoothDeltaAdjusted', ...
        ['The smooth support radius was increased at %d of %d evaluation ' ...
         'centers to avoid too small neighborhoods. The effective support ' ...
         'radius is therefore not fully smooth at these centers.'], ...
        nnz(adjusted), N);
    end

    deltas = max(deltas, deltaSafe);
  else
    deltas = 1.05 * max(dist, [], 2);
  end

  % compute weights
  deltas = max(deltas, realmin);
  weights = SO3F.w(dist ./ deltas);

  % apply voronoi weights
  weights = weights .* SO3F.vor_weights(ind);

  weights = max(real(weights), 0);

  % compute weighted average
  if SO3F.detectOutliers && ~isempty(SO3F.outlierIndicators) && size(SO3F.outlierIndicators,2) > 1
    vals = zeros(N, numf);
    for j = 1 : numf
      weights_j = weights .* exp(-SO3F.outlierIndicators(ind,j));
      Wsum = sum(weights_j, 2);
      vals(:,j) = sum(weights_j .* grid_vals(ind,j), 2) ./ max(Wsum, realmin);
    end
  else
    if (SO3F.detectOutliers == true)
      oI = SO3F.outlierIndicators;
      if isempty(oI), oI = SO3F.compute_outlier_indicators; end
      weights = weights .* exp(-oI(ind));
      clear oI;
    end

    Wsum = sum(weights, 2);

    if numf == 1
      vals = sum(weights .* grid_vals(ind), 2) ./ max(Wsum, realmin);
    else
      % sparse matrix contains all local averaging weights
      % this avoids looping over all components of SO3F.values
      ori_id = repmat((1:N)', nn, 1);
      A = sparse(ori_id, ind(:), weights(:), N, numel(SO3F.nodes));
      vals = A * grid_vals;
      vals = vals ./ max(Wsum, realmin);
    end
  end


% =====================================
% range-search mode
% =====================================
else
  [ind, dist] = SO3F.nodes.find(ori, SO3F.delta, 'searcher', SO3F.searcher);
  [grid_id, ori_id] = find(ind');

  % compute weights
  % dist(find(ind)) instead of nonzeros(dist), since elements of ori might be
  %   contained in SO3F.nodes ==> distance 0, but in neighborhood
  I = sub2ind(size(dist), ori_id, grid_id);
  weights = SO3F.w(dist(I) ./ SO3F.delta);

  % apply voronoi weights
  weights = weights .* SO3F.vor_weights(grid_id);

  weights = max(real(weights), 0);

  % compute weighted average
  if SO3F.detectOutliers && ~isempty(SO3F.outlierIndicators) && size(SO3F.outlierIndicators,2) > 1
    vals = zeros(N, numf);
    for j = 1 : numf
      weights_j = weights .* exp(-SO3F.outlierIndicators(grid_id,j));
      Wsum = accumarray(ori_id, weights_j, [N, 1], @sum, 0);
      vals(:,j) = accumarray(ori_id, weights_j .* grid_vals(grid_id,j), ...
        [N, 1], @sum, 0);
      vals(:,j) = vals(:,j) ./ max(Wsum, realmin);
    end
  else
    if (SO3F.detectOutliers == true)
      oI = SO3F.outlierIndicators;
      if isempty(oI), oI = SO3F.compute_outlier_indicators; end
      weights = weights .* exp(-oI(grid_id));
      clear oI;
    end

    Wsum = accumarray(ori_id, weights, [N, 1], @sum, 0);

    if numf == 1
      vals = accumarray(ori_id, weights .* grid_vals(grid_id), ...
        [N, 1], @sum, 0);
      vals = vals ./ max(Wsum, realmin);
    else
      % sparse matrix contains all local averaging weights
      % this is convenient for variable-size neighborhoods
      A = sparse(ori_id, grid_id, weights, N, numel(SO3F.nodes));
      vals = A * grid_vals;
      vals = vals ./ max(Wsum, realmin);
    end
  end
end

if isalmostreal(SO3F.values)
  vals = real(vals);
end

end
