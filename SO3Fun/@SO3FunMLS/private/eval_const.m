function [vals, warnings] = eval_const(SO3F, ori, varargin)

% Degree-zero MLS is a local weighted average. Smooth-support warning flags are
% returned to eval and emitted there only once.

ori = ori(:);
N = numel(ori);
numf = numel(SO3F);
supportMargin = 1.10;
candidateTol = 1e-4;
warnings = initWarnings;

grid_vals = reshape(SO3F.values(:), numel(SO3F.nodes), numf);

% degree zero is not split into components by eval, so average componentwise here
perComponent = SO3F.detectOutliers && ...
  (size(SO3F.outlierIndicators, 2) > 1);


% KNN mode
if (SO3F.delta == 0)
  nn = candidate_count_SO3(SO3F);
  [ind, dist] = SO3F.nodes.find(ori, nn, varargin{:});

  if SO3F.use_smooth_delta
    deltas = supportMargin * get_option(varargin, 'smoothDelta', []);
    deltas = max(real(deltas(:)), realmin);

    weights = SO3F.w(dist ./ deltas);
    deltaFallback = sum(weights > 0, 2) < SO3F.dim;

    if any(deltaFallback)
      fallbackDelta = supportMargin * dist(:,SO3F.dim);
      deltas(deltaFallback) = max( ...
        deltas(deltaFallback), fallbackDelta(deltaFallback));
      weights(deltaFallback,:) = ...
        SO3F.w(dist(deltaFallback,:) ./ deltas(deltaFallback));
    end

    positiveCount = sum(weights > 0, 2);
    warnings.smoothTooFew = any(deltaFallback | ...
      (positiveCount < SO3F.dim));

    % Only a candidate whose weight is numerically relevant can truncate the
    % intended compact support; see eval_knn.
    warnings.smoothAllCandidates = any(~SO3F.subsample & ...
      (positiveCount == nn) & ...
      (min(weights, [], 2) > candidateTol * max(weights, [], 2)));
  else
    deltas = max(real(supportMargin * max(dist, [], 2)), realmin);
    weights = SO3F.w(dist ./ deltas);
  end

  weights = weights .* SO3F.vor_weights(ind);
  weights = max(real(weights), 0);

  if perComponent
    vals = zeros(N, numf);
    % NOTE: with a second subscript the N-by-nn neighborhood layout of
    %   ind is lost, so it has to be restored explicitly
    for j = 1 : numf
      weights_j = weights .* ...
        exp(-reshape(SO3F.outlierIndicators(ind,j), size(ind)));
      Wsum = sum(weights_j, 2);
      vals(:,j) = sum(weights_j .* ...
        reshape(grid_vals(ind,j), size(ind)), 2) ./ max(Wsum, realmin);
    end
  else
    if SO3F.detectOutliers
      weights = weights .* exp(-SO3F.outlierIndicators(ind));
    end

    Wsum = sum(weights, 2);
    if numf == 1
      vals = sum(weights .* grid_vals(ind), 2) ./ max(Wsum, realmin);
    else
      center_id = repmat((1:N)', nn, 1);
      A = sparse(center_id, ind(:), weights(:), N, numel(SO3F.nodes));
      vals = (A * grid_vals) ./ max(Wsum, realmin);
    end
  end


% range mode
else
  [ind, dist] = SO3F.nodes.find(ori, SO3F.delta);
  [grid_id, center_id] = find(ind');

  I = sub2ind(size(dist), center_id, grid_id);
  weights = SO3F.w(dist(I) ./ SO3F.delta);
  weights = weights .* SO3F.vor_weights(grid_id);
  weights = max(real(weights), 0);

  if perComponent
    vals = zeros(N, numf);
    for j = 1 : numf
      weights_j = weights .* exp(-SO3F.outlierIndicators(grid_id,j));
      Wsum = accumarray(center_id, weights_j, [N, 1], @sum, 0);
      vals(:,j) = accumarray(center_id, ...
        weights_j .* grid_vals(grid_id,j), [N, 1], @sum, 0) ./ ...
        max(Wsum, realmin);
    end
  else
    if SO3F.detectOutliers
      weights = weights .* exp(-SO3F.outlierIndicators(grid_id));
    end

    Wsum = accumarray(center_id, weights, [N, 1], @sum, 0);
    if numf == 1
      vals = accumarray(center_id, weights .* grid_vals(grid_id), ...
        [N, 1], @sum, 0) ./ max(Wsum, realmin);
    else
      A = sparse(center_id, grid_id, weights, N, numel(SO3F.nodes));
      vals = (A * grid_vals) ./ max(Wsum, realmin);
    end
  end
end

if isalmostreal(SO3F.values), vals = real(vals); end

end


function warnings = initWarnings
  warnings = struct;
  warnings.rangeTooFew = false;
  warnings.rangeTooMany = false;
  warnings.smoothTooFew = false;
  warnings.smoothAllCandidates = false;
end
