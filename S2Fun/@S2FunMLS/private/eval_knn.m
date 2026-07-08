function [vals, conds, info] = eval_knn(S2F, v, varargin)

% get parameters
v = v(:);
N = numel(v);
want_info = nargout > 2;

% if delta should be smooth, we first draw more neighbors than necessary. 
%   (some of the weights will turn out to be zero after computing delta(x))
nn = S2F.nn * (1 + S2F.use_smooth_delta);
nn_total = nn * N;

% decide whether the local geometry score is needed
computeGeometryScore = S2F.centered && ...
  (want_info || (S2F.regularize && ~isempty(S2F.lambda_geom_rel) && (S2F.lambda_geom_rel ~= 0)));

% Find neighbors and perform subsampling. If the flag is set, compute distances.
[ind, dist] = S2F.nodes.find(v, nn, varargin{:});
if (S2F.subsample == true && S2F.stableFind == false)
  ind = S2F.find_optimal_subset(ind, v, varargin{:});
  nn_total = N * S2F.dim;
  nn = S2F.dim;
end

% id of the neighbors (in the grid of S2F)
grid_id = reshape(ind', nn_total, 1);

% id of entry of v (where we want to eval S2F)
v_id = repelem((1:N)', nn);

if (S2F.subsample == true)
  dist = angle(v.subSet(v_id), S2F.nodes.subSet(grid_id));
  dist = reshape(dist, S2F.dim, N)';
end


% evaluate the basis functions on the nodes
if (~S2F.centered)
  % choose faster way between computing all values and reusing them or
  %   computing values on S2F.nodes(grid_id)
  if nn_total > numel(S2F.nodes.x)
    G = eval_basis_functions(S2F); 
    G = G(grid_id, :).';
  else
    G = eval_basis_functions(S2F, S2F.nodes(grid_id)).';
  end

  % odd basis functions may clash with antipodal option, since p(-v) = -p(v),
  %   but v and -v are in the same equivalence class
  % thus make sure to use the representer which is closer to the center 
  %   (on the same hemisphere)
  if (S2F.antipodal && (mod(S2F.degree, 2) == 1))
    I = sum(v.subSet(v_id).xyz .* S2F.nodes.subSet(grid_id).xyz, 2) < 0;
    G(:,I) = -G(:,I);
  end

  g_book = reshape(eval_basis_functions(S2F, v).', S2F.dim, 1, N);
else
  % compute the rotations that shift each element of v into the north pole
  [xloc, yloc, zloc] = local_coordinates_S2(v, v_id, S2F.nodes, grid_id);

  G = eval_basis_functions(S2F, vector3d(xloc, yloc, zloc));
  G = permute(G, [2,1]);
  
  % ensure correct representer for antipodal S2F with odd degree (same as above)
  % since rot maps the center to the north pole, this can be checked by z < 0
  if (S2F.antipodal && (mod(S2F.degree, 2) == 1))
    I = zloc < 0;
    G(:,I) = -G(:,I);
    clear I;
  end

  % keep local tangent coordinates if they are needed for geometry regularization
  if computeGeometryScore
    xloc = reshape(xloc, [nn, N]);
    yloc = reshape(yloc, [nn, N]);
    clear zloc;
  else
    clear xloc yloc zloc;
  end

  % the evaluation point is always the north pole in local coordinates
  % no need to replicate this over all pages
  basis_in_pole = eval_basis_functions(S2F, vector3d.Z);
  g_book = basis_in_pole.';
end 

G_book = permute(reshape(G, S2F.dim, nn, N), [2, 1, 3]);
clear G v_id;

% compute distances and weights, or get the precomputed smoothDelta-values
if S2F.use_smooth_delta
  deltas = get_option(varargin, 'smoothDelta');
else
  deltas = 1.05 * max(dist, [], 2);
end

weights = S2F.w(dist ./ deltas);
vor_weights = S2F.vor_weights(grid_id);
vor_weights = reshape(vor_weights, nn, N)';
weights = weights .* vor_weights * 4*pi / numel(S2F.nodes);
clear deltas dist vor_weights;

if (S2F.detectOutliers == true)
  oI = reshape(S2F.outlierIndicators(grid_id), nn, N)';
  weights = weights .* exp(-oI);
  clear oI;
end

% put weights into book format
W_book = permute(weights, [2, 3, 1]);
W_book = max(real(W_book), 0);
clear weights;

% if smooth delta is used, check if we get a neighborhood-warning
if S2F.use_smooth_delta
  nn_smooth = sum(W_book > 0, 1);
  if (min(nn_smooth) < S2F.dim)
    warning(['Due to smoothing the support radius, ' ...
      'some centers did not have sufficiently many neighbors']);
  end
end

% compute geometry scores, if they are needed for the regularization or info
if computeGeometryScore
  geometryScore = local_geometry_score(xloc, yloc, W_book);
  clear xloc yloc;
end

% set up right hand side
grid_vals = reshape(S2F.values(:), numel(S2F.nodes), numel(S2F));
f_book = permute(reshape(grid_vals(grid_id,:), nn, N, numel(S2F)), [1, 3, 2]);
clear grid_id grid_vals;

% solve the systems and evaluate
if S2F.regularize
  solve_args = {'regularize', ...
    'maxcond', S2F.maxcond, 'mincond', S2F.mincond, ...
    'basis_weights', S2F.basis_weights, ...
    'basis_weights_scale', S2F.basis_weights_scale, ...
    'lambda_geom_rel', S2F.lambda_geom_rel};
else
  solve_args = {};
end

if computeGeometryScore
  solve_args = [solve_args, {'geometryScore', geometryScore}];
  clear geometryScore;
end

solve_args = [solve_args, varargin];

% only request the outputs that are actually needed
if nargout <= 1
  c_book = solve_lsq_book_constsize(W_book, G_book, f_book, solve_args{:});
elseif nargout == 2
  [c_book, conds] = solve_lsq_book_constsize(W_book, G_book, f_book, solve_args{:});
else
  [c_book, conds, info] = solve_lsq_book_constsize(W_book, G_book, f_book, solve_args{:});
end
clear f_book G_book W_book solve_args;

vals = permute(sum(c_book .* g_book, 1), [3, 2, 1]);

if isalmostreal(S2F.values)
  vals = real(vals);
end

end