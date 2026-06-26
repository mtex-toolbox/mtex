function [vals, conds] = eval_knn(S2F, v, varargin)

% get parameters
v = v(:);
N = numel(v);
nn = S2F.nn * 2;
nn_total = nn * N;

% Find neighbors and perform subsampling. If the flag is set, compute distances.
[ind, dist] = S2F.nodes.find(v, nn, varargin{:}, 'searcher', S2F.searcher);
if (S2F.subsample == true && S2F.stableFind == false)
  ind = S2F.find_optimal_subset(ind, v, varargin{:});
  nn_total = N * S2F.dim;
  nn = S2F.dim;
end

% id of the neighbors (in the grid of S2F)
grid_id = reshape(ind', nn_total, 1);
% id of entry of v (where we want to eval S2F)
v_id = reshape(repmat((1:N), nn, 1), nn_total, 1);

if (S2F.subsample == true)
  dist = angle(v.subSet(v_id), S2F.nodes.subSet(grid_id));
  dist = reshape(dist, S2F.dim, N)';
end


% evaluate the basis functions on the nodes
if (~S2F.centered)
  % choose faster way between computing all values and reusing them or
  %   computing values on S2F.nodes(grid_id)
  if nn_total > numel(S2F.nodes.x)
    basis_on_grid = eval_basis_functions(S2F); 
    G = basis_on_grid(grid_id, :).';
  else
    G = eval_basis_functions(S2F, S2F.nodes(grid_id)).';
  end

  % odd basis functions may clash with antipodal option, since p(-v) = -p(v),
  %   but v and -v are in the same equivalence class
  % thus make sure to use the representer which is closer to the center 
  %   (on the same hemisphere)
  if (S2F.antipodal && (mod(S2F.degree, 2) == 1))
    I = sum(v.subSet(v_id).xyz .* S2F.nodes.subSet(grid_id).xyz, 2) < 0;
    G(:,I) = G(:,I) * (-1);
  end

  g_book = reshape(eval_basis_functions(S2F, v).', S2F.dim, 1, N);
else
  % compute the rotations that shift each element of v into the north pole
  rot = rotation.map(v, vector3d.Z);
  rot = rot(v_id);
  rotneighbors = rot .* S2F.nodes(grid_id);
  basis_on_grid = eval_basis_functions(S2F, rotneighbors);
  G = basis_on_grid.';
  
  % ensure correct representer for antipodal S2F with odd degree (same as above)
  if (S2F.antipodal && (mod(S2F.degree, 2) == 1))
    I = sum(v.subSet(v_id).xyz .* S2F.nodes.subSet(grid_id).xyz, 2) < 0;
    G(:,I) = G(:,I) * (-1);
  end

  basis_in_pole = eval_basis_functions(S2F, vector3d.Z);
  g_book = repmat(basis_in_pole.', 1, 1, N);
end 
G_book = pagetranspose(reshape(G, S2F.dim, nn, N));
clear G v_id;

% compute distances and weights
if S2F.use_smooth_delta
  [deltas, nn_smooth] = getSmoothDelta(S2F.nodes, v, S2F.nn);
  if (min(nn_smooth) < S2F.dim)
    warning('Some nodes did not have sufficiently many neighbors.');
  end
else
  deltas = 1.05 * max(dist, [], 2);
end

weights = S2F.w(dist ./ deltas);
vor_weights = S2F.vor_weights(grid_id);
vor_weights = reshape(vor_weights, size(weights'))';
% normalization at the end keeps mean of weights at 1
weights = weights .* vor_weights * 4*pi / numel(S2F.nodes);
clear deltas dist vor_weights;
if (S2F.detectOutliers == true)
  oI = computeOutlierIndicators(S2F);
  oI = reshape(oI(grid_id), nn, N)';
  weights = weights .* exp(-oI);
  clear oI;
end

% normalize the maximum weight to be 1
W_book = permute(weights, [2, 3, 1]);
clear weights;

% set up right hand side
grid_vals = reshape(S2F.values(:), numel(S2F.nodes), numel(S2F));
f_book = permute(reshape(grid_vals(grid_id,:), nn, N, numel(S2F)), [1, 3, 2]);
clear grid_id grid_vals;

% solve the systems and evaluate
if S2F.regularize
  [c_book, conds] = solve_lsq_book_constsize(W_book, G_book, f_book, ...
    'regularize', 'maxcond', S2F.maxcond, 'mincond', S2F.mincond, ...
    'basis_weights', S2F.basis_weights, varargin{:});
else
  [c_book, conds] = solve_lsq_book_constsize(W_book, G_book, f_book, ...
    varargin{:});
end
clear f_book G_book W_book;

vals = permute(sum(c_book .* g_book, 1), [3, 2, 1]);

if isalmostreal(S2F.values)
  vals = real(vals);
end

end


function [delta, nn] = getSmoothDelta(v, w, n)

  n2 = ceil(1.5 * n);

  fg = fibonacciS2Grid(10000);
  [~, dn] = v.find(fg, n2);
  dn = dn(:,end);

  mls = S2FunMLS(fg, dn, 'regularize', false);
  mls.degree = 1;
  mls.oF = 2;
  mls.w = @(t)(mls.w(t).^4);
  mls.delta = mls.compute_delta;

  delta = mls.eval(w);

  if (nargout > 1)
    [~, dist] = v.find(w, 2*n);
    isin = dist < delta;
    nn = sum(isin, 2);
  end
end 