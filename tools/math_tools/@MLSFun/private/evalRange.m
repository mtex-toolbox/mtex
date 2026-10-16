function [vals,warnings,conds,info] = evalRange(F,v,varargin)
% evaluate one batch of centers with fixed-radius neighborhoods
%
% Neighborhoods with too few or too many nodes are evaluated by KNN
% instead. The warning flags are returned to eval, which emits them once
% for all batches.

v = v(:);
N0 = numel(v);
numf = numel(F);
wantInfo = nargout > 3;
warnings = initWarnings;

vals = zeros(N0,numf);
conds = zeros(N0,1);
if wantInfo, info = initRegInfo(N0); end

[ind,dist] = F.nodes.find(v,F.delta);
nn = full(sum(ind,2));

% too few nodes would interpolate, with an unbounded expected Lebesgue
% constant, too many exceed oF_max - both get a KNN neighborhood instead
tooFew = nn <= F.dim;
tooMany = nn > F.dim * F.oF_max;
warnings.rangeTooFew = any(tooFew);
warnings.rangeTooMany = any(tooMany);
if any(tooFew | tooMany) && F.use_smooth_delta && isempty(F.auxgrid)
  F = F.init_auxgrid;
end

fallback = {tooFew,1; tooMany,F.oF_max};
for k = 1:2
  id = fallback{k,1};
  if ~any(id), continue; end

  % assigning oF also resets oF_max
  FK = F;
  FK.delta = 0;
  FK.oF = fallback{k,2};
  [valsK,condsK,infoK,warningsK] = FK.eval(v.subSet(id),varargin{:});

  warnings = mergeWarnings(warnings,warningsK);
  vals(id,:) = reshape(valsK,nnz(id),numf);
  conds(id) = condsK;
  if wantInfo, info = insertRegInfo(info,id,infoK); end
end
if all(tooFew | tooMany), return; end

% the neighborhoods of moderate size
J = find(~(tooFew | tooMany));
v = v.subSet(J);
ind = ind(J,:);
dist = dist(J,:);

if F.subsample
  ind = findOptimalSubset(F,ind,v,varargin{:});
end

[gridId,centerId] = find(ind.');
nn = full(sum(ind,2));
clear ind

if F.subsample
  dist = sparse(centerId,gridId, ...
    angle(v.subSet(centerId),F.nodes.subSet(gridId)),numel(J),numel(F.nodes));
end

[G,basisAtCenters] = localBasis(F,v,centerId,gridId);

% compact local weights with Voronoi and outlier factors
weights = F.w(dist(sub2ind(size(dist),centerId,gridId)) ./ F.delta);
weights = weights .* F.vor_weights(gridId);
clear dist
if F.detectOutliers
  weights = weights .* exp(-F.outlierIndicators(gridId));
end
weights = max(real(weights),0);

% local function values
gridVals = reshape(F.values(:),numel(F.nodes),numf);
f = gridVals(gridId,:);
clear gridVals gridId centerId

solveArgs = solveOptions(F,permute(basisAtCenters,[2 3 1]),varargin{:});
if wantInfo
  [cBook,conds(J),infoJ] = solve_lsq_book_varsize(weights,G,f,nn,solveArgs{:});
  info = insertRegInfo(info,J,infoJ);
elseif nargout > 2
  [cBook,conds(J)] = solve_lsq_book_varsize(weights,G,f,nn,solveArgs{:});
else
  cBook = solve_lsq_book_varsize(weights,G,f,nn,solveArgs{:});
end
clear weights G f

% evaluate the local coefficient vectors
vals(J,:) = permute(sum(basisAtCenters .* permute(cBook,[3 1 2]),2),[1 3 2]);
if isalmostreal(F.values), vals = real(vals); end

end
