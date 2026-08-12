function [vals, conds, info, warnings] = eval(S2F, v, varargin)
% evaluate S2F by moving least squares
%
% The optional fourth output contains accumulated neighborhood warnings. When
% it is requested, the warnings are returned but not printed. This is used by
% nested evaluations in eval_range.

warnings = initWarnings;
emitWarnings = nargout < 4;
wantConds = nargout > 1;
wantInfo = nargout > 2;

if isempty(v)
  vals = [];
  conds = [];
  info = initRegInfo(0);
  return;
end

dimensions = size(v);
N = numel(v);

% degree zero is a weighted average and needs no local linear solves
if (S2F.degree == 0)
  if S2F.use_smooth_delta && (S2F.delta == 0)
    varargin = set_option(varargin, 'smoothDelta', getSmoothDelta(S2F, v));
  end

  [vals, warnings_batch] = S2F.eval_const(v, varargin{:});
  warnings = mergeWarnings(warnings, warnings_batch);

  if isscalar(S2F)
    vals = reshape(vals, dimensions);
  else
    vals = reshape(vals, [N, size(S2F)]);
  end

  conds = [];
  info = initRegInfo(N);
  if wantInfo, info = reshapeRegInfo(info, dimensions); end
  if emitWarnings, issueWarnings(warnings, S2F); end
  return;
end

% avoid page-dimension problems in the local solver for a single center
if (N == 1)
  [vals, conds, info, warnings] = S2F.eval([v;v], varargin{:});
  vals = reshape(vals(1,:), size(S2F));
  if wantConds, conds = conds(1); end
  if wantInfo, info = sliceRegInfo(info, 1); end
  if emitWarnings, issueWarnings(warnings, S2F); end
  return;
end

% Outlier indicators depend on the values, so vector-valued functions are
% evaluated componentwise when outlier detection is active.
if (~isscalar(S2F)) && S2F.detectOutliers
  v = v(:);
  vals = zeros(numel(v), numel(S2F));

  [vals(:,1), conds, info, warnings] = ...
    S2F.subSet(1).eval(v, varargin{:});

  for k = 2 : numel(S2F)
    [vals(:,k), ~, ~, warnings_batch] = ...
      S2F.subSet(k).eval(v, varargin{:});
    warnings = mergeWarnings(warnings, warnings_batch);
  end

  vals = reshape(vals, [numel(v), size(S2F)]);
  if wantConds, conds = reshape(conds, dimensions); end
  if wantInfo, info = reshapeRegInfo(info, dimensions); end
  if emitWarnings, issueWarnings(warnings, S2F); end
  return;
end

vals = zeros(N, numel(S2F));
if wantConds, conds = zeros(N, 1); end
if wantInfo, info = initRegInfo(N); end

smoothDelta = [];
if (S2F.delta == 0)
  nn = candidate_count_S2(S2F);
  if S2F.use_smooth_delta
    % Compute the smooth support field once and reuse it in every batch.
    smoothDelta = getSmoothDelta(S2F, v);
  end
else
  nn = S2F.dim * S2F.oF_max;
end

% keep the large pagewise arrays close to one GiB per batch
numf = numel(S2F);
bytes_per_v = (3*nn*S2F.dim + 6*S2F.dim^2 + ...
  2*nn*numf + 2*S2F.dim*numf) * 8;
batch_size = max(2, floor(2^30 / max(bytes_per_v, 1)));

start_idx = 1;
while start_idx <= N
  end_idx = min(start_idx + batch_size - 1, N);
  I = (start_idx : end_idx)';
  start_idx = end_idx + 1;

  options = varargin;
  if (S2F.delta == 0)
    if S2F.use_smooth_delta
      options = [options(:)', {'smoothDelta'}, {smoothDelta(I)}];
    end

    if wantInfo
      [vals(I,:), warnings_batch, conds(I), info_batch] = ...
        eval_knn(S2F, v.subSet(I), options{:});
      info = insertRegInfo(info, I, info_batch);
    elseif wantConds
      [vals(I,:), warnings_batch, conds(I)] = ...
        eval_knn(S2F, v.subSet(I), options{:});
    else
      [vals(I,:), warnings_batch] = ...
        eval_knn(S2F, v.subSet(I), options{:});
    end
  else
    if wantInfo
      [vals(I,:), warnings_batch, conds(I), info_batch] = ...
        eval_range(S2F, v.subSet(I), options{:});
      info = insertRegInfo(info, I, info_batch);
    elseif wantConds
      [vals(I,:), warnings_batch, conds(I)] = ...
        eval_range(S2F, v.subSet(I), options{:});
    else
      [vals(I,:), warnings_batch] = ...
        eval_range(S2F, v.subSet(I), options{:});
    end
  end

  warnings = mergeWarnings(warnings, warnings_batch);
end

if isscalar(S2F)
  vals = reshape(vals, dimensions);
else
  vals = reshape(vals, [N, size(S2F)]);
end
if wantConds, conds = reshape(conds, dimensions); end
if wantInfo, info = reshapeRegInfo(info, dimensions); end
if emitWarnings, issueWarnings(warnings, S2F); end

end


% smooth d_n(x)^2 on an equispaced grid and take the square root afterwards
function delta = getSmoothDelta(S2F, v)
  dn2 = S2F.auxgrid.opt.dn.^2;

  % d_n^2 is proportional to inverse local node density for small spherical
  % neighborhoods and is therefore smoother to average than d_n itself.
  mls = S2FunMLS(S2F.auxgrid, dn2, 'degree', 0, 'oF', 20, ...
    'centered', false, 'regularize', false, 'use_vor_weights', false, ...
    'use_smooth_delta', false, 'weight', 'wendland');
  mls.delta = mls.compute_delta;

  delta = sqrt(max(real(mls.eval(v)), 0));
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


function issueWarnings(warnings, S2F)
  if warnings.rangeTooFew
    warning('MTEX:MLS:rangeTooFew', ...
      ['Some fixed-radius neighborhoods had at most the ansatz dimension ' ...
      'many nodes and were replaced by minimal KNN neighborhoods.']);
  end

  if warnings.rangeTooMany
    warning('MTEX:MLS:rangeTooMany', ...
      ['Some fixed-radius neighborhoods exceeded the maximal ' ...
      'oversampling factor and were replaced by capped KNN neighborhoods.']);
  end

  if warnings.smoothTooFew
    warning('MTEX:MLS:smoothTooFew', ...
      ['At some centers the smooth support contained fewer than %d ' ...
      'positive-weight neighbors and was enlarged locally.'], S2F.dim);
  end

  if warnings.smoothAllCandidates
    warning('MTEX:MLS:smoothAllCandidates', ...
      ['At some centers all fetched KNN candidates carried a relevant ' ...
      'weight. The smooth compact support may be truncated; raise ' ...
      'candidateFactor above %g to fetch more candidates.'], ...
      S2F.candidateFactor);
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
  info.geometryScore = NaN(N, 1);
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
