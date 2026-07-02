function [vals, conds, warn_smallnn, warn_bignn, info] = eval_range(S2F, v, varargin)

% get parameters
v = v(:);
N = numel(v);
numf = numel(S2F);
vals = zeros(N, numf);
want_info = nargout > 4;

if nargout >= 2
  conds = zeros(N, 1);
end
if want_info
  info = initRegInfo(N);
end
 
% get the neighbors 
[ind, dist] = S2F.nodes.find(v, S2F.delta);
nn = full(sum(ind, 2));

warn_smallnn = false;
warn_bignn = false;

% for points with too few neighbors, we instead choose the S2F.dim nearest ones
% NOTE: the expectation of the lebesgue constant is infinite in this setting
too_few_neighbors = nn <= S2F.dim;
n_few = nnz(too_few_neighbors);

if (n_few > 0)
  warn_smallnn = true;

  % evaluate the critical nodes via knn-search instead of rangesearch
  delta_original = S2F.delta;
  oF_original = S2F.oF;

  % for S2F.nn = S2F.dim, the expectation of the lebesgue constant is infinite
  S2F.delta = 0;
  S2F.oF = 1;

  if want_info
    [temp, conds(too_few_neighbors), info_batch] = ...
      S2F.eval(v.subSet(too_few_neighbors), varargin{:});
    info = insertRegInfo(info, too_few_neighbors, info_batch);
  elseif nargout >= 2
    [temp, conds(too_few_neighbors)] = ...
      S2F.eval(v.subSet(too_few_neighbors), varargin{:});
  else
    temp = S2F.eval(v.subSet(too_few_neighbors), varargin{:});
  end

  vals(too_few_neighbors,:) = reshape(temp, n_few, numf);

  S2F.oF = oF_original;
  S2F.delta = delta_original;

  if (n_few == N)
    return;
  end
end

% for points with too many neighbors, we choose only the S2F.dim * S2F.oF_max nearest ones
too_many_neighbors = nn > S2F.dim * S2F.oF_max;
n_big = nnz(too_many_neighbors);

if (n_big > 0)
  warn_bignn = true;

  % evaluate the critical nodes via knn-search instead of rangesearch
  delta_original = S2F.delta;
  oF_original = S2F.oF;

  % for S2F.nn = S2F.dim, the expectation of the lebesgue constant is infinite
  S2F.delta = 0;
  S2F.oF = S2F.oF_max;

  if want_info
    [temp, conds(too_many_neighbors), info_batch] = ...
      S2F.eval(v.subSet(too_many_neighbors), varargin{:});
    info = insertRegInfo(info, too_many_neighbors, info_batch);
  elseif nargout >= 2
    [temp, conds(too_many_neighbors)] = ...
      S2F.eval(v.subSet(too_many_neighbors), varargin{:});
  else
    temp = S2F.eval(v.subSet(too_many_neighbors), varargin{:});
  end

  vals(too_many_neighbors,:) = reshape(temp, n_big, numf);

  S2F.oF = oF_original;
  S2F.delta = delta_original;

  if (n_few + n_big == N)
    return;
  end
end


% continue with the points that have neither too few nor many neighbors
J = ~(too_few_neighbors | too_many_neighbors);
J_idx = find(J);

v = v.subSet(J);
N = nnz(J);

ind = ind(J,:);
dist = dist(J,:);

% decide whether the local geometry score is needed
computeGeometryScore = S2F.centered && ...
  (want_info || (S2F.regularize && ~isempty(S2F.lambda_geom_rel) && (S2F.lambda_geom_rel ~= 0)));


% if optimal subsampling is set to true, we can now fall back to the eval_knn case 
%   where all neighborhoods have the same size (the dim of the ansatz space) 
if S2F.subsample
  ind = S2F.find_optimal_subset(ind, v, varargin{:});
end

