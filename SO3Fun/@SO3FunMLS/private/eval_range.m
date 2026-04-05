function [vals, conds, warn_smallnn, warn_bignn] = eval_range(SO3F, ori, varargin)

ori = ori(:);
N = size(ori, 1);
vals = zeros(N, numel(SO3F));
conds = zeros(N, 1);
SO3F = SO3F.subSet(':');
 
% get the neighbors and count them
ind = SO3F.nodes.find(ori, SO3F.delta);
nn = sum(ind, 2);

warn_smallnn = false;
warn_bignn = false;

% for points with too few neighbors, we instead choose the SO3F.dim nearest ones
% NOTE: the expectation of the lebesgue constant is infinite in this setting
too_few_neighbors = nn <= SO3F.dim;
if (sum(too_few_neighbors) > 0)
  warn_smallnn = true;
  % evaluate the critical nodes via knn-search instead of rangesearch
  delta_original = SO3F.delta;
  oF_original = SO3F.oF;
  % for SO3F.nn = SO3F.dim, the expectation of the lebesgue constant is infinite
  SO3F.delta = 0;
  SO3F.oF = 1;

  if (nargout == 2)
    [temp, conds(too_few_neighbors)] = SO3F.eval(ori.subSet(too_few_neighbors), varargin{:});
  else
    temp = SO3F.eval(ori.subSet(too_few_neighbors), varargin{:});
  end
  vals(too_few_neighbors,:) = reshape(temp, sum(too_few_neighbors), numel(SO3F));

  SO3F.oF = oF_original;
  SO3F.delta = delta_original;

  if (sum(too_few_neighbors) == N)
    return;
  end
end

% for points with too many neighbors, we choose only the SO3F.dim * SO3F.oF_max nearest ones
too_many_neighbors = nn > SO3F.dim * SO3F.oF_max;
if (sum(too_many_neighbors) > 0)
  warn_bignn = true;
  % evaluate the critical nodes via knn-search instead of rangesearch
  delta_original = SO3F.delta;
  oF_original = SO3F.oF;
  % for SO3F.nn = SO3F.dim, the expectation of the lebesgue constant is infinite
  SO3F.delta = 0;
  SO3F.oF = SO3F.oF_max;
  if (nargout == 2)
    [temp, conds(too_many_neighbors)] = SO3F.eval(ori.subSet(too_many_neighbors), varargin{:});
  else
    temp = SO3F.eval(ori.subSet(too_many_neighbors), varargin{:});
  end
  vals(too_many_neighbors,:) = reshape(temp, sum(too_many_neighbors), numel(SO3F));

  SO3F.oF = oF_original;
  SO3F.delta = delta_original;

  if (sum(too_many_neighbors | too_few_neighbors) == N)
    return;
  end
end

% continue with the points that have neither too few nor many neighbors
J = ~(too_few_neighbors | too_many_neighbors);
J_idx = find(J);
ori = ori.subSet(J);
N = sum(J);
[ind, dist] = SO3F.nodes.find(ori, SO3F.delta, varargin{:});

% if optimal subsampling is set to true, we can now fall back to the eval_knn case 
%   where all neighborhoods have the same size (the dim of the ansatz space) 
if (SO3F.subsample == true)
  ind = SO3F.find_optimal_subset(logical(ind), ori, varargin{:});
end

[grid_id, ori_id] = find(ind');
nn = sum(ind, 2);
nn_total = sum(nn);
clear ind;

if (SO3F.subsample == true)
  dist = angle(ori.subSet(ori_id), SO3F.nodes.subSet(grid_id));
  dist = sparse(ori_id, grid_id, dist, N, numel(SO3F.nodes));
end

% Compute G_book. Each page contains the values of the basis at all neighbors. 
%   if CS is trivial and SO3F.centered is disabled, we can speed up things
if ((SO3F.CS.id == 1) && (SO3F.centered == false) && (nn_total > numel(SO3F.nodes)))
  basis_on_grid = eval_basis_functions(SO3F)';
  G = basis_on_grid(:,grid_id);
  clear basis_on_grid;
  
  % odd basis functions may clash with antipodal option, since (-ori) = -p(ori)
  % thus make sure to use the representer which is closer to the center
  if (mod(SO3F.degree, 2) > 0)
    I = sum(ori.subSet(ori_id).abcd .* SO3F.nodes.subSet(grid_id).abcd, 2) < 0;
    G(:,I) = G(:,I) * (-1);
    clear I;
  end

  basis_in_ori = eval_basis_functions(SO3F, ori);
elseif (~SO3F.centered)
  % evaluate for every ori all basis function
  % NOTE: projecting to fR is very important, since later we treat all oris as 
  %       points on the sphere S^3 and use monomials at all neighbors ...
  projected = project2FundamentalRegion(SO3F.nodes(grid_id), ori(ori_id));  % In case of 2 symmetries, we have to symmetrise here w.r.t. lower symmetry (done in eval routine) 
  G(:, col_id) = eval_basis_functions(SO3F, projected)';
  clear projected;
  basis_in_ori = eval_basis_functions(SO3F, ori);
else
  % shift the local problems to be centered around orientation.id
  inv_oris = inv(ori);
  inv_oris = reshape(inv_oris(ori_id), size(SO3F.nodes(grid_id)));
  projected = project2FundamentalRegion(SO3F.nodes(grid_id), ori(ori_id));  % In case of 2 symmetries, we have to symmetrise here w.r.t. lower symmetry (done in eval routine) 
  rotneighbors = inv_oris .* projected;
  clear inv_oris projected;

  % evaluate the basis functions on the grid
  basis_on_grid = eval_basis_functions(SO3F, rotneighbors);
  clear rotneighbors;
  G = basis_on_grid.';
  clear basis_on_grid;

  % ensure correct representer for antipodal SO3F with odd degree (same as above)
  if (SO3F.antipodal && (mod(SO3F.degree, 2) == 1))
    I = sum(ori.subSet(ori_id).abcd .* SO3F.nodes.subSet(grid_id).abcd, 2) < 0;
    G(:,I) = G(:,I) * (-1);
  end

  basis_in_pole = eval_basis_functions(SO3F, orientation.id);
  basis_in_ori = repmat(basis_in_pole, N, 1);
  clear basis_in_pole;
end
G = G.';

% compute the weights
% dist(find(ind)) instead of nonzeros(dist), since elements of v might be
%   contained in S2F.nodes ==> distance 0, but in neighborhood
I = sub2ind(size(dist), ori_id, grid_id);
weights = SO3F.w(dist(I) / SO3F.delta);
clear dist I;

if (SO3F.detectOutliers == true)
  oI = computeOutlierIndicators(SO3F);
  oI_factor = exp(-oI(grid_id));
  weights = weights .* oI_factor;
  clear oI oI_factor;
end

% set up right hand side
grid_vals = reshape(SO3F.values(:), numel(SO3F.nodes), numel(SO3F));
f = grid_vals(grid_id,:);

if SO3F.regularize
  [c_book, conds(J_idx)]  = solve_lsq_book_varsize(weights, G, f, nn, ...
    'regularize', 'maxcond', SO3F.maxcond, 'mindond', SO3F.mincond, ...
    'basis_weights', SO3F.basis_weights, varargin{:});
else
  [c_book, conds(J_idx)]  = solve_lsq_book_varsize(weights, G, f, nn, varargin{:});
end

vals(J_idx,:) = permute(sum(basis_in_ori .* permute(c_book, [3 1 2]), 2), [1 3 2]);

if isalmostreal(SO3F.values)
  vals = real(vals); 
end

end
