function [vals, conds, warn_smallnn, warn_bignn, info] = eval_range(SO3F, ori, varargin)

% get parameters
ori = ori(:);
N = numel(ori);
numf = numel(SO3F);
vals = zeros(N, numf);
want_info = nargout > 4;

if nargout >= 2
  conds = zeros(N, 1);
end
if want_info
  info = initRegInfo(N);
end

% get the neighbors
[ind, dist] = SO3F.nodes.find(ori, SO3F.delta, 'searcher', SO3F.searcher);
nn = full(sum(ind, 2));

warn_smallnn = false;
warn_bignn = false;

% for points with too few neighbors, we instead choose the SO3F.dim nearest ones
% NOTE: the expectation of the lebesgue constant is infinite in this setting
too_few_neighbors = nn <= SO3F.dim;
n_few = nnz(too_few_neighbors);

if (n_few > 0)
  warn_smallnn = true;

  % evaluate the critical nodes via knn-search instead of rangesearch
  delta_original = SO3F.delta;
  oF_original = SO3F.oF;

  % for SO3F.nn = SO3F.dim, the expectation of the lebesgue constant is infinite
  SO3F.delta = 0;
  SO3F.oF = 1;

  if want_info
    [temp, conds(too_few_neighbors), info_batch] = ...
      SO3F.eval(ori.subSet(too_few_neighbors), varargin{:});
    info = insertRegInfo(info, too_few_neighbors, info_batch);
  elseif nargout >= 2
    [temp, conds(too_few_neighbors)] = ...
      SO3F.eval(ori.subSet(too_few_neighbors), varargin{:});
  else
    temp = SO3F.eval(ori.subSet(too_few_neighbors), varargin{:});
  end

  vals(too_few_neighbors,:) = reshape(temp, n_few, numf);

  SO3F.oF = oF_original;
  SO3F.delta = delta_original;

  if (n_few == N)
    return;
  end
end

% for points with too many neighbors, we choose only the SO3F.dim * SO3F.oF_max nearest ones
too_many_neighbors = nn > SO3F.dim * SO3F.oF_max;
n_big = nnz(too_many_neighbors);

if (n_big > 0)
  warn_bignn = true;

  % evaluate the critical nodes via knn-search instead of rangesearch
  delta_original = SO3F.delta;
  oF_original = SO3F.oF;

  % for SO3F.nn = SO3F.dim, the expectation of the lebesgue constant is infinite
  SO3F.delta = 0;
  SO3F.oF = SO3F.oF_max;

  if want_info
    [temp, conds(too_many_neighbors), info_batch] = ...
      SO3F.eval(ori.subSet(too_many_neighbors), varargin{:});
    info = insertRegInfo(info, too_many_neighbors, info_batch);
  elseif nargout >= 2
    [temp, conds(too_many_neighbors)] = ...
      SO3F.eval(ori.subSet(too_many_neighbors), varargin{:});
  else
    temp = SO3F.eval(ori.subSet(too_many_neighbors), varargin{:});
  end

  vals(too_many_neighbors,:) = reshape(temp, n_big, numf);

  SO3F.oF = oF_original;
  SO3F.delta = delta_original;

  if (n_few + n_big == N)
    return;
  end
end


% continue with the points that have neither too few nor many neighbors
J = ~(too_few_neighbors | too_many_neighbors);
J_idx = find(J);

ori = ori.subSet(J);
N = nnz(J);

ind = ind(J,:);
dist = dist(J,:);

% decide whether the local geometry score is needed
computeGeometryScore = SO3F.centered && ...
  (want_info || (SO3F.regularize && ~isempty(SO3F.lambda_geom_rel) && (SO3F.lambda_geom_rel ~= 0)));


% if optimal subsampling is set to true, we can now fall back to the eval_knn case
%   where all neighborhoods have the same size (the dim of the ansatz space)
if SO3F.subsample
  ind = SO3F.find_optimal_subset(ind, ori, varargin{:});
end

