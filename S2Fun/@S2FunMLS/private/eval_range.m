function [vals, conds] = eval_range(sF, v, varargin)

% get parameters
dimensions = size(v);
v = v(:);
N = size(v, 1);
vals = zeros(N, 1);
conds = zeros(N, 1);
 
% get the neighbors 
ind = sF.nodes.find(v, sF.delta); 
nn = sum(ind, 2);

% for points with too less neighbors, we instead choose the sF.dim nearest ones
% TODO: choose more neighbors than only the sF.dim nearest ones, since the
% expectation of the lebesgue constant is infinite in this setting
% (interpolation)
I = nn < sF.dim;
if (sum(I) > 0)
  warning(sprintf( ...
    ['Some centers did not have sufficiently many neighbors. \n' ...
    '\t In this case the numer of neighbors was set to the dimension of the ansatz space.']));
  
  nn_original = sF.nn;
  sF.nn = sF.dim;
  if (nargout == 2)
    [vals(I), conds(I)] = sF.eval(v.subSet(I));
  else
    vals(I) = sF.eval(v.subSet(I));
  end
  sF.nn = nn_original;
  if (sum(I) == N)
    return;
  end
end

% now continue with the points that have sufficiently many neighbors
J = ~I;
v = v.subSet(J);
N = sum(J);
[ind, dist] = sF.nodes.find(v, sF.delta);
% if optimal subsampling is set to true, we can now fall back to the eval_knn case 
%   where all neighborhoods have the same size (the dim of the ansatz space) 
if (sF.subsample == true)
  ind = sF.find_optimal_subset(ind, v, varargin{:});
end

[grid_id, v_id] = find(ind');
nn = sum(ind, 2);

if (sF.subsample == true)
  dist = angle(v.subSet(v_id), sF.nodes.subSet(grid_id));
  dist = sparse(v_id, grid_id, dist, N, numel(sF.nodes));
end

% the index vector col_id helps to construct the (sF.dim x N) matrix G, which
% holds the values of the basis functions at all neighbors of all centers from v
% col_id skips entries, whenever a center has not nn_max many neighbors 
nn_total = sum(nn);
nn_max = max(nn);
start_id = cumsum(nn(1:N-1)) + 1;
temp = ones(nn_total, 1);
temp(start_id) = 1 - nn(1:N-1);
temp = cumsum(temp);
col_id = (v_id-1) * nn_max + temp;

% compute for every center from v the matrix of all basis functions evaluated at
% all neighbors of this center 
G = zeros(sF.dim, nn_max * N);
% evaluate the basis functions on the nodes
if (~sF.centered)
  % choose faster way between computing all values and reusing them or
  % computing values on fibgrid(grid_id)
  if nn_total > numel(sF.nodes.x)
    basis_on_grid = eval_basis_functions(sF);
    G(:, col_id) = basis_on_grid(grid_id, :)';
  else
    G(:, col_id) = eval_basis_functions(sF, sF.nodes(grid_id))';
  end
  basis_in_v = eval_basis_functions(sF, v);
else
  % compute the rotations that shift each element of v into the north pole
  rot = rotation.map(v, vector3d.Z);
  rot = rot(v_id);
  rotneighbors = rot .* sF.nodes(grid_id);

  % determine which basis to use and evaluate it on the grid and on v
  basis_on_grid = eval_basis_functions(sF, rotneighbors);
  basis_in_pole = eval_basis_functions(sF, vector3d.Z);
  
  basis_in_v = repmat(basis_in_pole, N, 1);
  G(:, col_id) = basis_on_grid';
end
G_book = reshape(G, sF.dim, nn_max, N);

% compute the weights
weights = zeros(N * nn_max, 1);
weights(col_id) = sF.w(nonzeros(dist) / sF.delta);

% compute rescaling parameters for bether condition of the gram matrix
s = sqrt(abs(sum(reshape(G.^2 .* weights', sF.dim, nn_max, N), 2)));
sT = pagetranspose(s);

% start computing the pairwise discrete inner products (Gram matrix) 
W_times_G_book = pagetranspose(reshape(G .* weights', sF.dim, nn_max, N)) ./ sT;
Gram_book = pagemtimes(G_book, W_times_G_book) ./ s;

% compute the generating functions
g_book = reshape(basis_in_v', sF.dim, 1, N) ./ s;
genfuns_book = pagemtimes(W_times_G_book, pagemldivide(Gram_book, g_book));

% compute the values of the MLS approximation
f = zeros(N * nn_max, 1);
f(col_id) = sF.values(grid_id);
f_book = reshape(f, nn_max, 1, N);
valsJ = sum(f_book .* genfuns_book, 1);
vals(J) = valsJ(:);
vals = reshape(vals, dimensions);
if isreal(sF.values)
  vals = real(vals); 
end

if nargout == 2
  eigsJ = pagesvd(Gram_book);
  condsJ = eigsJ(1,:,:) ./ eigsJ(sF.dim,:,:);
  conds(J) = condsJ(:);
  conds = reshape(conds, dimensions);
end

end
