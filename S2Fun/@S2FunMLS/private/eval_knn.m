function [vals, conds] = eval_knn(sF, v, varargin)

% get parameters
dimensions = size(v);
v = v(:);
N = numel(v);
nn = sF.nn;
nn_total = nn * N;

% if the oversampling factor is <=1, set it to 2
if (sF.nn <= sF.dim)
  sF.nn = 2 * sF.dim;
  warning(sprintf(...
    ['The specified number of neighbors nn was less than the dimension dim.\n\t ' ...
    'nn has been set to 2 * dim.']));
end

% Find neighbors and perform subsampling. If the flag is set, compute distances.
[ind, dist] = sF.nodes.find(v, nn, varargin{:}); 
if (sF.subsample == true)
  ind = sF.find_optimal_subset(ind, v, varargin{:});
  nn_total = N * sF.dim;
  nn = sF.dim;
end

% id of the neighbors (in the grid of sF)
grid_id = reshape(ind', nn_total, 1);
% id of entry of v (where we want to eval sF)
v_id = reshape(repmat((1:N), nn, 1), nn_total, 1);
if (sF.subsample == true)
  dist = angle(v.subSet(v_id), sF.nodes.subSet(grid_id));
  dist = reshape(dist, sF.dim, N)';
end


% evaluate the basis functions on the nodes
if (~sF.centered)
  % choose faster way between computing all values and reusing them or
  % computing values on sF.nodes(grid_id)
  if nn_total > numel(sF.nodes.x)
    basis_on_grid = eval_basis_functions(sF); 
    G = basis_on_grid(grid_id, :).';
  else
    G = eval_basis_functions(sF, sF.nodes(grid_id)).';
  end
  
  % odd basis functions may clash with antipodal option, since p(-v) = -p(v),
  %   but v and -v are in the same equivalence class
  % thus make sure to use the representer which is closer to the center 
  %   (on the same hemisphere)
  if (mod(sF.degree, 2) == 1)
    I = sum(v.subSet(v_id).xyz .* sF.nodes.subSet(grid_id).xyz, 2) < 0;
    G(:,I) = G(:,I) * (-1);
  end

  g_book = reshape(eval_basis_functions(sF, v).', sF.dim, 1, N);
else
  % compute the rotations that shift each element of v into the north pole
  rot = rotation.map(v, vector3d.Z);
  rot = rot(v_id);
  rotneighbors = rot .* sF.nodes(grid_id);

  basis_on_grid = eval_basis_functions(sF, rotneighbors);
  basis_in_pole = eval_basis_functions(sF, vector3d.Z);

  g_book = repmat(basis_in_pole', 1, 1, N);
  G = basis_on_grid.';
end 
G_book = pagetranspose(reshape(G, sF.dim, nn, N));


% don't solve the normal equations G'WGc = G'Wf (like cond(G)^2)
% rather let matlab directly find min norm solution of sqrt(W) * (Gc-f)
% internally this uses QR and we end up with only cond(G), without the square!

% compute distances and weights
deltas = 1.1 * max(dist, [], 2);
weights = sF.w(dist ./ deltas);
if (sF.detectOutliers == true)
  oI = computeOutlierIndicators(sF);
  oI = reshape(oI(grid_id), nn, N)';
  weights = weights .* exp(-oI);
end
weights = weights ./ sum(weights, 2);
W_book = sqrt(reshape(weights', nn, 1, N));

% compute scaling factors (norms of columns of G_times_W_book)
B_book = G_book .* W_book;
S_book = sqrt(sum(abs(B_book).^2, 1));

% set up right hand side
f_book = pagetranspose(reshape(sF.values(grid_id,:).', numel(sF), nn, N));
fw_book = W_book .* f_book;

% solve the rescaled system and evaluate MLS
c_book = pagemldivide(B_book ./ S_book, fw_book) ./ pagetranspose(S_book);
vals = sum(c_book .* g_book, 1);

% for the eval-function we need output of size (numel(v) x numel(sF))
if isscalar(sF)
  vals = reshape(vals, dimensions);
else 
  % currently vals is (1 x numel(sF) x numel(v))
  vals = permute(vals, [3, 2, 1]);
end

if isalmostreal(sF.values)
  vals = real(vals);
end

if nargout == 2
  eigs = pagesvd(B_book ./ S_book);
  conds = eigs(1,:,:) ./ eigs(sF.dim,:,:);
  conds = conds(:);
  conds = reshape(conds, dimensions);
end

end
