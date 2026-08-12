function [vals, conds, info, warnings] = eval(SO3F, ori, varargin)
% evaluate SO3F by moving least squares
%
% The optional fourth output contains accumulated neighborhood warnings. When
% it is requested, the warnings are returned but not printed. This is used by
% nested evaluations in eval_range.

warnings = initWarnings;
emitWarnings = nargout < 4;
wantConds = nargout > 1;
wantInfo = nargout > 2;

if isempty(ori)
  vals = [];
  conds = [];
  info = initRegInfo(0);
  return;
end

if ~isa(ori, 'orientation')
  ori = orientation(ori, SO3F.CS, SO3F.SS);
end

% Use proper groups.
SO3F.CS = SO3F.CS.properGroup;
SO3F.SS = SO3F.SS.properGroup;
ori.CS = ori.CS.properGroup;
ori.SS = ori.SS.properGroup;

% Symmetrise with respect to the smaller side when both symmetries are active.
cs = ori.CS;
ss = ori.SS;
if cs.id ~= 1 && ss.id ~= 1
  if length(cs.rot) >= length(ss.rot)
    SO3F.nodes = ss * SO3F.nodes;
    SO3F.values = kron(SO3F.values, ones(numSym(ss),1));
    SO3F.vor_weights = kron(SO3F.vor_weights, ones(numSym(ss),1));
    if ~isempty(SO3F.outlierIndicators)
      SO3F.outlierIndicators = ...
        kron(SO3F.outlierIndicators, ones(numSym(ss),1));
    end
    SO3F.SS = specimenSymmetry.default;
    ori.SS = specimenSymmetry.default;
  else
    SO3F.nodes = SO3F.nodes * cs;
    SO3F.values = repmat(SO3F.values, numSym(cs), 1);
    SO3F.vor_weights = repmat(SO3F.vor_weights, numSym(cs), 1);
    if ~isempty(SO3F.outlierIndicators)
      SO3F.outlierIndicators = ...
        repmat(SO3F.outlierIndicators, numSym(cs), 1);
    end
    SO3F.CS = specimenSymmetry.default;
    ori.CS = specimenSymmetry.default;
  end

  SO3F.searcher = createns(SO3F.nodes.abcd);
  if SO3F.use_smooth_delta && (SO3F.delta == 0)
    SO3F = SO3F.init_auxgrid;
  end
end

if SO3F.detectOutliers && isempty(SO3F.outlierIndicators)
  SO3F.outlierIndicators = SO3F.compute_outlier_indicators;
end

dimensions = size(ori);
N = numel(ori);

% Degree zero is a weighted average and needs no local linear solves.
if (SO3F.degree == 0)
  if SO3F.use_smooth_delta && (SO3F.delta == 0)
    varargin = set_option(varargin, ...
      'smoothDelta', getSmoothDelta(SO3F, ori));
  end

  [vals, warnings_batch] = SO3F.eval_const(ori, varargin{:});
  warnings = mergeWarnings(warnings, warnings_batch);

  if isscalar(SO3F)
    vals = reshape(vals, dimensions);
  else
    vals = reshape(vals, [N, size(SO3F)]);
  end

  conds = [];
  info = initRegInfo(N);
  if wantInfo, info = reshapeRegInfo(info, dimensions); end
  if emitWarnings, issueWarnings(warnings, SO3F); end
  return;
end

% Avoid page-dimension problems in the local solver for one center.
if (N == 1)
  [vals, conds, info, warnings] = SO3F.eval([ori;ori], varargin{:});
  vals = reshape(vals(1,:), size(SO3F));
  if wantConds, conds = conds(1); end
  if wantInfo, info = sliceRegInfo(info, 1); end
  if emitWarnings, issueWarnings(warnings, SO3F); end
  return;
end

% Outlier indicators depend on the values. Evaluate vector-valued functions
% componentwise when outlier detection is active.
if (~isscalar(SO3F)) && SO3F.detectOutliers
  ori = ori(:);
  vals = zeros(numel(ori), numel(SO3F));

  SO3F1 = SO3F.subSet(1);
  if ~isempty(SO3F.outlierIndicators)
    SO3F1.outlierIndicators = SO3F.outlierIndicators(:,1);
  end
  [vals(:,1), conds, info, warnings] = ...
    SO3F1.eval(ori, varargin{:});

  for k = 2 : numel(SO3F)
    SO3Fk = SO3F.subSet(k);
    if ~isempty(SO3F.outlierIndicators) && ...
        size(SO3F.outlierIndicators,2) >= k
      SO3Fk.outlierIndicators = SO3F.outlierIndicators(:,k);
    end
    [vals(:,k), ~, ~, warnings_batch] = ...
      SO3Fk.eval(ori, varargin{:});
    warnings = mergeWarnings(warnings, warnings_batch);
  end

  vals = reshape(vals, [numel(ori), size(SO3F)]);
  if wantConds, conds = reshape(conds, dimensions); end
  if wantInfo, info = reshapeRegInfo(info, dimensions); end
  if emitWarnings, issueWarnings(warnings, SO3F); end
  return;
end

vals = zeros(N, numel(SO3F));
if wantConds, conds = zeros(N, 1); end
if wantInfo, info = initRegInfo(N); end

smoothDelta = [];
if (SO3F.delta == 0)
  nn = candidate_count_SO3(SO3F);
  if SO3F.use_smooth_delta
    % Compute the smooth support field once and reuse it in every batch.
    smoothDelta = getSmoothDelta(SO3F, ori);
  end
else
  % Fixed-radius neighborhoods are capped at this size in eval_range.
  nn = SO3F.dim * SO3F.oF_max;
end

