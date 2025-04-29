function [vals, conds] = eval_knn(sF, v)

% get some parameters 
N = size(v, 1); 
v = v(:);
nn = sF.nn;
nn_total = nn * N;

% get the neighbors and the distance to them
[ind, dist] = sF.nodes.find(v, nn); 
% basis = id of the neighbors (in the grid of sF)
grid_id = reshape(ind', nn_total, 1);
% v_id = id of entry of v (where we want to eval sF)
v_id = reshape(repmat((1:N), nn, 1), nn_total, 1);

% compute for every center from v the matrix of all basis functions evaluated at
% all neighbors of this center 
% ==============================================================================
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

  % determine which basis to use and evaluate them on the grid and on v
  if sF.all_degrees
    if sF.monomials
      basis_on_grid = [eval_monomials(rotneighbors, sF.degree) ...
        eval_monomials(rotneighbors, sF.degree-1)];
      basis_in_pole = [eval_monomials(vector3d.Z, sF.degree) ...
        eval_monomials(vector3d.Z, sF.degree-1)];
    else
      basis_on_grid = [eval_spherical_harmonics(rotneighbors, sF.degree) ... 
        eval_spherical_harmonics(rotneighbors, sF.degree-1)];
      basis_in_pole = [eval_spherical_harmonics(vector3d.Z, sF.degree) ...
        eval_spherical_harmonics(vector3d.Z, sF.degree-1)];
    end
  else
    if sF.monomials
      basis_on_grid = eval_monomials(rotneighbors, sF.degree, sF.tangent);
      basis_in_pole = eval_monomials(vector3d.Z, sF.degree, sF.tangent);
    else
      basis_on_grid = eval_spherical_harmonics(rotneighbors, sF.degree);
      basis_in_pole = eval_spherical_harmonics(vector3d.Z, sF.degree);
    end
  end
  g_book = repmat(basis_in_pole', 1, 1, N);
  G = basis_on_grid';
end 
G_book = reshape(G, sF.dim, nn, N);
% ==============================================================================

% compute the weights
deltas = 1.1 * max(dist, [], 2); 
weights = sF.w(dist ./ deltas);

% start computing the pairwise discrete inner products (Gram matrix) 
W_book = reshape(weights', 1, nn, N);
W_times_G_book = pagetranspose(G_book .* W_book);

% rescale the rows and columns of each Gram matrix (for better condition)
% the scale parameters s are the roots of the diagonal entries 
s = sqrt(sum(G_book.^2 .* W_book, 2));
sT = pagetranspose(s);
Gram_book = pagemtimes(G_book, W_times_G_book) ./ s ./ sT;

% compute the generating functions
g_book = g_book ./ s;
genfuns_book = pagemtimes(W_times_G_book ./ sT, pagemldivide(Gram_book, g_book));

% assemble the right hand side of the Gram system
% also rescale the right hand sides of the Gram systems
f_book = reshape(sF.values(grid_id), nn, 1, N);
vals = sum(f_book .* genfuns_book, 1);
vals = vals(:);

if isreal(sF.values)
  vals = real(vals);
end

if nargout == 2
  conds = pagefun(@cond, G_book_scaled);
end

end