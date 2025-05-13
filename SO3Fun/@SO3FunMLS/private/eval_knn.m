function [vals, conds] = eval_knn(sF, ori)

% TODO: allocate storage

dimensions = size(ori);
ori = ori(:);
N = numel(ori);
nn = sF.nn;
nn_total = nn * N;

if (sF.nn < sF.dim)
  sF.nn = 2 * sF.dim;
  warning(sprintf(...
    ['The specified number of neighbors nn was less than the dimension dim.\n\t ' ...
    'nn has been set to 2 * dim.']));
end
 
[ind, dist] = sF.nodes.find(ori, nn); 
% grid_id = id of the neighbors (in the grid of sF)
grid_id = reshape(ind', nn_total, 1);
% v_id = id of entry of v (where we want to eval sF)
ori_id = reshape(repmat((1:N), nn, 1), nn_total, 1);

% Compute G_book. Each page contains the values of the basis at all neighbors. 
if (~sF.centered)
  % evaluate for every ori all basis functions at all neighbors ...
  % NOTE: projecting to fR is very important, since later we treat all oris as 
  %       points on the sphere S^3 and use monomials
  projected = project2FundamentalRegion(sF.nodes(grid_id), ori(ori_id)); 
  G = eval_basis_functions(sF, projected)'; 
  % ... and also in the oris themselves
  g_book = reshape(eval_basis_functions(sF, ori)', sF.dim, 1, N);
else
  % shift the local problems to be centered around orientation.id
  % this enhances the condition of the gram matrices dramatically
  inv_oris = reshape(inv(ori(ori_id)), size(sF.nodes(grid_id)));
  projected = project2FundamentalRegion(sF.nodes(grid_id), ori(ori_id));
  rotneighbors = inv_oris .* projected;

  % evaluate for every ori all basis functions at all neighbors ...
  G = eval_basis_functions(sF, rotneighbors)';
  basis_in_pole = eval_basis_functions(sF, orientation.id);
  % ... and also in the oris themselves
  g_book = repmat(basis_in_pole', 1, 1, N);
end 
G_book = reshape(G, sF.dim, nn, N);

% compute the weights, set delta slighlty larger than the farthest neighbor 
deltas = 1.1 * max(dist, [], 2); 
weights = sF.w(dist ./ deltas);
W_book = reshape(weights', 1, nn, N);
clear dist weights

% compute rescaling parameters for bether condition of the gram matrix
s = sqrt(sum(G_book.^2 .* W_book, 2));

% start computing the (rescaled) Gram matrix
W_times_G_book = pagetranspose(G_book .* W_book ./ s);
Gram_book = pagemtimes(G_book, W_times_G_book) ./ s;

% compute the generating functions
g_book = g_book ./ s;
genfuns_book = pagemtimes(W_times_G_book, pagemldivide(Gram_book, g_book));
genfuns_book = permute(genfuns_book,[1,3,2]);

% assemble the right hand side of the Gram system
f_book = reshape(sF.values(grid_id,:), nn, N, numel(sF));
vals = sum(f_book .* genfuns_book, 1);
if isscalar(sF)
  vals = reshape(vals, dimensions);
else
  vals = reshape(vals, [numel(ori) size(sF)]);
end

if isalmostreal(sF.values)
  vals = real(vals);
end

if nargout == 2
  eigs = pagesvd(Gram_book);
  conds = eigs(1,:,:) ./ eigs(sF.dim,:,:);
  conds = conds(:);
  conds = reshape(conds, dimensions);
end

end