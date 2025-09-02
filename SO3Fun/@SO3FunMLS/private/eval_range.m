function [vals, conds] = eval_range(SO3F, ori)

dimensions = size(ori);
ori = ori(:);
N = size(ori, 1);
vals = zeros(N, numel(SO3F));
conds = zeros(N, 1);
sz = size(SO3F); SO3F = SO3F.subSet(':');
 
% get the neighbors and count them
ind = SO3F.nodes.find(ori, SO3F.delta); 
nn = sum(ind, 2);

% for points with too less neighbors, we instead choose the SO3F.dim nearest ones
I = nn < SO3F.dim;
if (sum(I) > 0)
  warning(sprintf( ...
    ['Some centers did not have sufficiently many neighbors. \n' ...
    '\t In this case the ', num2str(SO3F.dim), ' closest neighbors have been used.']));
  
  nn_original = SO3F.nn;
  SO3F.nn = SO3F.dim;
  if (nargout == 2)
    [vals(I,:), conds(I)] = SO3F.eval(ori.subSet(I));
  else
    vals(I,:) = SO3F.eval(ori.subSet(I));
  end
  SO3F.nn = nn_original;
  if (sum(I) == N)
    return;
  end
end

% now continue with the points that have sufficiently many neighbors 
J = ~I;
ori = ori.subSet(J);
N = sum(J);
[ind, dist] = SO3F.nodes.find(ori, SO3F.delta);
[grid_id, ori_id] = find(ind');
nn = sum(ind, 2);

% the created vector col_id helps to create the (SO3F.dim x N) matrix G, which
% holds the values of the basis functions at all neighbors of all centers from v
% col_id skips entries, whenever a center has not nn_max many neighbors 
nn_total = sum(nn);
nn_max = max(nn); 
start_id = cumsum(nn(1:N-1)) + 1;
temp = ones(nn_total, 1);
temp(start_id) = 1 - nn(1:N-1);
temp = cumsum(temp);
col_id = (ori_id-1) * nn_max + temp;

% compute the weights
weights = zeros(N * nn_max, 1);
weights(col_id) = SO3F.w(nonzeros(dist) / SO3F.delta);
clear dist;
% also get the needed values of SO3F on its grid
f = zeros(N * nn_max, numel(SO3F));
f(col_id,:) = SO3F.values(grid_id,:);
f_book = reshape(f, nn_max, N, numel(SO3F));

G = zeros(SO3F.dim, nn_max * N); 
% Compute G_book. Each page contains the values of the basis at all neighbors. 
% if CS is trivial and SO3F.centered is disabled, we can speed up things
if ((SO3F.CS.id == 1) && (SO3F.centered == false) && (nn_total > numel(SO3F.nodes)))
  basis_on_grid = eval_basis_functions(SO3F)';
  G(:,col_id) = basis_on_grid(:,grid_id);
  clear basis_on_grid;
  % for odd monomials we have p(-o) = -p(o)
  if (mod(SO3F.degree, 2) == 1)
    temp1 = ori.abcd;
    temp1 = temp1(ori_id,:);
    temp2 = SO3F.nodes.abcd;
    temp2 = temp2(grid_id,:);
    I = col_id(sum(temp1 .* temp2, 2) < 0);
    marker = true(1, SO3F.dim);
    G(marker,I) = - G(marker,I);
    clear temp1 temp2 I;
  end
  basis_in_ori = eval_basis_functions(SO3F, ori);
elseif (~SO3F.centered)
  % evaluate for every ori all basis function
  % NOTE: projecting to fR is very important, since later we treat all oris as 
  %       points on the sphere S^3 and use monomialss at all neighbors ...
  projected = project2FundamentalRegion(SO3F.nodes(grid_id), ori(ori_id));
  G(:, col_id) = eval_basis_functions(SO3F, projected)';
  clear projected;
  basis_in_ori = eval_basis_functions(SO3F, ori);
else
  % shift the local problems to be centered around orientation.id
  inv_oris = inv(ori);
  inv_oris = reshape(inv_oris(ori_id), size(SO3F.nodes(grid_id)));
  projected = project2FundamentalRegion(SO3F.nodes(grid_id), ori(ori_id));
  rotneighbors = inv_oris .* projected;
  clear inv_oris projected ori_id;

  % evaluate the basis funcitons on the grid
  basis_on_grid = eval_basis_functions(SO3F, rotneighbors);
  clear rotneighbors;
  basis_in_pole = eval_basis_functions(SO3F, orientation.id);
  
  basis_in_ori = repmat(basis_in_pole, N, 1);
  G(:, col_id) = basis_on_grid';
end
G_book = reshape(G, SO3F.dim, nn_max, N);
clear grid_id;

% compute rescaling parameters for better condition of the gram matrices
s = sqrt(abs(sum(reshape(G.^2 .* weights', SO3F.dim, nn_max, N), 2)));

% start computing the pairwise discrete inner products (Gram matrix) 
W_times_G_book = pagetranspose(reshape(G .* weights', SO3F.dim, nn_max, N) ./ s);
clear weights G;
Gram_book = pagemtimes(G_book, W_times_G_book) ./ s;

% compute the generating functions
g_book = reshape(basis_in_ori', SO3F.dim, 1, N) ./ s;
clear s;
genfuns_book = pagemtimes(W_times_G_book, pagemldivide(Gram_book, g_book));
genfuns_book = permute(genfuns_book,[1,3,2]);
clear W_times_G_book g_book;

% compute the values of the MLS approximation
valsJ = sum(f_book .* genfuns_book, 1);
vals(J,:) = reshape(valsJ,[numel(ori) numel(SO3F)]);
if isscalar(SO3F)
  vals = reshape(vals, dimensions);
else
  vals = reshape(vals, [prod(dimensions) sz]);
end

if isalmostreal(SO3F.values)
  vals = real(vals); 
end

if nargout == 2
  eigsJ = pagesvd(Gram_book);
  condsJ = eigsJ(1,:,:) ./ eigsJ(SO3F.dim,:,:);
  conds(J) = condsJ(:);
  conds = reshape(conds, dimensions);
end

end
