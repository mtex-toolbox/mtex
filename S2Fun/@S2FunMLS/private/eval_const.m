function [vals, warnings] = eval_const(S2F, v, varargin)

% Degree-zero MLS is a local weighted average. Smooth-support warning flags are
% returned to eval and emitted there only once.

v = v(:);
N = numel(v);
numf = numel(S2F);
supportMargin = 1.10;
candidateTol = 1e-4;
warnings = initWarnings;

grid_vals = reshape(S2F.values(:), numel(S2F.nodes), numf);

% degree zero is not split into components by eval, so average componentwise here
perComponent = S2F.detectOutliers && ...
  (size(S2F.outlierIndicators, 2) > 1);


% KNN mode
if (S2F.delta == 0)
  nn = candidate_count_S2(S2F);
  [ind, dist] = S2F.nodes.find(v, nn, varargin{:});

  if S2F.use_smooth_delta
    deltas = supportMargin * get_option(varargin, 'smoothDelta', []);
    deltas = max(real(deltas(:)), realmin);

    weights = S2F.w(dist ./ deltas);
    deltaFallback = sum(weights > 0, 2) < S2F.dim;

    if any(deltaFallback)
      fallbackDelta = supportMargin * dist(:,S2F.dim);
      deltas(deltaFallback) = max( ...
        deltas(deltaFallback), fallbackDelta(deltaFallback));
      weights(deltaFallback,:) = ...
        S2F.w(dist(deltaFallback,:) ./ deltas(deltaFallback));
    end

    positiveCount = sum(weights > 0, 2);
    warnings.smoothTooFew = any(deltaFallback | ...
      (positiveCount < S2F.dim));

    % Only a candidate whose weight is numerically relevant can truncate the
    % intended compact support; see eval_knn.
    warnings.smoothAllCandidates = any(~S2F.subsample & ...
      (positiveCount == nn) & ...
      (min(weights, [], 2) > candidateTol * max(weights, [], 2)));
  else
    deltas = max(real(supportMargin * max(dist, [], 2)), realmin);
    weights = S2F.w(dist ./ deltas);
  end

  weights = weights .* S2F.vor_weights(ind);
  weights = max(real(weights), 0);

  if perComponent
    vals = zeros(N, numf);
    % NOTE: with a second subscript the N-by-nn neighborhood layout of
    %   ind is lost, so it has to be restored explicitly
    for j = 1 : numf
      weights_j = weights .* ...
        exp(-reshape(S2F.outlierIndicators(ind,j), size(ind)));
      Wsum = sum(weights_j, 2);
      vals(:,j) = sum(weights_j .* ...
        reshape(grid_vals(ind,j), size(ind)), 2) ./ max(Wsum, realmin);
    end
  else
    if S2F.detectOutliers
      weights = weights .* exp(-S2F.outlierIndicators(ind));
    end

    Wsum = sum(weights, 2);
    if numf == 1
      vals = sum(weights .* grid_vals(ind), 2) ./ max(Wsum, realmin);
    else
      center_id = repmat((1:N)', nn, 1);
      A = sparse(center_id, ind(:), weights(:), N, numel(S2F.nodes));
      vals = (A * grid_vals) ./ max(Wsum, realmin);
    end
  end


% range mode
else
  [ind, dist] = S2F.nodes.find(v, S2F.delta);
  [grid_id, center_id] = find(ind');

  I = sub2ind(size(dist), center_id, grid_id);
  weights = S2F.w(dist(I) ./ S2F.delta);
  weights = weights .* S2F.vor_weights(grid_id);
  weights = max(real(weights), 0);

  if perComponent
    vals = zeros(N, numf);
    for j = 1 : numf
      weights_j = weights .* exp(-S2F.outlierIndicators(grid_id,j));
      Wsum = accumarray(center_id, weights_j, [N, 1], @sum, 0);
      vals(:,j) = accumarray(center_id, ...
        weights_j .* grid_vals(grid_id,j), [N, 1], @sum, 0) ./ ...
        max(Wsum, realmin);
    end
  else
    if S2F.detectOutliers
      weights = weights .* exp(-S2F.outlierIndicators(grid_id));
    end

    Wsum = accumarray(center_id, weights, [N, 1], @sum, 0);
    if numf == 1
      vals = accumarray(center_id, weights .* grid_vals(grid_id), ...
        [N, 1], @sum, 0) ./ max(Wsum, realmin);
    else
      A = sparse(center_id, grid_id, weights, N, numel(S2F.nodes));
      vals = (A * grid_vals) ./ max(Wsum, realmin);
    end
  end
end

if isalmostreal(S2F.values), vals = real(vals); end

end


function warnings = initWarnings
  warnings = struct;
  warnings.rangeTooFew = false;
  warnings.rangeTooMany = false;
  warnings.smoothTooFew = false;
  warnings.smoothAllCandidates = false;
end
