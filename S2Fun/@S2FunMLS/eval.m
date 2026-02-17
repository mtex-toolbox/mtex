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


% if outlier detection is enabled but S2F is not scalar we have to be careful
% with matrix dimensions in eval_knn and eval_range
% easy workaround is to catch this case here and loop over the entries of S2F
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

vals = zeros(N, numel(S2F));
if (nargout == 2)
  conds = zeros(N, 1);
end

% we perform the computation in batches of 1GB (2^30 Bytes) RAM
nn = S2F.nn;
if (nn == 0)
  nn = S2F.guess_nn("max");
end
oF = nn / S2F.dim;
% byter_per_v is bytes_per_ori from SO3FunMLS, multiplied by 3/4 in order to
% approximately correct for the different number of variables
bytes_per_v = S2F.dim * (2*nn + 5*oF + S2F.dim) * 8 * 3/4 * numel(S2F);
batch_size = ceil(2 * 2^30 / bytes_per_v);

current_batch = 0;
start_idx = 1;
end_idx = 0;

while (end_idx < N)

  current_batch = current_batch + 1;
  end_idx = min(end_idx + batch_size, N);
  I = (start_idx : end_idx)';
  start_idx = end_idx + 1;

  % just evaluate the mls approximation
  if (nargout == 1)
    if (S2F.delta == 0)
      vals(I,:) = eval_knn(S2F, v.subSet(I), varargin{:});
    else
      vals(I,:) = eval_range(S2F, v.subSet(I), varargin{:});
    end

  % also compute condition numbers of the design matrices
  else
    if (S2F.delta == 0)
      [vals(I,:), conds(I)] = eval_knn(S2F, v.subSet(I), varargin{:});
    else
      [vals(I,:), conds(I)] = eval_range(S2F, v.subSet(I), varargin{:});
    end
  end

end

% at this point the vals have the shape (numel(ori) x numel(S2F))
% if S2F has multiple components, we want to respect the shape of S2F
if ~isscalar(S2F)
  vals = reshape(vals, [N, size(S2F)]);
end

if (nargout == 2)
  conds = reshape(conds, dimensions);
end 

end
