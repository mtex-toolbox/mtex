function [vals, conds, info] = eval(SO3F, ori, varargin)

% evaluate SO3F in orientations via moving least squares (MLS) approximation
% also returns the condition of the (regularized) local least squares problems
%
% Syntax
%   vals = SO3F.eval(ori)
%   vals = eval(SO3F,ori)
%
% Input
%  SO3F  - @SO3FunMLS
%  ori   - @orientation the evaluation orientations
%
% Output
%  vals  - values of the MLS approximation SO3F on ori
%  conds - condition of the complete normalized local Gram matrices after
%            regularization
%  info  - struct with additional regularization data


if isempty(ori)
  vals = [];
  conds = [];
  info = initRegInfo(0);
  return;
end

if ~isa(ori,'orientation')
  ori = orientation(ori,SO3F.CS,SO3F.SS);
end

% Use proper groups
SO3F.CS = SO3F.CS.properGroup;
SO3F.SS = SO3F.SS.properGroup;
ori.CS = ori.CS.properGroup;
ori.SS = ori.SS.properGroup;

% Symmetrise w.r.t. lower symmetry, since only one symmetry can be used in find-method
cs = ori.CS; ss = ori.SS;
if cs.id~=1 && ss.id~=1
  if length(cs.rot) >= length(ss.rot)
    % symmetrise SLeft
    SO3F.nodes = ss*SO3F.nodes;
    SO3F.values = kron(SO3F.values, ones(numSym(ss),1));
    SO3F.vor_weights = kron(SO3F.vor_weights, ones(numSym(ss),1));
    if ~isempty(SO3F.outlierIndicators)
      SO3F.outlierIndicators = kron(SO3F.outlierIndicators, ones(numSym(ss),1));
    end
    SO3F.SS = specimenSymmetry.default;
    ori.SS = specimenSymmetry.default;
  else
    % symmetrise SRight
    SO3F.nodes = SO3F.nodes*cs;
    SO3F.values = repmat(SO3F.values,numSym(cs), 1);
    SO3F.vor_weights = repmat(SO3F.vor_weights,numSym(cs), 1);
    if ~isempty(SO3F.outlierIndicators)
      SO3F.outlierIndicators = repmat(SO3F.outlierIndicators,numSym(cs), 1);
    end
    SO3F.CS = specimenSymmetry.default;
    ori.CS = specimenSymmetry.default;
  end
  SO3F.searcher = createns(SO3F.nodes.abcd);
  if SO3F.use_smooth_delta
    SO3F = SO3F.init_auxgrid;
  end
end

if SO3F.detectOutliers && isempty(SO3F.outlierIndicators)
  SO3F.outlierIndicators = SO3F.compute_outlier_indicators;
end

dimensions = size(ori);
N = numel(ori);
want_info = nargout > 2;

% constant degree does not need batches and will not regularize
if (SO3F.degree == 0)
  % provide smooth delta values, if the option flag is true
  if SO3F.use_smooth_delta
    smoothDelta = getSmoothDelta(SO3F, ori);
    varargin = set_option(varargin, 'smoothDelta', smoothDelta);
  end
  vals = SO3F.eval_const(ori, varargin{:});
  if isscalar(SO3F)
    vals = reshape(vals, dimensions);
  else
    vals = reshape(vals, [N, size(SO3F)]);
  end
  conds = [];
  info = initRegInfo(0);
  return;
elseif (SO3F.degree == 1)
  if (~SO3F.tangent && SO3F.regularize)
    warning(['Regularization prevents reproduction of constants, if the ' ...
      'degree is 1 and tangent is set to false. It is probably best to set ' ...
      'the tangent option to true and re-initialize the regularization ' ...
      'parameters via SO3F = SO3F.init_reg_params("force")']);
  end
end

% prevent dimension error in local least squares solver for N==1
if (N == 1)
  ori = [ori;ori];
  if want_info
    [vals, conds, info] = SO3F.eval(ori, varargin{:});
    info = sliceRegInfo(info, 1);
  elseif nargout >= 2
    [vals, conds] = SO3F.eval(ori, varargin{:});
  else
    vals = SO3F.eval(ori, varargin{:});
  end
  vals = vals(1,:);
  vals = reshape(vals, size(SO3F));
  if nargout >= 2
    conds = conds(1);
  end
  return;
end

% if outlier detection is enabled but SO3F is not scalar we have to be careful
%   with matrix dimensions in eval_knn and eval_range
%   easy workaround is to catch this case here and loop over the entries of SO3F
if ((~isscalar(SO3F)) && SO3F.detectOutliers)
  ori = ori(:);
  vals = zeros(numel(ori), numel(SO3F));

  % extract condition number via the first component, if necessary
  SO3F1 = SO3F.subSet(1);
  if ~isempty(SO3F.outlierIndicators)
    SO3F1.outlierIndicators = SO3F.outlierIndicators(:,1);
  end
  if want_info
    [vals(:,1), conds, info] = SO3F1.eval(ori, varargin{:});
  elseif nargout >= 2
    [vals(:,1), conds] = SO3F1.eval(ori, varargin{:});
  else
    vals(:,1) = SO3F1.eval(ori, varargin{:});
  end

  for i = 2 : numel(SO3F)
    SO3Fi = SO3F.subSet(i);
    if ~isempty(SO3F.outlierIndicators) && size(SO3F.outlierIndicators,2) >= i
      SO3Fi.outlierIndicators = SO3F.outlierIndicators(:,i);
    end
    vals(:,i) = SO3Fi.eval(ori, varargin{:});
  end

  % reshape and return
  vals = reshape(vals, [numel(ori), size(SO3F)]);
  if (nargout >= 2)
    conds = reshape(conds, dimensions);
  end
  if want_info
    info = reshapeRegInfo(info, dimensions);
  end
  return;
