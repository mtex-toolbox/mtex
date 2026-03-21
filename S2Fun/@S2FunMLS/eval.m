function [vals, conds] = eval(S2F, v, varargin)
% evaluate S2F on v via moving least squares (MLS) approximation
% can also return the condition numbers of the (weighted) design matrices 
%
% Syntax
%   vals = S2F.eval(v)
%   vals = eval(S2F,v)
%
% Input
%  S2F - @S2FunMLS
%  v  - @vector3d the evaluation directions
%
% Output
%  vals  - the values of the mls approximation S2F on v
%


if isempty(v)
  vals = [];
  conds = [];
  return;
end

dimensions = size(v);
N = numel(v);

% prevent dimension error in local least squares solver for N==1
if (N == 1)
  v = [v;v];
  [vals, conds] = S2F.eval(v, varargin{:});
  vals = vals(1,:);
  vals = reshape(vals, size(S2F));
  conds = conds(1);
  return;
end

% if outlier detection is enabled but S2F is not scalar we have to be careful
%   with matrix dimensions in eval_knn and eval_range
%   easy workaround is to catch this case here and loop over the entries of S2F
if ((~isscalar(S2F)) && S2F.detectOutliers)
  v = v(:);
  vals = zeros(numel(v), numel(S2F));
  % extract condition number via the first component, if necessary
  if (nargout == 1)
    vals(:,1) = S2F.subSet(1).eval(v, varargin{:});
  else
    [vals(:,1), conds] = S2F.subSet(1).eval(v, varargin{:});
  end

  for i = 2 : numel(S2F)
    vals(:,i) = S2F.subSet(i).eval(v, varargin{:});
  end
  
  % reshape and return
  vals = reshape(vals, [numel(v), size(S2F)]);
  return;
end

vals = zeros(N, numel(S2F));
if (nargout == 2)
  conds = zeros(N, 1);
end

% we perform the computation in batches of 1GB (2^30 Bytes) RAM
if (S2F.delta == 0)
  nn = S2F.nn;
else
  nn = S2F.guess_nn("max");
end
% byter_per_v is bytes_per_ori from SO3FunMLS, multiplied by 3/4 in order to
% approximately correct for the different number of variables
bytes_per_v = S2F.dim * (2*nn + 5*S2F.oF + S2F.dim) * 8 * 3/4 * numel(S2F);
batch_size = ceil(2 * 2^30 / bytes_per_v);

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
  
  if (S2F.delta == 0)
    [vals(I,:), conds(I)] = eval_knn(S2F, v.subSet(I), varargin{:});
  else
    [vals(I,:), conds(I), warn_tfn, warn_tmn] = eval_range(S2F, v.subSet(I), varargin{:});
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

if (nargout == 2)
  conds = reshape(conds, dimensions);
end 

end
