function [vals, conds, info] = eval_knn(SO3F, ori, varargin)

% get parameters
ori = ori(:);
N = numel(ori);
want_info = nargout > 2;

% if delta should be smooth, we first draw more neighbors than necessary.
%   (some of the weights will turn out to be zero after computing delta(x))
nn = SO3F.nn * (1 + SO3F.use_smooth_delta);
nn_total = nn * N;

% decide whether the local geometry score is needed
computeGeometryScore = SO3F.centered && ...
  (want_info || (SO3F.regularize && ~isempty(SO3F.lambda_geom_rel) && (SO3F.lambda_geom_rel ~= 0)));

% Find neighbors and perform subsampling. If the flag is set, compute distances.
[ind, dist] = SO3F.nodes.find(ori, nn, varargin{:}, 'searcher', SO3F.searcher);
if (SO3F.subsample == true)
  ind = SO3F.find_optimal_subset(ind, ori, varargin{:});
  nn_total = N * SO3F.dim;
  nn = SO3F.dim;
end

% id of the neighbors (in the grid of SO3F)
grid_id = reshape(ind', nn_total, 1);

% id of entry of ori (where we want to eval SO3F)
ori_id = repelem((1:N)', nn);

if (SO3F.subsample == true)
  dist = angle(ori.subSet(ori_id), SO3F.nodes.subSet(grid_id));
  dist = reshape(dist, SO3F.dim, N)';
end


% evaluate the basis functions on the nodes
if (~SO3F.centered)
  if ((SO3F.CS.id == 1) && (nn_total > numel(SO3F.nodes)))
    % choose faster way between computing all values and reusing them or
    %   computing values on SO3F.nodes(grid_id)
    G = eval_basis_functions(SO3F);
    G = G(grid_id, :).';

    % odd basis functions may clash with antipodal option, since p(-ori) = -p(ori),
    %   but ori and -ori are in the same equivalence class
    % thus make sure to use the representer which is closer to the center
    if (SO3F.antipodal && (mod(SO3F.degree, 2) == 1))
      I = sum(ori.subSet(ori_id).abcd .* SO3F.nodes.subSet(grid_id).abcd, 2) < 0;
      G(:,I) = -G(:,I);
      clear I;
    end
  else
    % projecting to fR is very important, since later we treat all oris as
    % points on the sphere S^3 and use monomials
    projected = project2FundamentalRegion(SO3F.nodes(grid_id), ori(ori_id));
    G = eval_basis_functions(SO3F, projected).';
    clear projected;
  end

  g_book = reshape(eval_basis_functions(SO3F, ori).', SO3F.dim, 1, N);
else
  % compute the rotations that shift each element of ori into the identity
  [aloc, bloc, cloc, dloc, rotneighbors] = ...
    local_coordinates_SO3(ori, ori_id, SO3F.nodes, grid_id);

  G = eval_basis_functions(SO3F, rotneighbors);
  G = permute(G, [2,1]);
  clear rotneighbors;

  % ensure correct representer for antipodal SO3F with odd degree
  % since rot maps the center to the identity, this can be checked by a < 0
  if (SO3F.antipodal && (mod(SO3F.degree, 2) == 1))
    I = aloc < 0;
    G(:,I) = -G(:,I);
    clear I;
  end

  % keep local tangent coordinates if they are needed for geometry regularization
  if computeGeometryScore
    bloc = reshape(bloc, [nn, N]);
    cloc = reshape(cloc, [nn, N]);
    dloc = reshape(dloc, [nn, N]);
    clear aloc;
  else
    clear aloc bloc cloc dloc;
  end

  % the evaluation point is always the identity in local coordinates
  % no need to replicate this over all pages
  basis_in_pole = eval_basis_functions(SO3F, orientation.id);
  g_book = basis_in_pole.';
end

G_book = permute(reshape(G, SO3F.dim, nn, N), [2, 1, 3]);
clear G ori_id;

% compute distances and weights, or get the precomputed smoothDelta-values
if SO3F.use_smooth_delta
  deltas = real(get_option(varargin, 'smoothDelta'));
  deltas = deltas(:);

  % guarantee at least SO3F.dim positive-weight neighbors locally
  m = min(SO3F.dim, size(dist, 2));
  deltaSafe = 1.05 * dist(:,m);
  adjusted = deltas < deltaSafe;

  if any(adjusted)
    warning('SO3FunMLS:smoothDeltaAdjusted', ...
      ['The smooth support radius was increased at %d of %d evaluation ' ...
       'centers to avoid too small neighborhoods. The effective support ' ...
       'radius is therefore not fully smooth at these centers.'], ...
      nnz(adjusted), N);
  end

  deltas = max(deltas, deltaSafe);
else
  deltas = 1.05 * max(dist, [], 2);
end

deltas = max(deltas, realmin);
weights = SO3F.w(dist ./ deltas);
vor_weights = SO3F.vor_weights(grid_id);
vor_weights = reshape(vor_weights, nn, N)';
weights = weights .* vor_weights * pi^2 / numel(SO3F.nodes);
clear deltas dist vor_weights;

if (SO3F.detectOutliers == true)
  oI = SO3F.outlierIndicators;
  if isempty(oI), oI = SO3F.compute_outlier_indicators; end
  oI = reshape(oI(grid_id), nn, N)';
  weights = weights .* exp(-oI);
  clear oI;
end

% put weights into book format
W_book = permute(weights, [2, 3, 1]);
W_book = max(real(W_book), 0);
clear weights;

% a custom weight function may still vanish inside its nominal support
if SO3F.use_smooth_delta
  nn_smooth = sum(W_book > 0, 1);
  if (min(nn_smooth) < SO3F.dim)
    warning('SO3FunMLS:insufficientWeightedNeighbors', ...
      ['Some centers still have fewer positive-weight neighbors than the ' ...
       'dimension of the ansatz space.']);
  end
end

% compute geometry scores, if they are needed for the regularization or info
if computeGeometryScore
  geometryScore = local_geometry_score_SO3(bloc, cloc, dloc, W_book);
  clear bloc cloc dloc;
end

% set up right hand side
grid_vals = reshape(SO3F.values(:), numel(SO3F.nodes), numel(SO3F));
f_book = permute(reshape(grid_vals(grid_id,:), nn, N, numel(SO3F)), [1, 3, 2]);
clear grid_id grid_vals;

% solve the systems and evaluate
if SO3F.regularize
  solve_args = {'regularize', ...
    'maxcond', SO3F.maxcond, 'mincond', SO3F.mincond, ...
    'basis_weights', SO3F.basis_weights, ...
    'basis_weights_scale', SO3F.basis_weights_scale, ...
    'lambda_geom_rel', SO3F.lambda_geom_rel, ...
    'condition_geometry'};
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

if isalmostreal(SO3F.values)
  vals = real(vals);
end

end
