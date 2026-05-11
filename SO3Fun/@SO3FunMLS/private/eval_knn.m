function [vals, conds] = eval_knn(SO3F, ori, varargin)

ori = ori(:);
N = numel(ori);
nn = SO3F.nn;
nn_total = nn * N;
 
% Find neighbors and perform subsampling. If the flag is set, compute distances.
[ind, dist] = SO3F.nodes.find(ori, nn, 'searcher', SO3F.searcher);

if (SO3F.subsample == true)
  ind = SO3F.find_optimal_subset(ind, ori, varargin{:});
  nn_total = N * SO3F.dim;
  nn = SO3F.dim;
end

% grid_id = id of the neighbors (in the grid of SO3F)
grid_id = reshape(ind', nn_total, 1);
clear ind;
% ori_id = id of entry of ori (where we want to eval SO3F)
ori_id = reshape(repmat((1:N), nn, 1), nn_total, 1);

if (SO3F.subsample == true)
  dist = angle(ori.subSet(ori_id), SO3F.nodes.subSet(grid_id));
  dist = reshape(dist, SO3F.dim, N)';
end

% compute the weights, set delta slighlty larger than the farthest neighbor 
% take the root of the weights, see after large if-block for explanation
weights = SO3F.w(dist ./ (1.00 * max(dist, [], 2)))';
clear dist;

% set up the right hand side
grid_vals = reshape(SO3F.values(:), numel(SO3F.nodes), numel(SO3F));
f_book = permute(reshape(grid_vals(grid_id,:), nn, N, numel(SO3F)), [1, 3, 2]);
if (SO3F.detectOutliers == true)
  oI = computeOutlierIndicators(SO3F); 
  oI = reshape(oI(grid_id), nn, N);
  weights = weights .* exp(-oI);
  clear oI grid_vals;
end
W_book = permute(weights, [1, 3, 2]);
clear weights;

% Compute G_book. Each page contains the values of the basis at all neighbors. 
% if CS is trivial and SO3F.centered is disabled, we can speed up things
if ((SO3F.CS.id == 1) && (SO3F.centered == false) && (nn_total > numel(SO3F.nodes)))
  G = eval_basis_functions(SO3F)';
  G = G(:,grid_id);
  % for odd monomials we have p(-o) = -p(o)
  if (mod(SO3F.degree, 2) == 1)
    temp1 = reshape(repmat(ori, 1, nn).', nn_total, 1);
    temp2 = SO3F.nodes.abcd;
    temp2 = temp2(grid_id,:);
    I = sum(temp1.abcd .* temp2, 2) < 0;
    marker = true(1, SO3F.dim);
    G(marker,I) = - G(marker,I);
    clear temp1 temp2 I;
  end
  g_book = reshape(eval_basis_functions(SO3F, ori)', SO3F.dim, 1, N);
elseif (~SO3F.centered)
  % evaluate for every ori all basis functions at all neighbors ...
  % NOTE: projecting to fR is very important, since later we treat all oris as 
  %       points on the sphere S^3 and use monomials
  projected = project2FundamentalRegion(SO3F.nodes(grid_id), ori(ori_id));  % In case of 2 symmetries, we have to symmetrise here w.r.t. lower symmetry (done in eval routine) 
  G = eval_basis_functions(SO3F, projected)'; 
  clear projected;
  % ... and also in the oris themselves
  g_book = reshape(eval_basis_functions(SO3F, ori)', SO3F.dim, 1, N);
else
  % shift the local problems to be centered around orientation.id
  % this enhances the condition of the gram matrices dramatically
  inv_oris = inv(ori);
  inv_oris = reshape(inv_oris(ori_id), size(SO3F.nodes(grid_id)));
  projected = project2FundamentalRegion(SO3F.nodes(grid_id), ori(ori_id));  % In case of 2 symmetries, we have to symmetrise here w.r.t. lower symmetry (done in eval routine) 
  rotneighbors = inv_oris .* projected;
  clear inv_oris projected;

  % evaluate for every ori all basis functions at all neighbors ...
  G = eval_basis_functions(SO3F, rotneighbors)';
  clear rotneighbors;

  if (SO3F.antipodal && (mod(SO3F.degree, 2) == 1))
    I = sum(ori.subSet(ori_id).abcd .* SO3F.nodes.subSet(grid_id).abcd, 2) < 0;
    G(:,I) = G(:,I) * (-1);
  end
  clear ori_id;

  basis_in_pole = eval_basis_functions(SO3F, orientation.id);
  g_book = repmat(basis_in_pole', 1, 1, N);
end 
G_book = pagetranspose(reshape(G, SO3F.dim, nn, N));
clear G grid_id;

% solve the systems and evaluate
if SO3F.regularize
  [c_book, conds] = solve_lsq_book_constsize(W_book, G_book, f_book, ...
    'regularize', 'maxcond', SO3F.maxcond, 'mincond', SO3F.mincond, ...
    'basis_weights', SO3F.basis_weights, varargin{:});
else
  [c_book, conds] = solve_lsq_book_constsize(W_book, G_book, f_book, ...
    varargin{:});
end
clear f_book G_book W_book;

vals = permute(sum(c_book .* g_book, 1), [3, 2, 1]);

if isalmostreal(SO3F.values)
  vals = real(vals);
end

end
