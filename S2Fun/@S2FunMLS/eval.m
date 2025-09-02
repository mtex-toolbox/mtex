function [vals, conds] = eval(sF, v, varargin)

% evaluate sF on v via moving least squares (MLS) approximation
% provide the possibility of also returning the condition numbers of the gram matrices
%
% Syntax
%   vals = sF.eval(v)
%   vals = eval(sF,v)
%
% Input
%  sF    - the function we want to approximate
%  v     - the points where we want to evaluate the MLS approximation
%
% Output
%  vals  - the values of sF on v
%


if ~isa(v, 'vector3d')
  v = vector3d(v, sF.CS);
end


dimensions = size(v);
N = numel(v);
vals = zeros(N, numel(sF));
if (nargout == 2)
  conds = zeros(N, 1);
end


% we perform the computation in batches of 1GB (2^30 Bytes) RAM
nn = sF.nn;
if (nn == 0)
  nn = sF.guess_nn("max");
end
oF = nn / sF.dim;
% byter_per_v is bytes_per_ori from SO3FunMLS, multiplied by 3/4 in order to
% approximately correct for the number of variables
bytes_per_v = sF.dim * (2*nn + 5*oF + sF.dim) * 8 * 3/4;
batch_size = ceil(2 * 2^30 / bytes_per_v);

current_batch = 0;
start_idx = 1;
end_idx = 0;

while (end_idx < N)

  current_batch = current_batch + 1;
  end_idx = min(end_idx + batch_size, N);
  I = (start_idx : end_idx)';
  start_idx = end_idx + 1;

  if (nargout == 1)
    if (sF.nn >= sF.dim)
      vals(I,:) = eval_knn(sF, v.subSet(I), varargin{:});
    else
      vals(I,:) = eval_range(sF, v.subSet(I), varargin{:});
    end

  else
    if (sF.nn >= sF.dim)
      [vals(I,:), conds(I,:)] = eval_knn(sF, v.subSet(I), varargin{:});
    else
      [vals(I,:), conds(I,:)] = eval_range(sF, v.subSet(I), varargin{:});
    end
  end

end

vals = reshape(vals, [dimensions, numel(sF)]);
if (nargout == 2)
  conds = reshape(conds, [dimensions numel(sF)]);
end 

end
