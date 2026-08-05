function [vals, conds, warn_smallnn, warn_bignn, info] = ...
    eval_range(S2F, v, varargin)

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

% find all nodes in the prescribed support
[ind, dist] = S2F.nodes.find(v, S2F.delta);
nn = full(sum(ind, 2));

warn_smallnn = false;
warn_bignn = false;

% points with too few neighbors are handled by a KNN search
% NOTE: the expected Lebesgue constant is infinite at exact interpolation
too_few_neighbors = nn <= S2F.dim;
n_few = nnz(too_few_neighbors);

if n_few > 0
  warn_smallnn = true;

  if S2F.use_smooth_delta && isempty(S2F.auxgrid)
    S2F = S2F.init_auxgrid;
  end

  delta_original = S2F.delta;
  oF_original = S2F.oF;
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

  if n_few == N
    return;
  end
end

% points with too many neighbors are capped by a KNN search
too_many_neighbors = nn > S2F.dim * S2F.oF_max;
n_big = nnz(too_many_neighbors);

if n_big > 0
  warn_bignn = true;

  if S2F.use_smooth_delta && isempty(S2F.auxgrid)
    S2F = S2F.init_auxgrid;
  end

  delta_original = S2F.delta;
  oF_original = S2F.oF;
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


% continue with neighborhoods of moderate size
J = ~(too_few_neighbors | too_many_neighbors);
J_idx = find(J);

v = v.subSet(J);
N = nnz(J);
ind = ind(J,:);
dist = dist(J,:);

if S2F.subsample
  ind = S2F.find_optimal_subset(ind, v, varargin{:});
end

[grid_id, v_id] = find(ind');
nn = full(sum(ind, 2));
clear ind;

if S2F.subsample
  localDist = angle(v.subSet(v_id), S2F.nodes.subSet(grid_id));
  dist = sparse(v_id, grid_id, localDist, N, numel(S2F.nodes));
end

nn_total = numel(grid_id);


% evaluate the local basis
if ~S2F.centered
  if nn_total > numel(S2F.nodes.x)
    basis_on_grid = eval_basis_functions(S2F);
    G = basis_on_grid(grid_id, :);
    clear basis_on_grid;
  else
    G = eval_basis_functions(S2F, S2F.nodes(grid_id));
  end

  if S2F.antipodal && mod(S2F.degree, 2) == 1
    I = sum(v.subSet(v_id).xyz .* ...
      S2F.nodes.subSet(grid_id).xyz, 2) < 0;
    G(I,:) = -G(I,:);
  end

  basis_in_v = eval_basis_functions(S2F, v);
  eval_vector = permute(basis_in_v, [2, 3, 1]);
else
  [xloc, yloc, zloc] = ...
    local_coordinates_S2(v, v_id, S2F.nodes, grid_id);

  G = eval_basis_functions(S2F, vector3d(xloc, yloc, zloc));

  if S2F.antipodal && mod(S2F.degree, 2) == 1
    I = zloc < 0;
    G(I,:) = -G(I,:);
  end
  clear xloc yloc zloc;

  basis_in_v = eval_basis_functions(S2F, vector3d.Z);
  eval_vector = basis_in_v.';
end


% compute compact local weights
I = sub2ind(size(dist), v_id, grid_id);
weights = S2F.w(dist(I) ./ S2F.delta);
weights = weights .* S2F.vor_weights(grid_id) * 4*pi / numel(S2F.nodes);
clear dist I;

if S2F.detectOutliers
  weights = weights .* exp(-S2F.outlierIndicators(grid_id));
end
weights = max(real(weights), 0);

% local function values
grid_vals = reshape(S2F.values(:), numel(S2F.nodes), numf);
f = grid_vals(grid_id,:);
clear grid_id grid_vals;


% solve the variable-size systems
solve_args = {'eval_vector', eval_vector};
if S2F.centered
  solve_args = [solve_args, {'centered_evaluation'}];
end
if S2F.regularize
  solve_args = [solve_args, {'regularize', ...
    'mincond', S2F.mincond, 'maxcond', S2F.maxcond, ...
    'targetcond', S2F.targetcond}];
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


% evaluate the local coefficient vectors
vals(J_idx,:) = permute(sum(basis_in_v .* ...
  permute(c_book, [3 1 2]), 2), [1 3 2]);

if isalmostreal(S2F.values)
  vals = real(vals);
end

end


% initialize struct for additional regularization information
function info = initRegInfo(N)
  info = struct;
  info.conds_reg = NaN(N, 1);
  info.conds_unreg = NaN(N, 1);
  info.maxeig = NaN(N, 1);
  info.mineig = NaN(N, 1);
  info.maxeig_reg = NaN(N, 1);
  info.mineig_reg = NaN(N, 1);
  info.centerAmplification = NaN(N, 1);
  info.centerAmplificationRegBound = NaN(N, 1);
  info.numericalRidge = NaN(N, 1);
  info.shapeRegularization = NaN(N, 1);
  info.regularizationActive = false(N, 1);
  info.deltaFallback = false(N, 1);
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
