function [vals, conds] = eval(SO3F, ori,varargin)
% evaluate SO3F in orientations via moving least squares (MLS) approximation
% provide the possibility of also returning the condition numbers of the gram matrices
%
% Syntax
%   vals = SO3F.eval(ori)
%   vals = eval(SO3F,ori)
%
% Input
%  SO3F  - @SO3FunMLS
%  ori   - @orientation (the points where we want to evaluate the MLS-approximation)
%
% Output
%  vals  - the values of SO3F on ori
%  conds - the condition numbers of the LSQR systems 
%


if isempty(ori)
  vals = [];
  conds = [];
  return;
end

% if outlier detection is enabled but SO3F is not scalar we have to be careful
% with matrix dimensions in eval_knn and eval_range
% easy workaround is to catch this case here and loop over the entries of SO3F
if ((~isscalar(SO3F)) && SO3F.detectOutliers)
  vals = zeros(numel(ori), numel(SO3F));
  % extract condition number via the first component, if necessary
  if (nargout == 1)
    vals(:,1) = SO3F.subSet(1).eval(ori, varargin{:});
  else
    [vals(:,1), conds] = SO3F.subSet(1).eval(ori, varargin{:});
  end

  for i = 2 : numel(SO3F)
    vals(:,i) = SO3F.subSet(i).eval(ori, varargin{:});
  end
  % reshape and return
  vals = reshape(vals, [numel(ori), size(SO3F)]);
  return;
end

dimensions = size(ori);
N = prod(dimensions);

% prevent dimension error in local least squares solver for N==1
if (N == 1)
  ori = [ori; ori];
  [vals, conds] = SO3F.eval(ori, varargin{:});
  vals = vals(1,:);
  vals = reshape(vals, size(SO3F));
  conds = conds(1);
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
    SO3F.SS = specimenSymmetry.default;
    ori.SS = specimenSymmetry.default;
  else
    % symmetrise SRight
    SO3F.nodes = SO3F.nodes*cs;
    SO3F.values = repmat(SO3F.values,numSym(cs), 1);
    SO3F.CS = specimenSymmetry.default;
    ori.CS = specimenSymmetry.default;
  end
end


vals = zeros(N, numel(SO3F));
if (nargout == 2)
  conds = zeros(N, 1);
end

% we perform the computation in batches of 1GB (2^30 Bytes) RAM 
nn = SO3F.nn;
if (nn == 0) 
  nn = SO3F.guess_nn("max"); 
end
oF = nn / SO3F.dim;
bytes_per_ori = SO3F.dim * (2*nn + 5*oF + SO3F.dim) * 8 * numel(SO3F);
batch_size = ceil(2 * 2^30 / bytes_per_ori);

current_batch = 0;
start_idx = 1;
end_idx = 0;

while (end_idx < N)

  current_batch = current_batch + 1;
  end_idx = min(end_idx + batch_size, N);
  I = (start_idx : end_idx)';
  start_idx = end_idx + 1;

  if (nargout == 1)
    if (SO3F.nn >= SO3F.dim)
      vals(I,:) = eval_knn(SO3F, ori.subSet(I));
    else
      vals(I,:) = eval_range(SO3F, ori.subSet(I));
    end

  else
    if (SO3F.nn >= SO3F.dim)
      [vals(I,:), conds(I,:)] = eval_knn(SO3F, ori.subSet(I));
    else
      [vals(I,:), conds(I,:)] = eval_range(SO3F, ori.subSet(I));
    end
  end

end

% at this point the vals have the shape (numel(ori) x numel(SO3F))
% if SO3F has only 1 component, we want to respect the shape of ori
% if SO3F has multiple components, we want to respect the shape of SO3F
if (isscalar(SO3F))
  vals = reshape(vals, dimensions);
else
  vals = reshape(vals, [N, size(SO3F)]);
end

if (nargout == 2)
  conds = reshape(conds, dimensions);
end

end
