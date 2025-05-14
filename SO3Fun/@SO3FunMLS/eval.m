function [vals, conds] = eval(SO3F, ori)

% evaluate sF on ori via moving least squares (MLS) approximation
% provide the possibility of also returning the condition numbers of the gram matrices
%
% Syntax
%   vals = SO3F.eval(ori)
%   vals = eval(SO3F,ori)
%
% Input
%  SO3F  - the function we want to approximate
%  ori   - the points where we want to evaluate the MLS approximation
%
% Output
%  vals  - the values of SO3F on ori
%

% I = ori.a < 0;
% ori(I) = ori(I) * orientation([-1,0,0,0]);

if ~isa(ori,'orientation')
  ori = orientation(ori, SO3F.CS, SO3F.SS);
end

dimensions = size(ori);
N = prod(dimensions);
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
bytes_per_ori = SO3F.dim * (2*nn + 5*oF + SO3F.dim) * 8;
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

vals = reshape(vals, [dimensions numel(SO3F)]);
if (nargout == 2)
  conds = reshape(conds, [dimensions numel(SO3F)]);
end

end