function [vals, conds] = eval_range(SO3F, ori, varargin)

ori = ori(:);
N = size(ori, 1);
vals = zeros(N, numel(SO3F));
conds = zeros(N, 1);
SO3F = SO3F.subSet(':');
 
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

% if optimal subsampling is set to true, we can now fall back to the eval_knn case 
%   where all neighborhoods have the same size (the dim of the ansatz space) 
if (SO3F.subsample == true)
  ind = SO3F.find_optimal_subset(logical(ind), ori, varargin{:});
end

[grid_id, ori_id] = find(ind');
nn = sum(ind, 2);
clear ind;

if (SO3F.subsample == true)
  dist = angle(ori.subSet(ori_id), SO3F.nodes.subSet(grid_id));
  dist = sparse(ori_id, grid_id, dist, N, numel(SO3F.nodes));
end

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
clear temp start_id;

% TODO: nn_max might be much larger than mean(nn) at very few occations
%   ==> compute in batches of similar nn for less ram usage

% compute the weights
weights = zeros(N * nn_max, 1);
% dist(find(ind)) instead of nonzeros(dist), since elements of v might be
%   contained in SO3F.nodes ==> distance 0, but in neighborhood
K = sub2ind(size(dist), ori_id, grid_id);
weights(col_id) = SO3F.w(dist(K) / SO3F.delta);
clear dist K;

% scale down weights of outliers, if enabled
if (SO3F.detectOutliers == true)
  oI = computeOutlierIndicators(SO3F);
  oI_factor = zeros(N * nn_max, 1);
  oI_factor(col_id) = exp(-oI(grid_id));
  weights = weights .* oI_factor;
  clear oI_factor;
end

% for each center, normalize the maximum weight to be 1
weights = reshape(weights, nn_max, N);
weights = weights ./ max(weights, [], 1);
weights = sqrt(weights(:));

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

  basis_in_pole = eval_basis_functions(SO3F, orientation.id);
  basis_in_ori = repmat(basis_in_pole, N, 1);
  clear basis_in_pole;

  G(:, col_id) = basis_on_grid';
  clear basis_on_grid;
end

clear ori_id;

% dont solve the normal equations G'WGc = G'Wf (like cond(G)^2)
% rather let matlab directly find min norm solution of sqrt(W) * (Gc-f)
% internally this uses QR and we end up with only cond(G)

B = G .* weights';
B_book = pagetranspose(reshape(B, SO3F.dim, nn_max, N)); 
clear B G;

% compute scaling factors (norms of columns of G_times_W_book)
s_book = sqrt(sum(abs(B_book).^2, 1));

% set up right hand side
f = zeros(N * nn_max, numel(SO3F));
grid_vals = reshape(SO3F.values(:), numel(SO3F.nodes), numel(SO3F));
f(col_id,:) = grid_vals(grid_id,:);
clear col_id grid_id grid_vals;
fw_book = permute(reshape((weights .* f).', numel(SO3F), nn_max, N), [2 1 3]);
clear f weights;

% compute the generating functions
c_book = pagemldivide(B_book ./ s_book, fw_book) ./ pagetranspose(s_book);
clear fw_book;
vals(J,:) = permute(sum(basis_in_ori .* permute(c_book, [3 1 2]), 2), [1 3 2]);
clear basis_in_ori c_book;

if isalmostreal(SO3F.values)
  vals = real(vals); 
end

if nargout == 2
  eigsJ = pagesvd(B_book ./ s_book);
  condsJ = eigsJ(1,:,:) ./ eigsJ(SO3F.dim,:,:);
  conds(J) = condsJ(:);
end

end