[grid_id, v_id] = find(ind');
nn = full(sum(ind, 2));
clear ind;

if S2F.subsample
  dist = angle(v.subSet(v_id), S2F.nodes.subSet(grid_id));
  dist = sparse(v_id, grid_id, dist, N, numel(S2F.nodes));
end

nn_total = numel(grid_id);


% compute for every center from v the matrix of all basis functions evaluated at
%   all neighbors of this center 
% evaluate the basis functions on the nodes
if (~S2F.centered)

  % choose faster way between computing all values and reusing them or
  % computing values on fibgrid(grid_id)
  if nn_total > numel(S2F.nodes.x)
    basis_on_grid = eval_basis_functions(S2F);
    G = basis_on_grid(grid_id, :);
    clear basis_on_grid;
  else
    G = eval_basis_functions(S2F, S2F.nodes(grid_id));
  end

  % odd basis functions may clash with antipodal option, since (-v) = -p(v)
  % thus make sure to use the representer which is closer to the center
  if (mod(S2F.degree, 2) > 0)
    I = sum(v.subSet(v_id).xyz .* S2F.nodes.subSet(grid_id).xyz, 2) < 0;
    G(I,:) = -G(I,:);
    clear I;
  end

  basis_in_v = eval_basis_functions(S2F, v);

else

  % compute the rotations that shift each element of v into the north pole
  rot = rotation.map(v, vector3d.Z);
  rot = rot(v_id);

  % TODO: project to fundamental region?
  rotneighbors = rot .* S2F.nodes(grid_id);
  clear rot;

  % determine which basis to use and evaluate it on the grid and on v
  G = eval_basis_functions(S2F, rotneighbors);

  % ensure correct representer for antipodal S2F with odd degree (same as above)
  % since rot maps the center to the north pole, this can be checked by z < 0
  if (S2F.antipodal && (mod(S2F.degree, 2) == 1))
    I = rotneighbors.z < 0;
    G(I,:) = -G(I,:);
    clear I;
  end

  % store local tangent coordinates if they are needed for geometry regularization
  if computeGeometryScore
    xloc = rotneighbors.x;
    yloc = rotneighbors.y;
  end
  clear rotneighbors;

  % the evaluation point is always the north pole in local coordinates
  % no need to replicate this over all rows
  basis_in_pole = eval_basis_functions(S2F, vector3d.Z);
  basis_in_v = basis_in_pole;

end


% compute the weights
% dist(find(ind)) instead of nonzeros(dist), since elements of v might be
%   contained in S2F.nodes ==> distance 0, but in neighborhood
I = sub2ind(size(dist), v_id, grid_id);
weights = S2F.w(dist(I) / S2F.delta);

vor_weights = S2F.vor_weights(grid_id);

% normalization at the end keeps mean of weights at 1
weights = weights .* vor_weights * 4*pi / numel(S2F.nodes);
clear dist I vor_weights;

if (S2F.detectOutliers == true)
  oI = computeOutlierIndicators(S2F);
  weights = weights .* exp(-oI(grid_id));
  clear oI;
end

% compute geometry scores, if they are needed for the regularization or info
if computeGeometryScore
  geometryScore = localGeometryScore(xloc, yloc, weights, nn);
  clear xloc yloc;
end

% set up right hand side
grid_vals = reshape(S2F.values(:), numel(S2F.nodes), numf);
f = grid_vals(grid_id,:);
clear grid_id grid_vals;


% solve the systems
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
vals(J_idx,:) = permute(sum(basis_in_v .* permute(c_book, [3 1 2]), 2), [1 3 2]);

if isalmostreal(S2F.values)
  vals = real(vals); 
end

end


% ======================
% Local helper functions
% ======================

% local geometric badness of the weighted tangent node cloud
% all inputs are expected to be ordered according to sizes
% xloc and yloc are essentialy the coordinates w.r.t. the local tangent space
function geometryScore = localGeometryScore(xloc, yloc, weights, sizes)
  beta = 2;

  N = numel(sizes);
  system_id = repelem((1:N)', sizes);

  % compute 'total weight' of each neighborhood
  Wsum = accumarray(system_id, weights, [N, 1], @sum, 0);
  Wsum = max(Wsum, realmin);

  % normalize weights in each neighborhood
  omega = weights ./ Wsum(system_id);

  % weight local tangent coordinates once and reuse them
  wx = omega .* xloc;
  wy = omega .* yloc;

  % compute weighted center 
  mux = accumarray(system_id, wx, [N, 1], @sum, 0);
  muy = accumarray(system_id, wy, [N, 1], @sum, 0);

  % compute weighted second moments 
  M11 = accumarray(system_id, wx .* xloc, [N, 1], @sum, 0);
  M12 = accumarray(system_id, wx .* yloc, [N, 1], @sum, 0);
  M22 = accumarray(system_id, wy .* yloc, [N, 1], @sum, 0);

  % compute trace and determinant of the local moment matrix M 
  trM  = M11 + M22;
  detM = M11 .* M22 - M12.^2;

  % measure how two-dimensional the local neighborhood is
  % iso is close to 1 for isotropic neighborhoods and close to 0 for line-like ones
  iso = 4 .* detM ./ max(trM.^2, realmin);
  iso = min(max(real(iso), 0), 1);

  % measure how much the local neighborhood is shifted away from the center
  % balance is small for centered neighborhoods and large for one-sided ones
  balance = sqrt(mux.^2 + muy.^2) ./ sqrt(max(trM, realmin));

  % combine isotropy and balance into one local geometry quality
  % quality is close to 1 for good neighborhoods and close to 0 for bad ones
  quality = iso .* exp(-beta .* balance.^2);
  quality = min(max(real(quality), 0), 1);

  % convert quality into a score
  % geometryScore is close to 0 for good neighborhoods and close to 1 for bad ones
  geometryScore = (1 - quality).^2;
  geometryScore = geometryScore(:);
end

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
