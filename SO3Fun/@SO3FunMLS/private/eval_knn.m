function [vals, conds] = eval_knn(SO3F, ori)

if (SO3F.nn < SO3F.dim)
  SO3F.nn = 2 * SO3F.dim;
  warning(sprintf(...
    ['The specified number of neighbors nn was less than the dimension dim.\n\t ' ...
    'nn has been set to 2 * dim.']));
end

dimensions = size(ori);
ori = ori(:);
N = numel(ori);
nn = SO3F.nn;
nn_total = nn * N;
 
% find the neighbors, construct index vectors
[ind, dist] = SO3F.nodes.find(ori, nn); 
% grid_id = id of the neighbors (in the grid of SO3F)
grid_id = reshape(ind', nn_total, 1);
clear ind;
% v_id = id of entry of v (where we want to eval SO3F)
ori_id = reshape(repmat((1:N), nn, 1), nn_total, 1);

% compute the weights, set delta slighlty larger than the farthest neighbor 
W_book = SO3F.w(dist ./ (1.1 * max(dist, [], 2)));
clear dist;
W_book = reshape(W_book', 1, nn, N);
% also get the needed values of SO3F on its grid
f_book = reshape(SO3F.values(grid_id,:), nn, N, numel(SO3F));

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
  projected = project2FundamentalRegion(SO3F.nodes(grid_id), ori(ori_id)); 
  G = eval_basis_functions(SO3F, projected)'; 
  clear projected;
  % ... and also in the oris themselves
  g_book = reshape(eval_basis_functions(SO3F, ori)', SO3F.dim, 1, N);
else
  % shift the local problems to be centered around orientation.id
  % this enhances the condition of the gram matrices dramatically
  inv_oris = inv(ori);
  inv_oris = reshape(inv_oris(ori_id), size(SO3F.nodes(grid_id)));
  projected = project2FundamentalRegion(SO3F.nodes(grid_id), ori(ori_id));
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

% compute rescaling parameters for bether condition of the gram matrix
s = sqrt(sum(G_book.^2 .* W_book, 2));

% start computing the (rescaled) Gram matrix
W_times_G_book = pagetranspose(G_book .* W_book ./ s);
clear W_book;
Gram_book = pagemtimes(G_book, W_times_G_book) ./ s;

% compute the generating functions
genfuns_book = pagemtimes(W_times_G_book, pagemldivide(Gram_book, g_book ./ s));
genfuns_book = permute(genfuns_book,[1,3,2]);
clear W_times_G_book g_book s;

% assemble the right hand side of the Gram system
vals = sum(f_book .* genfuns_book, 1);
if isscalar(SO3F)
  vals = reshape(vals, dimensions);
else
  vals = reshape(vals, [numel(ori) size(SO3F)]);
end

if isalmostreal(SO3F.values)
  vals = real(vals);
end

if nargout == 2
  eigs = pagesvd(Gram_book);
  conds = eigs(1,:,:) ./ eigs(SO3F.dim,:,:);
  conds = conds(:);
  conds = reshape(conds, dimensions);
end

end
