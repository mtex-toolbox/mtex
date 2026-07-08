function [vals, conds, info] = eval(S2F, v, varargin)
% evaluate S2F on v via moving least squares (MLS) approximation
% also returns the condition of the (regularized) local least squares problems
%
% Syntax
%   vals = S2F.eval(v)
%   vals = eval(S2F,v)
%
% Input
%   S2F - @S2FunMLS
%   v   - @vector3d the evaluation directions
%
% Output
%   vals  - values of the MLS approximation S2F on v
%   conds - condition of the solved local least squares problems
%   info  - struct with additional regularization data


if isempty(v)
  vals = [];
  conds = [];
  info = initRegInfo(0);
  return;
end

dimensions = size(v);
N = numel(v);
want_info = nargout > 2;

% constant degree does not need batches and will not regularize
if (S2F.degree == 0)
  % provide smooth delta values, if the option flag is true
  if S2F.use_smooth_delta
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
elseif (S2F.degree == 1)
  if (~S2F.tangent && S2F.regularize)
    warning(['Regularization prevents reproduction of constants, if the ' ...
      'degree is 1 and tangent is set to false. It is probably best to set ' ...
      'the tangent option to true and re-initialize the regularization ' ...
      'parameters via S2F = S2F.init_reg_params("force")']); 
  end
end

% prevent dimension error in local least squares solver for N==1
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
  vals = vals(1,:);
  vals = reshape(vals, size(S2F));
  if nargout >= 2
    conds = conds(1);
  end
  return;
end

% if outlier detection is enabled but S2F is not scalar we have to be careful
%   with matrix dimensions in eval_knn and eval_range
%   easy workaround is to catch this case here and loop over the entries of S2F
if ((~isscalar(S2F)) && S2F.detectOutliers)
  v = v(:);
  vals = zeros(numel(v), numel(S2F));

  % extract condition number via the first component, if necessary
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
  
  % reshape and return
  vals = reshape(vals, [numel(v), size(S2F)]);
  if (nargout >= 2)
    conds = reshape(conds, dimensions);
  end
  if want_info
    info = reshapeRegInfo(info, dimensions);
  end
  return;
end

vals = zeros(N, numel(S2F));
if (nargout >= 2)
  conds = zeros(N, 1);
end
if want_info
  info = initRegInfo(N);
end

smoothDelta = [];
if (S2F.delta == 0)
  nn = S2F.nn;
  % precompute values for smooth version of delta once for all batches
  % otherwise we repeatedly perform stuff like creating the corresponding mls and so on
  if S2F.use_smooth_delta
    smoothDelta = getSmoothDelta(S2F, v);
  end
else
  nn = S2F.guess_nn("max");
end

% We perform the computation in batches of 1GB (2^30 Bytes) RAM. 
% This is not super precise, but close to what eval_knn demands per v. 
bytes_per_v = S2F.dim * (nn*2 + 9*S2F.oF + S2F.dim) * 8 * numel(S2F);
batch_size = ceil(1 * 2^30 / bytes_per_v); % go for approx 1 GB RAM

current_batch = 0;
start_idx = 1;
end_idx = 0;

% initialize warning-switches (avoid printing the same warning for every batch)
warning_too_few_neighbors = false;
warning_too_many_neighbors = false;

while (end_idx < N)
  current_batch = current_batch + 1;
  end_idx = min(end_idx + batch_size, N);
  I = (start_idx : end_idx)';
  start_idx = end_idx + 1;

  varargin_batch = varargin;
  if (S2F.delta == 0)
    if S2F.use_smooth_delta
      varargin_batch = [varargin_batch(:)', {'smoothDelta'}, {smoothDelta(I)}];
    end

    if want_info
      [vals(I,:), conds(I), info_batch] = eval_knn(S2F, v.subSet(I), varargin_batch{:});
      info = insertRegInfo(info, I, info_batch);
    elseif nargout >= 2
      [vals(I,:), conds(I)] = eval_knn(S2F, v.subSet(I), varargin_batch{:});
    else
      vals(I,:) = eval_knn(S2F, v.subSet(I), varargin_batch{:});
    end
  else
    if want_info
      [vals(I,:), conds(I), warn_tfn, warn_tmn, info_batch] ...
        = eval_range(S2F, v.subSet(I), varargin_batch{:});
      info = insertRegInfo(info, I, info_batch);
    elseif nargout >= 2
      [vals(I,:), conds(I), warn_tfn, warn_tmn] ...
        = eval_range(S2F, v.subSet(I), varargin_batch{:});
    else
      [vals(I,:), ~, warn_tfn, warn_tmn] ...
        = eval_range(S2F, v.subSet(I), varargin_batch{:});
    end

    warning_too_few_neighbors = warning_too_few_neighbors | warn_tfn;
    warning_too_many_neighbors = warning_too_many_neighbors | warn_tmn;
  end
end

% print warnings, if any occured
if (warning_too_few_neighbors)
  warning(['Some centers did not have sufficiently many neighbors. ' ...
    'In this case the numer of neighbors was set to the dimension of the ansatz space (%d).'], S2F.dim);
end
if (warning_too_many_neighbors)
  warning(['Some centers did have too many neighbors. ' ...
    'In this case only the %d nearest neighbors have been used.'], ...
    S2F.dim * S2F.oF_max);
end

% at this point the vals have the shape (numel(ori) x numel(S2F))
% if S2F has multiple components, we want to respect the shape of S2F
if isscalar(S2F)
  vals = reshape(vals, dimensions);
else
  vals = reshape(vals, [N, size(S2F)]);
end

if (nargout >= 2)
  conds = reshape(conds, dimensions);
end 
if want_info
  info = reshapeRegInfo(info, dimensions);
end

end


% compute smoothed version of delta via MLS on fiboannciGrid with d_n(x)
%   (distance of n-th nearest neighbor to x) as data 
% n2 oversamples by factor 1.5. this tries to avoid ending up with centers where
%   delta(x) is too small to provide sufficiently many neighbors
function [delta, nn] = getSmoothDelta(S2F, v)
  dn = S2F.auxgrid.opt.dn;
  mls = S2FunMLS(S2F.auxgrid, dn, 'degree', 0, 'oF', 5, 'centered', false, ...
    'regularize', false, 'use_vor_weights', false, 'use_smooth_delta', false);
  mls.delta = mls.compute_delta;
  delta = mls.eval(v);

  if (nargout > 1)
    [~, dist] = S2F.nodes.find(v, 2*S2F.nn);
    isin = dist < delta;
    nn = sum(isin, 2);
  end
end

% initialize struct for additional regularization information
function info = initRegInfo(N)
  info = struct;
  info.conds_reg = NaN(N, 1);
  info.conds_unreg = NaN(N, 1);
  info.geometryScore = NaN(N, 1);
  info.maxeig = NaN(N, 1);
  info.mineig = NaN(N, 1);
  info.meanEig = NaN(N, 1);
  info.conds_geom = NaN(N, 1);
  info.lambdaGeom = NaN(N, 1);
  info.lambdaCond = NaN(N, 1);
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

% return only the selected entries of the info struct
function info = sliceRegInfo(info, I)
  names = fieldnames(info);
  for k = 1 : numel(names)
    name = names{k};
    info.(name) = info.(name)(I,:);
  end
end

% reshape all fields of the info struct according to the evaluation grid
function info = reshapeRegInfo(info, dimensions)
  names = fieldnames(info);
  for k = 1 : numel(names)
    name = names{k};
    if isvector(info.(name))
      info.(name) = reshape(info.(name), dimensions);
    end
  end
end
