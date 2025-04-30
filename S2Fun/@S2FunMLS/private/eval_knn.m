function [vals, conds] = eval_knn(sF, v)

% get some parameters 
dimensions = size(v);
v = v(:);
N = numel(v);
nn = sF.nn;
nn_total = nn * N;

if (sF.nn < sF.dim)
  sF.nn = 2 * sF.dim;
  warning(sprintf(...
    ['The specified number of neighbors nn was less than the dimension dim.\n\t ' ...
    'nn has been set to 2 * dim.']));
end

[ind, dist] = sF.nodes.find(v, nn); 
% grid_id = id of the neighbors (in the grid of sF)
grid_id = reshape(ind', nn_total, 1);
% v_id = id of entry of v (where we want to eval sF)
v_id = reshape(repmat((1:N), nn, 1), nn_total, 1);

% compute for every center from v the matrix of all basis functions evaluated at
% all neighbors of this center 
if (~sF.centered)
  % evaluate the basis functions on the nodes
  % choose faster way between computing all values and reusing them or
  % computing values on fibgrid(grid_id)
  if nn_total > numel(sF.nodes.x)
    basis_on_grid = eval_basis_functions(sF); 
    G = basis_on_grid(grid_id, :)';
  else
    G = eval_basis_functions(sF, sF.nodes(grid_id))';
  end
  g_book = reshape(eval_basis_functions(sF, v)', sF.dim, 1, N);
else
  % compute the rotations that shift each element of v into the north pole
  rot = rotation.map(v, vector3d.Z);
  rot = rot(v_id);
  rotneighbors = rot .* sF.nodes(grid_id);

  basis_on_grid = eval_basis_functions(sF, rotneighbors);
  basis_in_pole = eval_basis_functions(sF, vector3d.Z);

  g_book = repmat(basis_in_pole', 1, 1, N);
  G = basis_on_grid';
end 
G_book = reshape(G, sF.dim, nn, N);

% compute the weights, set delta slighlty larger than the farthest neighbor 
deltas = 1.1 * max(dist, [], 2); 
weights = sF.w(dist ./ deltas);
W_book = reshape(weights', 1, nn, N);

% compute rescaling parameters for bether condition of the gram matrix
s = sqrt(sum(G_book.^2 .* W_book, 2));
sT = pagetranspose(s);

% start computing the (rescaled) Gram matrix
W_times_G_book = pagetranspose(G_book .* W_book) ./ sT;
Gram_book = pagemtimes(G_book, W_times_G_book) ./ s;

% compute the generating functions
g_book = g_book ./ s;
genfuns_book = pagemtimes(W_times_G_book, pagemldivide(Gram_book, g_book));

% assemble the right hand side of the Gram system
% also rescale the right hand sides of the Gram systems
f_book = reshape(sF.values(grid_id), nn, 1, N);
vals = sum(f_book .* genfuns_book, 1);
vals = vals(:);
vals = reshape(vals, dimensions);
if isreal(sF.values)
  vals = real(vals);
end

if nargout == 2
  eigs = pagesvd(Gram_book);
  conds = eigs(1,:,:) ./ eigs(sF.dim,:,:);
  conds = conds(:);
  conds = reshape(conds, dimensions);
end

end