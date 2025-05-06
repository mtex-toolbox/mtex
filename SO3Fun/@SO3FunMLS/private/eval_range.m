function [vals, conds] = eval_range(sF, ori)

dimensions = size(ori);
ori = ori(:);
N = size(ori, 1);
vals = zeros(N, 1);
conds = zeros(N, 1);
 
% get the neighbors and count them
ind = sF.nodes.find(ori, sF.delta); 
nn = sum(ind, 2);

% for points with too less neighbors, we instead choose the sF.dim nearest ones
I = nn < sF.dim;
if (sum(I) > 0)
  warning(sprintf( ...
    ['Some centers did not have sufficiently many neighbors. \n' ...
    '\t In this case the <dimension> closest neighbors have been used.']));
  
  nn_original = sF.nn;
  sF.nn = sF.dim;
  if (nargout == 2)
    [vals(I), conds(I)] = sF.eval(ori.subSet(I));
  else
    vals(I) = sF.eval(ori.subSet(I));
  end
  sF.nn = nn_original;
  if (sum(I) == N)
    return;
  end
end

% now continue with the points that have sufficiently many neighbors 
J = ~I;
ori = ori.subSet(J);
N = sum(J);
[ind, dist] = sF.nodes.find(ori, sF.delta);
[grid_id, ori_id] = find(ind');
nn = sum(ind, 2);

% the created vector col_id helps to create the (sF.dim x N) matrix G, which
% holds the values of the basis functions at all neighbors of all centers from v
% col_id skips entries, whenever a center has not nn_max many neighbors 
nn_total = sum(nn);
nn_max = max(nn); 
start_id = cumsum(nn(1:N-1)) + 1;
temp = ones(nn_total, 1);
temp(start_id) = 1 - nn(1:N-1);
temp = cumsum(temp);
col_id = (ori_id-1) * nn_max + temp;

% Compute G_book. Each page contains the values of the basis at all neighbors. 
G = zeros(sF.dim, nn_max * N); 
if (~sF.centered)
  % evaluate for every ori all basis function
  % NOTE: projecting to fR is very important, since later we treat all oris as 
  %       points on the sphere S^3 and use monomialss at all neighbors ...
  projected = project2FundamentalRegion(sF.nodes(grid_id), sF.nodes.CS, ori(ori_id));
  % the projected orientations might be at the opposite side of S^3
  I = sum(projected.abcd .* ori(ori_id).abcd, 2) < 0;
  projected(I) = orientation(projected(I)) * orientation([-1,0,0,0]);
  G(:, col_id) = eval_basis_functions(sF, projected)';
  basis_in_ori = eval_basis_functions(sF, ori);
else
  % shift the local problems to be centered around orientation.id
  inv_oris = reshape(inv(ori(ori_id)), size(sF.nodes(grid_id)));
  projected = project2FundamentalRegion(sF.nodes(grid_id), sF.nodes.CS, ori(ori_id));
  % the projected orientations might be at the opposite side of S^3
  I = sum(projected.abcd .* ori(ori_id).abcd, 2) < 0;
  projected(I) = orientation(projected(I)) * orientation([-1,0,0,0]);
  rotneighbors = inv_oris .* projected;

  % evaluate the basis funcitons on the grid
  basis_on_grid = eval_basis_functions(sF, rotneighbors);
  basis_in_pole = eval_basis_functions(sF, orientation.id);
  
  basis_in_ori = repmat(basis_in_pole, N, 1);
  G(:, col_id) = basis_on_grid';
end
G_book = reshape(G, sF.dim, nn_max, N);

% compute the weights
weights = zeros(N * nn_max, 1);
weights(col_id) = sF.w(nonzeros(dist) / sF.delta);

% compute rescaling parameters for better condition of the gram matrices
s = sqrt(abs(sum(reshape(G.^2 .* weights', sF.dim, nn_max, N), 2)));
sT = pagetranspose(s);

% start computing the pairwise discrete inner products (Gram matrix) 
W_times_G_book = pagetranspose(reshape(G .* weights', sF.dim, nn_max, N)) ./ sT;
Gram_book = pagemtimes(G_book, W_times_G_book) ./ s;

% compute the generating functions
g_book = reshape(basis_in_ori', sF.dim, 1, N) ./ s;
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