% Keep the large pagewise arrays close to one GiB per batch.
numf = numel(SO3F);
bytes_per_ori = (3*nn*SO3F.dim + 7*SO3F.dim^2 + ...
  2*nn*numf + 2*SO3F.dim*numf) * 8;
batch_size = max(2, floor(2^30 / max(bytes_per_ori, 1)));

start_idx = 1;
while start_idx <= N
  end_idx = min(start_idx + batch_size - 1, N);
  I = (start_idx : end_idx)';
  start_idx = end_idx + 1;

  options = varargin;
  if (SO3F.delta == 0)
    if SO3F.use_smooth_delta
      options = [options(:)', {'smoothDelta'}, {smoothDelta(I)}];
    end

    if wantInfo
      [vals(I,:), warnings_batch, conds(I), info_batch] = ...
        eval_knn(SO3F, ori.subSet(I), options{:});
      info = insertRegInfo(info, I, info_batch);
    elseif wantConds
      [vals(I,:), warnings_batch, conds(I)] = ...
        eval_knn(SO3F, ori.subSet(I), options{:});
    else
      [vals(I,:), warnings_batch] = ...
        eval_knn(SO3F, ori.subSet(I), options{:});
    end
  else
    if wantInfo
      [vals(I,:), warnings_batch, conds(I), info_batch] = ...
        eval_range(SO3F, ori.subSet(I), options{:});
      info = insertRegInfo(info, I, info_batch);
    elseif wantConds
      [vals(I,:), warnings_batch, conds(I)] = ...
        eval_range(SO3F, ori.subSet(I), options{:});
    else
      [vals(I,:), warnings_batch] = ...
        eval_range(SO3F, ori.subSet(I), options{:});
    end
  end

  warnings = mergeWarnings(warnings, warnings_batch);
end

if isscalar(SO3F)
  vals = reshape(vals, dimensions);
else
  vals = reshape(vals, [N, size(SO3F)]);
end
if wantConds, conds = reshape(conds, dimensions); end
if wantInfo, info = reshapeRegInfo(info, dimensions); end
if emitWarnings, issueWarnings(warnings, SO3F); end

end


% Smooth the local support volume d_n^3 and take the cube root afterwards.
function delta = getSmoothDelta(SO3F, ori)
  if isempty(SO3F.auxgrid)
    SO3F = SO3F.init_auxgrid;
  end

  dnVol = SO3F.auxgrid.opt.dn.^3;
  mls = SO3FunMLS(SO3F.auxgrid, dnVol, ...
    'degree', 0, 'oF', 20, 'centered', false, ...
    'regularize', false, 'use_vor_weights', false, ...
    'use_smooth_delta', false, 'weight', 'wendland');
  mls.delta = mls.compute_delta;

  delta = max(real(mls.eval(ori)), 0).^(1/3);
end


function warnings = initWarnings
  warnings = struct;
  warnings.rangeTooFew = false;
  warnings.rangeTooMany = false;
  warnings.smoothTooFew = false;
  warnings.smoothAllCandidates = false;
end


function warnings = mergeWarnings(warnings, other)
  names = fieldnames(warnings);
  for k = 1 : numel(names)
    warnings.(names{k}) = warnings.(names{k}) | other.(names{k});
  end
end


function issueWarnings(warnings, SO3F)
  if warnings.rangeTooFew
    warning('MTEX:MLS:rangeTooFew', ...
      ['Some fixed-radius neighborhoods had at most the ansatz ' ...
      'dimension many nodes and were replaced by minimal KNN neighborhoods.']);
  end

  if warnings.rangeTooMany
    warning('MTEX:MLS:rangeTooMany', ...
      ['Some fixed-radius neighborhoods exceeded the maximal ' ...
      'oversampling factor and were replaced by capped KNN neighborhoods.']);
  end

  if warnings.smoothTooFew
    warning('MTEX:MLS:smoothTooFew', ...
      ['At some centers the smooth support contained fewer than %d ' ...
      'positive-weight neighbors and was enlarged locally.'], SO3F.dim);
  end

  if warnings.smoothAllCandidates
    warning('MTEX:MLS:smoothAllCandidates', ...
      ['At some centers all fetched KNN candidates carried a relevant ' ...
      'weight. The smooth compact support may be truncated; raise ' ...
      'candidateFactor above %g to fetch more candidates.'], ...
      SO3F.candidateFactor);
  end
end


function info = initRegInfo(N)
  info = struct;
  info.conds_reg = NaN(N, 1);
  info.conds_unreg = NaN(N, 1);
  info.maxeig = NaN(N, 1);
  info.mineig = NaN(N, 1);
  info.maxeig_reg = NaN(N, 1);
  info.mineig_reg = NaN(N, 1);
  info.centerAmplification = NaN(N, 1);
  info.centerAmplificationRegBound = NaN(N, 1);
  info.numericalRidge = NaN(N, 1);
  info.shapeRegularization = NaN(N, 1);
  info.regularizationActive = false(N, 1);
  info.deltaFallback = false(N, 1);
  info.candidateLimit = false(N, 1);
end


function info = insertRegInfo(info, I, info_batch)
  names = fieldnames(info_batch);
  for k = 1 : numel(names)
    name = names{k};
    if isfield(info, name)
      info.(name)(I,:) = info_batch.(name);
    end
  end
end


function info = sliceRegInfo(info, I)
  names = fieldnames(info);
  for k = 1 : numel(names)
    info.(names{k}) = info.(names{k})(I,:);
  end
end


function info = reshapeRegInfo(info, dimensions)
  names = fieldnames(info);
  N = prod(dimensions);
  for k = 1 : numel(names)
    name = names{k};
    if numel(info.(name)) == N
      info.(name) = reshape(info.(name), dimensions);
    end
  end
end
