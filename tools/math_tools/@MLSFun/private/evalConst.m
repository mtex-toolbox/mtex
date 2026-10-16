function [vals,warnings] = evalConst(F,v,varargin)
% degree-zero MLS, a local weighted average
%
% The warning flags are returned to eval, which emits them once.

v = v(:);
N = numel(v);
numf = numel(F);
warnings = initWarnings;

gridVals = reshape(F.values(:),numel(F.nodes),numf);

% degree zero is not split into components by eval, so average componentwise here
perComponent = F.detectOutliers && size(F.outlierIndicators,2) > 1;

if F.delta == 0 % KNN

  nn = candidateCount(F);
  [ind,dist] = F.nodes.find(v,nn,varargin{:});

  if F.use_smooth_delta
    deltas = F.supportMargin * get_option(varargin,'smoothDelta',[]);
    deltas = max(real(deltas(:)),realmin);

    weights = F.w(dist ./ deltas);
    deltaFallback = sum(weights > 0,2) < F.dim;
    if any(deltaFallback)
      fallbackDelta = F.supportMargin * dist(:,F.dim);
      deltas(deltaFallback) = max(deltas(deltaFallback),fallbackDelta(deltaFallback));
      weights(deltaFallback,:) = F.w(dist(deltaFallback,:) ./ deltas(deltaFallback));
    end

    positiveCount = sum(weights > 0,2);
    warnings.smoothTooFew = any(deltaFallback | positiveCount < F.dim);
    warnings.smoothAllCandidates = any(~F.subsample & positiveCount == nn & ...
      min(weights,[],2) > F.candidateTol * max(weights,[],2));
  else
    deltas = max(real(F.supportMargin * max(dist,[],2)),realmin);
    weights = F.w(dist ./ deltas);
  end

  weights = max(real(weights .* F.vor_weights(ind)),0);

  if perComponent
    vals = zeros(N,numf);
    % with a second subscript the N × nn layout of ind has to be restored
    for j = 1:numf
      weightsJ = weights .* exp(-reshape(F.outlierIndicators(ind,j),size(ind)));
      vals(:,j) = sum(weightsJ .* reshape(gridVals(ind,j),size(ind)),2) ./ ...
        max(sum(weightsJ,2),realmin);
    end
  else
    if F.detectOutliers
      weights = weights .* exp(-F.outlierIndicators(ind));
    end
    Wsum = sum(weights,2);
    if numf == 1
      vals = sum(weights .* gridVals(ind),2) ./ max(Wsum,realmin);
    else
      A = sparse(repmat((1:N).',nn,1),ind(:),weights(:),N,numel(F.nodes));
      vals = (A * gridVals) ./ max(Wsum,realmin);
    end
  end

else % range search

  [ind,dist] = F.nodes.find(v,F.delta);
  [gridId,centerId] = find(ind.');

  weights = F.w(dist(sub2ind(size(dist),centerId,gridId)) ./ F.delta);
  weights = max(real(weights .* F.vor_weights(gridId)),0);

  if perComponent
    vals = zeros(N,numf);
    for j = 1:numf
      weightsJ = weights .* exp(-F.outlierIndicators(gridId,j));
      vals(:,j) = accumarray(centerId,weightsJ .* gridVals(gridId,j),[N 1],@sum,0) ./ ...
        max(accumarray(centerId,weightsJ,[N 1],@sum,0),realmin);
    end
  else
    if F.detectOutliers
      weights = weights .* exp(-F.outlierIndicators(gridId));
    end
    Wsum = accumarray(centerId,weights,[N 1],@sum,0);
    if numf == 1
      vals = accumarray(centerId,weights .* gridVals(gridId),[N 1],@sum,0) ./ max(Wsum,realmin);
    else
      A = sparse(centerId,gridId,weights,N,numel(F.nodes));
      vals = (A * gridVals) ./ max(Wsum,realmin);
    end
  end

  % a center without a node within delta takes a minimal KNN neighborhood
  empty = ~any(ind,2);
  if any(empty)
    warnings.rangeTooFew = true;
    FK = F;
    FK.delta = 0;
    FK.oF = 1;
    [valsK,~,~,warningsK] = FK.eval(v.subSet(empty),varargin{:});
    vals(empty,:) = reshape(valsK,nnz(empty),numf);
    warnings = mergeWarnings(warnings,warningsK);
  end

end

if isalmostreal(F.values), vals = real(vals); end

end
