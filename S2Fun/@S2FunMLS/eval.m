function [vals, conds, info] = eval(S2F, v, varargin)
% evaluate S2F on v via moving least squares (MLS) approximation
% also return conditions and additional regularization diagnostics
%
% Syntax
%   vals = S2F.eval(v)
%   vals = eval(S2F,v)
%
% Input
%   S2F - @S2FunMLS
%   v   - @vector3d evaluation directions
%
% Output
%   vals  - values of the MLS approximation
%   conds - conditions of the solved normalized Gram systems
%   info  - additional regularization diagnostics


if isempty(v)
  vals = [];
  conds = [];
  info = initRegInfo(0);
  return;
end

dimensions = size(v);
N = numel(v);
want_info = nargout > 2;

% degree zero is a weighted average and does not need local linear solves
if (S2F.degree == 0)
  if S2F.use_smooth_delta && (S2F.delta == 0)
    smoothDelta = getSmoothDelta(S2F, v);
    varargin = set_option(varargin, 'smoothDelta', smoothDelta);
  end
  vals = S2F.eval_const(v, varargin{:});
  if isscalar(S2F)
    vals = reshape(vals, dimensions);
  else
    vals = reshape(vals, [N, size(S2F)]);
  end
  conds = [];
  info = initRegInfo(0);
  return;
end

% avoid page-dimension problems in the local solver for a single center
if (N == 1)
  v = [v;v];
  if want_info
    [vals, conds, info] = S2F.eval(v, varargin{:});
    info = sliceRegInfo(info, 1);
  elseif nargout >= 2
    [vals, conds] = S2F.eval(v, varargin{:});
  else
    vals = S2F.eval(v, varargin{:});
  end
  vals = reshape(vals(1,:), size(S2F));
  if nargout >= 2
    conds = conds(1);
  end
  return;
end

% Outlier indicators depend on the values, so vector-valued functions are
% evaluated componentwise when outlier detection is enabled.
if (~isscalar(S2F)) && S2F.detectOutliers
  v = v(:);
  vals = zeros(numel(v), numel(S2F));

  if want_info
    [vals(:,1), conds, info] = S2F.subSet(1).eval(v, varargin{:});
  elseif nargout >= 2
    [vals(:,1), conds] = S2F.subSet(1).eval(v, varargin{:});
  else
    vals(:,1) = S2F.subSet(1).eval(v, varargin{:});
  end

  for i = 2 : numel(S2F)
    vals(:,i) = S2F.subSet(i).eval(v, varargin{:});
  end

  vals = reshape(vals, [numel(v), size(S2F)]);
  if nargout >= 2
    conds = reshape(conds, dimensions);
  end
  if want_info
    info = reshapeRegInfo(info, dimensions);
  end
  return;
end

vals = zeros(N, numel(S2F));
if nargout >= 2
  conds = zeros(N, 1);
end
if want_info
  info = initRegInfo(N);
end

smoothDelta = [];
if (S2F.delta == 0)
  nn = S2F.nn;
  if S2F.use_smooth_delta
    % compute the smooth support field once and reuse it in all batches
    smoothDelta = getSmoothDelta(S2F, v);
  end
else
  % range evaluation is capped at this neighborhood size in eval_range
  nn = S2F.dim * S2F.oF_max;
end

% keep the large pagewise matrices close to one GiB per batch
numf = numel(S2F);
bytes_per_v = (3*nn*S2F.dim + 6*S2F.dim^2 + ...
  2*nn*numf + 2*S2F.dim*numf) * 8;
batch_size = max(2, floor(2^30 / max(bytes_per_v, 1)));

start_idx = 1;
end_idx = 0;

% collect range-search warnings and print each of them only once
warning_too_few_neighbors = false;
warning_too_many_neighbors = false;

while (end_idx < N)
  end_idx = min(end_idx + batch_size, N);
  I = (start_idx : end_idx)';
  start_idx = end_idx + 1;

  varargin_batch = varargin;
  if (S2F.delta == 0)
    if S2F.use_smooth_delta
      varargin_batch = [varargin_batch(:)', ...
        {'smoothDelta'}, {smoothDelta(I)}];
    end

    if want_info
      [vals(I,:), conds(I), info_batch] = ...
        eval_knn(S2F, v.subSet(I), varargin_batch{:});
      info = insertRegInfo(info, I, info_batch);
    elseif nargout >= 2
      [vals(I,:), conds(I)] = ...
        eval_knn(S2F, v.subSet(I), varargin_batch{:});
    else
      vals(I,:) = eval_knn(S2F, v.subSet(I), varargin_batch{:});
    end
  else
    if want_info
      [vals(I,:), conds(I), warn_tfn, warn_tmn, info_batch] = ...
        eval_range(S2F, v.subSet(I), varargin_batch{:});
      info = insertRegInfo(info, I, info_batch);
    elseif nargout >= 2
      [vals(I,:), conds(I), warn_tfn, warn_tmn] = ...
        eval_range(S2F, v.subSet(I), varargin_batch{:});
    else
      [vals(I,:), ~, warn_tfn, warn_tmn] = ...
        eval_range(S2F, v.subSet(I), varargin_batch{:});
    end

    warning_too_few_neighbors = warning_too_few_neighbors | warn_tfn;
    warning_too_many_neighbors = warning_too_many_neighbors | warn_tmn;
  end
end

if warning_too_few_neighbors
  warning(['Some centers did not have sufficiently many neighbors. ' ...
    'The number of neighbors was set to the ansatz dimension (%d).'], S2F.dim);
end
if warning_too_many_neighbors
  warning(['Some centers had too many neighbors. Only the %d nearest ' ...
    'neighbors were used.'], S2F.dim * S2F.oF_max);
end

if isscalar(S2F)
  vals = reshape(vals, dimensions);
else
  vals = reshape(vals, [N, size(S2F)]);
end

if nargout >= 2
  conds = reshape(conds, dimensions);
end
if want_info
  info = reshapeRegInfo(info, dimensions);
end

end


% smooth d_n(x)^2 on an equispaced grid and take the square root afterwards
function delta = getSmoothDelta(S2F, v)
  dn2 = S2F.auxgrid.opt.dn.^2;

  % The auxiliary MLS approximates local support area rather than d_n itself.
  % On S^2 this quantity is proportional to d_n^2 for small neighborhoods and
  % therefore follows the inverse local node density much more naturally.
  mls = S2FunMLS(S2F.auxgrid, dn2, 'degree', 0, 'oF', 5, ...
    'centered', false, 'regularize', false, 'use_vor_weights', false, ...
    'use_smooth_delta', false);
  mls.delta = mls.compute_delta;

  delta2 = max(real(mls.eval(v)), 0);
  delta = sqrt(delta2);
end

% initialize struct for additional regularization information
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
end

% insert regularization info of one batch into the full info struct
function info = insertRegInfo(info, I, info_batch)
  names = fieldnames(info_batch);
  for k = 1 : numel(names)
    name = names{k};
    if isfield(info, name)
      info.(name)(I,:) = info_batch.(name);
    end
  end
end

% return only selected entries of the info struct
function info = sliceRegInfo(info, I)
  names = fieldnames(info);
  for k = 1 : numel(names)
    name = names{k};
    info.(name) = info.(name)(I,:);
  end
end

% reshape all pagewise fields according to the evaluation grid
function info = reshapeRegInfo(info, dimensions)
  names = fieldnames(info);
  for k = 1 : numel(names)
    name = names{k};
    if isvector(info.(name))
      info.(name) = reshape(info.(name), dimensions);
    end
  end
end
