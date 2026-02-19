function [vals, conds] = eval_range(S2F, v, varargin)

% TODO: make this cleaner, throw away points after some threshold number 

% get parameters
v = v(:);
N = size(v, 1);
vals = zeros(N, numel(S2F));
conds = zeros(N, 1);
 
% get the neighbors 
ind = S2F.nodes.find(v, S2F.delta); 
nn = sum(ind, 2);


% for points with too less neighbors, we instead choose the S2F.dim nearest ones
% NOTE: we choose more neighbors than only the S2F.dim nearest ones, since the
% expectation of the lebesgue constant is infinite in this setting
too_few_neighbors = nn <= S2F.dim;
if (sum(too_few_neighbors) > 0)
  warning(['Some centers did not have sufficiently many neighbors. ' ...
    'In this case the numer of neighbors was set to the dimension of the ansatz space (%d).'], S2F.dim);
  
  % evaluate the critical nodes via knn-search instead of rangesearch
  delta_original = S2F.delta;
  oF_original = S2F.oF;
  % for S2F.nn = S2F.dim, the expectation of the lebesgue constant is infinite
  S2F.delta = 0;
  S2F.oF = 1;
  if (nargout == 2)
    [temp, conds(too_few_neighbors)] = S2F.eval(v.subSet(too_few_neighbors), varargin{:});
  else
    temp = S2F.eval(v.subSet(too_few_neighbors), varargin{:});
  end
  vals(too_few_neighbors,:) = reshape(temp, sum(too_few_neighbors), numel(S2F));

  S2F.delta = delta_original;
  S2F.oF = oF_original;

  if (sum(too_few_neighbors) == N)
    return;
  end
end

% for points with too many neighbors, we choose only the S2F.dim * S2F.oF_max nearest ones
too_many_neighbors = nn > S2F.dim * S2F.oF;
if (sum(too_many_neighbors) > 0)
  warning(['Some centers did have too many neighbors. ' ...
    'In this case only the %d nearest neighbors have been used.'], ...
        S2F.dim * S2F.oF_max);

  % evaluate the critical nodes via knn-search instead of rangesearch
  delta_original = S2F.delta;
  oF_original = S2F.oF;
  % for S2F.nn = S2F.dim, the expectation of the lebesgue constant is infinite
  S2F.delta = 0;
  S2F.oF = S2F.oF_max;
  if (nargout == 2)
    [temp, conds(too_many_neighbors)] = S2F.eval(v.subSet(too_many_neighbors), varargin{:});
  else
    temp = S2F.eval(v.subSet(too_many_neighbors), varargin{:});
  end
  vals(too_many_neighbors,:) = reshape(temp, sum(too_many_neighbors), numel(S2F));

  S2F.delta = delta_original;
  S2F.oF = oF_original;

  if (sum(too_many_neighbors | too_few_neighbors) == N)
    return;
  end
end


% continue with the points that have neither too few nor many neighbors
J = ~(too_few_neighbors | too_many_neighbors);
J_idx = find(J);
v = v.subSet(J);
N = sum(J);
[ind, dist] = S2F.nodes.find(v, S2F.delta, varargin{:});


% if optimal subsampling is set to true, we can now fall back to the eval_knn case 
%   where all neighborhoods have the same size (the dim of the ansatz space) 
if (S2F.subsample == true && S2F.stableFind == false)
  ind = S2F.find_optimal_subset(ind, v, varargin{:});
end


% treat bad nodes separately, but only if the stablefind-option is true
iscvx = S2F.checkConvexity(v, ind);
if (S2F.stableFind && sum(iscvx) < N)
  [valstmp, conds(J_idx(~iscvx))] = eval_stable(S2F, v.subSet(~iscvx), ...
    varargin{:}, S2F.stableFindOptions{:});
  vals(J_idx(~iscvx),:) = reshape(valstmp, sum(~iscvx), numel(S2F));
  clear valstmp;

  % restrict varibales to their new domain (where iscvx is true)
  N = sum(iscvx);
  v = v.subSet(iscvx);
  ind = ind(iscvx, :);
  dist = dist(iscvx, :);
else
  iscvx = true(N, 1);
end


[grid_id, v_id] = find(ind');
nn = sum(ind, 2);
nn_total = sum(nn);
clear ind;


if (S2F.subsample == true && S2F.stableFind == false)
  dist = angle(v.subSet(v_id), S2F.nodes.subSet(grid_id));
  dist = sparse(v_id, grid_id, dist, N, numel(S2F.nodes));
end


% compute for every center from v the matrix of all basis functions evaluated at
%   all neighbors of this center 
% evaluate the basis functions on the nodes
if (~S2F.centered)
  % choose faster way between computing all values and reusing them or
  % computing values on fibgrid(grid_id)
  if nn_total > numel(S2F.nodes.x)
    basis_on_grid = eval_basis_functions(S2F);
    G = basis_on_grid(grid_id, :).';
  else
    G = eval_basis_functions(S2F, S2F.nodes(grid_id)).';
  end

  % odd basis functions may clash with antipodal option, since (-v) = -p(v)
  % thus make sure to use the representer which is closer to the center
  if (mod(S2F.degree, 2) > 0)
    I = sum(v.subSet(v_id).xyz .* S2F.nodes.subSet(grid_id).xyz, 2) < 0;
    G(:,I) = G(:,I) * (-1);
    clear I;
  end

  basis_in_v = eval_basis_functions(S2F, v);
else
  % compute the rotations that shift each element of v into the north pole
  rot = rotation.map(v, vector3d.Z);
  rot = rot(v_id);
  rotneighbors = rot .* S2F.nodes(grid_id);

  % determine which basis to use and evaluate it on the grid and on v
  basis_on_grid = eval_basis_functions(S2F, rotneighbors);
  clear rotneighbors;
  G = basis_on_grid.';

  basis_in_pole = eval_basis_functions(S2F, vector3d.Z);
  basis_in_v = repmat(basis_in_pole, N, 1);
end
G = G.';

% dont solve the normal equations G'WGc = G'Wf (like cond(G)^2)
% rather let matlab directly find min norm solution of sqrt(W) * (Gc-f)
% internally this uses QR and we end up with only cond(G)

% compute the weights
% dist(find(ind)) instead of nonzeros(dist), since elements of v might be
%   contained in S2F.nodes ==> distance 0, but in neighborhood
I = sub2ind(size(dist), v_id, grid_id);
weights = S2F.w(dist(I) / S2F.delta);
clear dist I;

if (S2F.detectOutliers == true)
  oI = computeOutlierIndicators(S2F);
  oI_factor = exp(-oI(grid_id));
  weights = weights .* oI_factor;
  clear oI oI_factor;
end

% set up right hand side
grid_vals = reshape(S2F.values(:), numel(S2F.nodes), numel(S2F));
f = grid_vals(grid_id,:);

if S2F.regularize
  [c_book, conds(J_idx(iscvx))]  = solve_lsq_book_varsize(weights, G, f, nn, ...
    'regularize', S2F.regularizationOptions{:}, varargin{:});
else
  [c_book, conds(J_idx(iscvx))]  = solve_lsq_book_varsize(weights, G, f, nn, varargin{:});
end

vals(J_idx(iscvx),:) = permute(sum(basis_in_v .* permute(c_book, [3 1 2]), 2), [1 3 2]);

if isalmostreal(S2F.values)
  vals = real(vals); 
end

end
