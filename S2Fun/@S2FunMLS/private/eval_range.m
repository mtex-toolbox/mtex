function [vals, conds] = eval_range(sF, v)

% get the number of points in v
N = size(v, 1);
v = v(:);
 
% get the neighbors and the distance to them
[ind, dist] = sF.nodes.find(v, sF.delta); 
[grid_id, v_id] = find(ind');
nn = sum(ind, 2);

% create index vectors in order to use pagefuns
nn_total = sum(nn);
nn_max = max(nn);
start_id = cumsum(nn(1:N-1)) + 1;
temp = ones(nn_total, 1);
temp(start_id) = 1 - nn(1:N-1);
% col_id helps to create the (sF.dim x N) matrix G, which holds the values of
% the basis functions at all neighbors of all centers from v  
% col_id skips entries, whenever a center has not nn_max many neighbors
temp = cumsum(temp);
col_id = (v_id-1) * nn_max + temp;

G = zeros(sF.dim, nn_max * N); 
if (~sF.centered)
  % evaluate the basis functions on the nodes
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
  basis_in_v = repmat(basis_in_pole, N, 1);
  G(:, col_id) = basis_on_grid';
end
G_book = reshape(G, sF.dim, nn_max, N);

% compute the weights
weights = zeros(N * nn_max, 1);
weights(col_id) = sF.w(nonzeros(dist) / sF.delta);

% start computing the pairwise discrete inner products (Gram matrix) 
W_times_G_book = pagetranspose(reshape(G .* weights', sF.dim, nn_max, N));

% rescale the rows and columns of each Gram matrix (for better condition)
% the scale parameters s are the roots of the diagonal entries 
s = sqrt(sum(G.^2 .* weights', 2));
sT = pagetranspose(s);
Gram_book = pagemtimes(G_book, W_times_G_book) ./ s ./ sT;

% compute the generating functions
g_book = reshape(basis_in_v', sF.dim, 1, N) ./ s;
genfuns_book = pagemtimes(W_times_G_book ./ sT, pagemldivide(Gram_book, g_book));

% compute the values of the MLS approximation
f = zeros(N * nn_max, 1);
f(col_id) = sF.values(grid_id);
f_book = reshape(f, nn_max, 1, N);
vals = sum(f_book .* genfuns_book, 1);
vals = vals(:);

if isreal(sF.values)
  vals = real(vals);
end

if nargout == 2
  conds = pagefun(@cond, Gram_book);
end

end