end

vals = zeros(N, numel(SO3F));
if (nargout >= 2)
  conds = zeros(N, 1);
end
if want_info
  info = initRegInfo(N);
end

smoothDelta = [];
if (SO3F.delta == 0)
  nn = SO3F.nn;
  % precompute values for smooth version of delta once for all batches
  % otherwise we repeatedly perform stuff like creating the corresponding mls and so on
  if SO3F.use_smooth_delta
    smoothDelta = getSmoothDelta(SO3F, ori);
  end
else
  nn = SO3F.guess_nn("max");
end

% We perform the computation in batches of 1GB (2^30 Bytes) RAM.
% This is not super precise, but close to what eval_knn demands per ori.
bytes_per_ori = SO3F.dim * (nn*2 + 9*SO3F.oF + SO3F.dim) * 8 * numel(SO3F);
batch_size = ceil(1 * 2^30 / bytes_per_ori); % go for approx 1 GB RAM

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
  if (SO3F.delta == 0)
    if SO3F.use_smooth_delta
      varargin_batch = [varargin_batch(:)', {'smoothDelta'}, {smoothDelta(I)}];
    end

    if want_info
      [vals(I,:), conds(I), info_batch] = eval_knn(SO3F, ori.subSet(I), varargin_batch{:});
      info = insertRegInfo(info, I, info_batch);
    elseif nargout >= 2
      [vals(I,:), conds(I)] = eval_knn(SO3F, ori.subSet(I), varargin_batch{:});
    else
      vals(I,:) = eval_knn(SO3F, ori.subSet(I), varargin_batch{:});
    end
  else
    if want_info
      [vals(I,:), conds(I), warn_tfn, warn_tmn, info_batch] ...
        = eval_range(SO3F, ori.subSet(I), varargin_batch{:});
      info = insertRegInfo(info, I, info_batch);
    elseif nargout >= 2
      [vals(I,:), conds(I), warn_tfn, warn_tmn] ...
        = eval_range(SO3F, ori.subSet(I), varargin_batch{:});
    else
      [vals(I,:), ~, warn_tfn, warn_tmn] ...
        = eval_range(SO3F, ori.subSet(I), varargin_batch{:});
    end

    warning_too_few_neighbors = warning_too_few_neighbors | warn_tfn;
    warning_too_many_neighbors = warning_too_many_neighbors | warn_tmn;
  end
end

% print warnings, if any occured
if (warning_too_few_neighbors)
  warning(['Some centers did not have sufficiently many neighbors. ' ...
    'In this case the numer of neighbors was set to the dimension of the ansatz space (%d).'], SO3F.dim);
end
if (warning_too_many_neighbors)
  warning(['Some centers did have too many neighbors. ' ...
    'In this case only the %d nearest neighbors have been used.'], ...
    SO3F.dim * SO3F.oF_max);
end

% at this point the vals have the shape (numel(ori) x numel(SO3F))
% if SO3F has multiple components, we want to respect the shape of SO3F
if isscalar(SO3F)
  vals = reshape(vals, dimensions);
else
  vals = reshape(vals, [N, size(SO3F)]);
end

if (nargout >= 2)
  conds = reshape(conds, dimensions);
end
if want_info
  info = reshapeRegInfo(info, dimensions);
end

end


% compute smoothed version of delta via MLS on the auxiliary grid
%   the local support volume d_n(x)^3 is used as data and transformed back to
%   a radius after evaluation
function [delta, nn] = getSmoothDelta(SO3F, ori)
  if isempty(SO3F.auxgrid)
    SO3F = SO3F.init_auxgrid;
  end
  dn = SO3F.auxgrid.opt.dn;
  % smooth the local support volume instead of the neighbor distance itself
  %   on SO(3), this volume scales locally like d_n^3 and is approximately
  %   proportional to the inverse node density; after the MLS approximation,
  %   taking the cube root recovers the corresponding smooth support radius
  dnVol = dn.^3;
  mls = SO3FunMLS(SO3F.auxgrid, dnVol, 'degree', 0, 'oF', 5, 'centered', false, ...
    'regularize', false, 'use_vor_weights', false, 'use_smooth_delta', false);
  mls.delta = mls.compute_delta;
  deltaVol = mls.eval(ori);
  delta = max(real(deltaVol), 0) .^ (1/3);

  if (nargout > 1)
    [~, dist] = SO3F.nodes.find(ori, 2*SO3F.nn, 'searcher', SO3F.searcher);
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
