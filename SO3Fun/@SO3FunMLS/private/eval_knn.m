function [vals, conds] = eval_knn(SO3F, ori, varargin)

if (SO3F.nn < SO3F.dim)
  SO3F.nn = 2 * SO3F.dim;
  warning(sprintf(...
    ['The specified number of neighbors nn was less than the dimension dim.\n\t ' ...
    'nn has been set to 2 * dim.']));
end

ori = ori(:);
N = numel(ori);
nn = SO3F.nn;
nn_total = nn * N;
 
% find the neighbors, construct index vectors
[ind, dist] = SO3F.nodes.find(ori, nn);

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
weights = SO3F.w(dist ./ (1.1 * max(dist, [], 2)))';
clear dist;

% set up the right hand side
grid_vals = reshape(SO3F.values(:), numel(SO3F.nodes), numel(SO3F));
f_book = reshape(grid_vals(grid_id,:), nn, N, numel(SO3F));
if (SO3F.detectOutliers == true)
  oI = computeOutlierIndicators(SO3F); 
  oI = reshape(oI(grid_id), nn, N);
  weights = weights .* exp(-oI);
  clear oI grid_vals;
end

% normalize the maximum weight to 1
% reason for the root is explained after the end of the following large if-block
weights = sqrt(weights ./ max(weights, [], 1));
fw_book = weights .* f_book;
fw_book = permute(fw_book, [1, 3, 2]);
clear f_book;

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
  clear inv_oris projected ori_id;

  % evaluate for every ori all basis functions at all neighbors ...
  G = eval_basis_functions(SO3F, rotneighbors)';
  clear rotneighbors;
  basis_in_pole = eval_basis_functions(SO3F, orientation.id);
  % ... and also in the oris themselves
  g_book = repmat(basis_in_pole', 1, 1, N);
end 
G_book = reshape(G, SO3F.dim, nn, N);
clear G grid_id;

% don't solve the normal equations G'WGc = G'Wf (like cond(G)^2)
% rather let matlab directly find min norm solution of sqrt(W) * (Gc-f)
% internally this uses QR and we end up with only cond(G), without the square!

% B satisfies B' * B = G' * W * G
B_book = G_book .* reshape(weights, [1, size(weights)]);
clear G_book weights;

% compute scaling factors for preconditioning the grams systems
s_book = sqrt(sum(abs(B_book).^2, 2));

% solve the rescaled systems and evaluate MLS
c_book = pagemldivide(pagetranspose(B_book ./ s_book), fw_book) ./ s_book;



clear fw_book;
vals = sum(c_book .* g_book, 1);
clear c_book g_book;

% set correct output format
vals = permute(vals, [3, 2, 1]);

if isalmostreal(SO3F.values)
  vals = real(vals);
end

if nargout == 2
  eigs = pagesvd(B_book ./ s_book);
  conds = eigs(1,:,:) ./ eigs(SO3F.dim,:,:);
  conds = conds(:);
end

end
