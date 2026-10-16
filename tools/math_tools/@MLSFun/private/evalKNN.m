function [vals,warnings,conds,info] = evalKNN(F,v,varargin)
% evaluate one batch of centers with KNN neighborhoods
%
% The warning flags are returned to eval, which emits them once for all
% batches.

v = v(:);
N = numel(v);
numf = numel(F);
wantConds = nargout > 2;
wantInfo = nargout > 3;
warnings = initWarnings;

% a smooth support radius needs a buffer of candidates outside the support
nn = candidateCount(F);

[ind,dist] = F.nodes.find(v,nn,varargin{:});
if F.subsample
  ind = findOptimalSubset(F,ind,v,varargin{:});
  nn = F.dim;
  dist = reshape(angle(v.subSet(repelem((1:N).',nn,1)), ...
    F.nodes.subSet(reshape(ind.',[],1))),nn,N).';
end

% compact local weights
if F.use_smooth_delta
  deltas = F.supportMargin * get_option(varargin,'smoothDelta',[]);
  deltas = max(real(deltas(:)),realmin);

  % enlarge the radius only where fewer than dim rows would carry weight
  weights = F.w(dist ./ deltas);
  deltaFallback = sum(weights > 0,2) < F.dim;
  if any(deltaFallback)
    if F.subsample
      fallbackDelta = F.supportMargin * max(dist,[],2);
    else
      fallbackDelta = F.supportMargin * dist(:,F.dim);
    end
    deltas(deltaFallback) = max(deltas(deltaFallback),fallbackDelta(deltaFallback));
    weights(deltaFallback,:) = F.w(dist(deltaFallback,:) ./ deltas(deltaFallback));
  end

  positiveCount = sum(weights > 0,2);
  warnings.smoothTooFew = any(deltaFallback | positiveCount < F.dim);

  % only a candidate with a relevant weight can truncate the compact support
  candidateLimit = ~F.subsample & positiveCount == nn & ...
    min(weights,[],2) > F.candidateTol * max(weights,[],2);
  warnings.smoothAllCandidates = any(candidateLimit);
else
  deltas = max(real(F.supportMargin * max(dist,[],2)),realmin);
  weights = F.w(dist ./ deltas);
  deltaFallback = false(N,1);
  candidateLimit = false(N,1);
end

% Voronoi and outlier factors, ind has the N × nn layout of the weights
weights = weights .* F.vor_weights(ind);
if F.detectOutliers
  weights = weights .* exp(-F.outlierIndicators(ind));
end
weights = max(real(weights),0);

% the candidates come sorted by distance, so the columns beyond the last
% positive weight carry no weight at any center and drop out
if ~F.subsample
  nn = max([find(any(weights > 0,1),1,'last'),1]);
  ind = ind(:,1:nn);
  weights = weights(:,1:nn);
end
WBook = permute(weights,[2 3 1]);
clear weights dist deltas

% ind is N × nn, the local systems are the pages of nn × ... × N books
gridId = reshape(ind.',[],1);
centerId = repelem((1:N).',nn,1);
clear ind

[G,basisAtCenters] = localBasis(F,v,centerId,gridId);
GBook = permute(reshape(G,nn,N,F.dim),[1 3 2]);
gBook = permute(basisAtCenters,[2 3 1]);
clear G centerId

% local function values
gridVals = reshape(F.values(:),numel(F.nodes),numf);
fBook = permute(reshape(gridVals(gridId,:),nn,N,numf),[1 3 2]);
clear gridId gridVals

solveArgs = solveOptions(F,gBook,varargin{:});
if wantInfo
  [cBook,conds,info] = solve_lsq_book_constsize(WBook,GBook,fBook,solveArgs{:});
  info.deltaFallback = deltaFallback;
  info.candidateLimit = candidateLimit;
elseif wantConds
  [cBook,conds] = solve_lsq_book_constsize(WBook,GBook,fBook,solveArgs{:});
else
  cBook = solve_lsq_book_constsize(WBook,GBook,fBook,solveArgs{:});
end

% evaluate the local coefficient vectors
vals = permute(sum(cBook .* gBook,1),[3 2 1]);
if isalmostreal(F.values), vals = real(vals); end

end