[grid_id, ori_id] = find(ind');
nn = full(sum(ind, 2));
clear ind;

if SO3F.subsample
  dist = angle(ori.subSet(ori_id), SO3F.nodes.subSet(grid_id));
  dist = sparse(ori_id, grid_id, dist, N, numel(SO3F.nodes));
end

nn_total = numel(grid_id);


% compute for every center from ori the matrix of all basis functions evaluated at
%   all neighbors of this center
% evaluate the basis functions on the nodes
if (~SO3F.centered)

  if ((SO3F.CS.id == 1) && (nn_total > numel(SO3F.nodes)))
    % choose faster way between computing all values and reusing them or
    % computing values on SO3F.nodes(grid_id)
    basis_on_grid = eval_basis_functions(SO3F);
    G = basis_on_grid(grid_id, :);
    clear basis_on_grid;

    % odd basis functions may clash with antipodal option, since p(-ori) = -p(ori)
    % thus make sure to use the representer which is closer to the center
    if (SO3F.antipodal && (mod(SO3F.degree, 2) == 1))
      I = sum(ori.subSet(ori_id).abcd .* SO3F.nodes.subSet(grid_id).abcd, 2) < 0;
      G(I,:) = -G(I,:);
      clear I;
    end
  else
    % projecting to fR is very important, since later we treat all oris as
    % points on the sphere S^3 and use monomials
    projected = project2FundamentalRegion(SO3F.nodes(grid_id), ori(ori_id));
    G = eval_basis_functions(SO3F, projected);
    clear projected;
  end

  basis_in_ori = eval_basis_functions(SO3F, ori);

else

  % compute the rotations that shift each element of ori into the identity
  [aloc, bloc, cloc, dloc, rotneighbors] = ...
    local_coordinates_SO3(ori, ori_id, SO3F.nodes, grid_id);

  % determine which basis to use and evaluate it on the grid and on ori
  G = eval_basis_functions(SO3F, rotneighbors);
  clear rotneighbors;

  % ensure correct representer for antipodal SO3F with odd degree
  % since rot maps the center to the identity, this can be checked by a < 0
  if (SO3F.antipodal && (mod(SO3F.degree, 2) == 1))
    I = aloc < 0;
    G(I,:) = -G(I,:);
    clear I;
  end

  % keep local tangent coordinates if they are needed for geometry regularization
  if computeGeometryScore
    clear aloc;
  else
    clear aloc bloc cloc dloc;
  end

  % the evaluation point is always the identity in local coordinates
  % no need to replicate this over all rows
  basis_in_pole = eval_basis_functions(SO3F, orientation.id);
  basis_in_ori = basis_in_pole;
end


% compute the weights
% dist(find(ind)) instead of nonzeros(dist), since elements of ori might be
%   contained in SO3F.nodes ==> distance 0, but in neighborhood
I = sub2ind(size(dist), ori_id, grid_id);
weights = SO3F.w(dist(I) ./ SO3F.delta);

vor_weights = SO3F.vor_weights(grid_id);

% normalization at the end keeps mean of weights at 1
weights = weights .* vor_weights * pi^2 / numel(SO3F.nodes);
clear dist I vor_weights;

if (SO3F.detectOutliers == true)
  oI = SO3F.outlierIndicators;
  if isempty(oI), oI = SO3F.compute_outlier_indicators; end
  weights = weights .* exp(-oI(grid_id));
  clear oI;
end

% compute geometry scores, if they are needed for the regularization or info
if computeGeometryScore
  geometryScore = local_geometry_score_SO3(bloc, cloc, dloc, weights, nn);
  clear bloc cloc dloc;
end

% set up right hand side
grid_vals = reshape(SO3F.values(:), numel(SO3F.nodes), numf);
f = grid_vals(grid_id,:);
clear grid_id grid_vals;


% solve the systems
if SO3F.regularize

  solve_args = {'regularize', ...
    'maxcond', SO3F.maxcond, 'mincond', SO3F.mincond, ...
    'basis_weights', SO3F.basis_weights, ...
    'basis_weights_scale', SO3F.basis_weights_scale, ...
    'lambda_geom_rel', SO3F.lambda_geom_rel};
else
  solve_args = {};
end

if computeGeometryScore
  solve_args = [solve_args, {'geometryScore', geometryScore}];
  clear geometryScore;
end

solve_args = [solve_args, varargin];

if want_info
  [c_book, conds(J_idx), info_batch] = ...
    solve_lsq_book_varsize(weights, G, f, nn, solve_args{:});
  info = insertRegInfo(info, J_idx, info_batch);
elseif nargout >= 2
  [c_book, conds(J_idx)] = ...
    solve_lsq_book_varsize(weights, G, f, nn, solve_args{:});
else
  c_book = solve_lsq_book_varsize(weights, G, f, nn, solve_args{:});
end

clear weights G f solve_args;


% evaluate
vals(J_idx,:) = permute(sum(basis_in_ori .* permute(c_book, [3 1 2]), 2), [1 3 2]);

if isalmostreal(SO3F.values)
  vals = real(vals);
end

end


% ======================
% Local helper functions
% ======================

% initialize struct for additional regularization information
function info = initRegInfo(N)
  info = struct;
  info.conds_reg = NaN(N, 1);
  info.conds_unreg = NaN(N, 1);
  info.geometryScore = NaN(N, 1);
  info.maxeig = NaN(N, 1);
  info.mineig = NaN(N, 1);
  info.meanEig = NaN(N, 1);
  info.conds_geom = NaN(N, 1);
  info.lambdaGeom = NaN(N, 1);
  info.lambdaCond = NaN(N, 1);
end

% insert regularization info of one batch into the full info struct
function info = insertRegInfo(info, I, info_batch)
  names = fieldnames(info_batch);
  for k = 1 : numel(names)
    name = names{k};
    if isfield(info, name)
      info.(name)(I,:) = info_batch.(name);
    end
  end
end
