function [vals, conds] = eval_range(S2F, v, varargin)

% get parameters
v = v(:);
N = size(v, 1);
vals = zeros(N, numel(S2F));
conds = zeros(N, 1);
 
% get the neighbors 
ind = S2F.nodes.find(v, S2F.delta); 
nn = sum(ind, 2);

% for points with too less neighbors, we instead choose the S2F.dim nearest ones
% NOTE: we choose more neighbors than only the S2F.dim nearest ones, since the
% expectation of the lebesgue constant is infinite in this setting
I = nn <= S2F.dim;
if (sum(I) > 0)
  warning(sprintf( ...
    ['Some centers did not have sufficiently many neighbors. \n' ...
    '\t In this case the numer of neighbors was set to the dimension of the ansatz space.']));
  
  % evaluate the critical nodes via knn-search instead of rangesearch
  nn_original = S2F.nn;
  % for S2F.nn = S2F.dim, the expectation of the lebesgue constant is infinite
  S2F.nn = S2F.dim + 1;
  if (nargout == 2)
    [vals(I,:), conds(I)] = S2F.eval(v.subSet(I));
  else
    vals(I,:) = S2F.eval(v.subSet(I));
  end
  S2F.nn = nn_original;

  if (sum(I) == N)
    return;
  end
end

% continue with the points that have sufficiently many neighbors
J = ~I;
v = v.subSet(J);
N = sum(J);
[ind, dist] = S2F.nodes.find(v, S2F.delta, varargin{:});

% if optimal subsampling is set to true, we can now fall back to the eval_knn case 
%   where all neighborhoods have the same size (the dim of the ansatz space) 
if (S2F.subsample == true)
  ind = S2F.find_optimal_subset(ind, v, varargin{:});
end

[grid_id, v_id] = find(ind');
nn = sum(ind, 2);

if (S2F.subsample == true)
  dist = angle(v.subSet(v_id), S2F.nodes.subSet(grid_id));
  dist = sparse(v_id, grid_id, dist, N, numel(S2F.nodes));
end


% the index vector col_id helps to construct the (S2F.dim x N) matrix G, which
% holds the values of the basis functions at all neighbors of all centers from v
% col_id skips entries, whenever a center has not nn_max many neighbors 
nn_total = sum(nn);
nn_max = max(nn);
start_id = cumsum(nn(1:N-1)) + 1;
temp = ones(nn_total, 1);
temp(start_id) = 1 - nn(1:N-1);
temp = cumsum(temp);
col_id = (v_id-1) * nn_max + temp;

% TODO: nn_max might be much larger than mean(nn) at very few occations
%   ==> compute in batches of similar nn for less ram usage

% compute for every center from v the matrix of all basis functions evaluated at
% all neighbors of this center 
G = zeros(S2F.dim, nn_max * N);
% evaluate the basis functions on the nodes
if (~S2F.centered)
  % choose faster way between computing all values and reusing them or
  % computing values on fibgrid(grid_id)
  if nn_total > numel(S2F.nodes.x)
    basis_on_grid = eval_basis_functions(S2F);
    G(:, col_id) = basis_on_grid(grid_id, :).';
  else
    G(:, col_id) = eval_basis_functions(S2F, S2F.nodes(grid_id)).';
  end

  % odd basis functions may clash with antipodal option, since (-v) = -p(v)
  % thus make sure to use the representer which is closer to the center
  if (mod(S2F.degree, 2) > 0)
    I = sum(v.subSet(v_id).xyz .* S2F.nodes.subSet(grid_id).xyz, 2) < 0;
    G(:,I) = G(:,I) * (-1);
  end

  basis_in_v = eval_basis_functions(S2F, v);
else
  % compute the rotations that shift each element of v into the north pole
  rot = rotation.map(v, vector3d.Z);
  rot = rot(v_id);
  rotneighbors = rot .* S2F.nodes(grid_id);

  % determine which basis to use and evaluate it on the grid and on v
  basis_on_grid = eval_basis_functions(S2F, rotneighbors);
  basis_in_pole = eval_basis_functions(S2F, vector3d.Z);
  
  basis_in_v = repmat(basis_in_pole, N, 1);
  G(:, col_id) = basis_on_grid.';
end

% dont solve the normal equations G'WGc = G'Wf (like cond(G)^2)
% rather let matlab directly find min norm solution of sqrt(W) * (Gc-f)
% internally this uses QR and we end up with only cond(G)

% compute the weights
weights = zeros(N * nn_max, 1);
% dist(find(ind)) instead of nonzeros(dist), since elements of v might be
%   contained in S2F.nodes ==> distance 0, but in neighborhood
I = sub2ind(size(dist), v_id, grid_id);
weights(col_id) = S2F.w(dist(I) / S2F.delta);

if (S2F.detectOutliers == true)
  oI = computeOutlierIndicators(S2F);
  oI_factor = zeros(N * nn_max, 1);
  oI_factor(col_id) = exp(-oI(grid_id));
  weights = weights .* oI_factor;
end

% for each center, normalize the maximum weight to be 1
weights = reshape(weights, nn_max, N);
weights = weights ./ max(weights, [], 1);
weights = weights(:);

% B satisfies B' * B = G' * W * G
B = G .* sqrt(weights');
B_book = pagetranspose(reshape(B, S2F.dim, nn_max, N)); 

% compute scaling factors (norms of columns of G_times_W_book)
S_book = sqrt(sum(abs(B_book).^2, 1));

% set up right hand side
f = zeros(N * nn_max, numel(S2F));
f(col_id,:) = S2F.values(grid_id,:);
fw_book = permute(reshape((sqrt(weights) .* f).', numel(S2F), nn_max, N), [2 1 3]);

% compute the generating functions
c_book = pagemldivide(B_book ./ S_book, fw_book) ./ pagetranspose(S_book);
vals(J,:) = permute(sum(basis_in_v .* permute(c_book, [3 1 2]), 2), [1 3 2]);

if isalmostreal(S2F.values)
  vals = real(vals); 
end

if nargout == 2
  eigsJ = pagesvd(B_book ./ S_book);
  condsJ = eigsJ(1,:,:) ./ eigsJ(S2F.dim,:,:);
  conds(J) = condsJ(:);
end

end
