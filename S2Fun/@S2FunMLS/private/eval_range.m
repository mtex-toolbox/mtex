function [vals, warnings, conds, info] = eval_range(S2F, v, varargin)

% Evaluate one fixed-radius batch. Warning flags are returned to eval and are
% emitted there only once after all batches have been processed.

v = v(:);
N0 = numel(v);
numf = numel(S2F);
wantConds = nargout > 2;
wantInfo = nargout > 3;
warnings = initWarnings;

vals = zeros(N0, numf);
if wantConds, conds = zeros(N0, 1); end
if wantInfo, info = initRegInfo(N0); end

[ind, dist] = S2F.nodes.find(v, S2F.delta);
nn = full(sum(ind, 2));

% Avoid exact interpolation; its expected Lebesgue constant is unbounded.
too_few = nn <= S2F.dim;
if any(too_few)
  warnings.rangeTooFew = true;
  n_few = nnz(too_few);

  if S2F.use_smooth_delta && isempty(S2F.auxgrid)
    S2F = S2F.init_auxgrid;
  end

  % switch to a minimal KNN neighborhood; assigning oF resets oF_max
  delta_original = S2F.delta;
  oF_original = S2F.oF;
  oF_max_original = S2F.oF_max;
  S2F.delta = 0;
  S2F.oF = 1;

  [temp, tempConds, info_batch, warnings_batch] = ...
    S2F.eval(v.subSet(too_few), varargin{:});
  warnings = mergeWarnings(warnings, warnings_batch);

  vals(too_few,:) = reshape(temp, n_few, numf);
  if wantConds, conds(too_few) = tempConds; end
  if wantInfo, info = insertRegInfo(info, too_few, info_batch); end

  S2F.oF = oF_original;
  S2F.oF_max = oF_max_original;
  S2F.delta = delta_original;
  if n_few == N0, return; end
end

% Cap very large neighborhoods by a KNN search.
too_many = nn > S2F.dim * S2F.oF_max;
if any(too_many)
  warnings.rangeTooMany = true;
  n_big = nnz(too_many);

  if S2F.use_smooth_delta && isempty(S2F.auxgrid)
    S2F = S2F.init_auxgrid;
  end

  delta_original = S2F.delta;
  oF_original = S2F.oF;
  oF_max_original = S2F.oF_max;
  S2F.delta = 0;
  S2F.oF = S2F.oF_max;

  [temp, tempConds, info_batch, warnings_batch] = ...
    S2F.eval(v.subSet(too_many), varargin{:});
  warnings = mergeWarnings(warnings, warnings_batch);

  vals(too_many,:) = reshape(temp, n_big, numf);
  if wantConds, conds(too_many) = tempConds; end
  if wantInfo, info = insertRegInfo(info, too_many, info_batch); end

  S2F.oF = oF_original;
  S2F.oF_max = oF_max_original;
  S2F.delta = delta_original;
  if nnz(too_few | too_many) == N0, return; end
end


% continue with the neighborhoods of moderate size
J = ~(too_few | too_many);
J_idx = find(J);
v = v.subSet(J);
ind = ind(J,:);
dist = dist(J,:);
N = nnz(J);

if S2F.subsample
  ind = S2F.find_optimal_subset(ind, v, varargin{:});
end

[grid_id, center_id] = find(ind');
nn = full(sum(ind, 2));
clear ind;

if S2F.subsample
  localDist = angle(v.subSet(center_id), S2F.nodes.subSet(grid_id));
  dist = sparse(center_id, grid_id, localDist, N, numel(S2F.nodes));
end

nn_total = numel(grid_id);


% evaluate the local basis
if ~S2F.centered
  if nn_total > numel(S2F.nodes)
    basis_on_grid = eval_basis_functions(S2F);
    G = basis_on_grid(grid_id, :);
    clear basis_on_grid;
  else
    G = eval_basis_functions(S2F, S2F.nodes.subSet(grid_id));
  end

  if S2F.antipodal && mod(S2F.degree, 2) == 1
    I = sum(v.subSet(center_id).xyz .* ...
      S2F.nodes.subSet(grid_id).xyz, 2) < 0;
    G(I,:) = -G(I,:);
  end

  basis_at_centers = eval_basis_functions(S2F, v);
  eval_vector = permute(basis_at_centers, [2, 3, 1]);

  % the geometry score describes the local node cloud in the tangent frame, so
  % the diagnostic needs local coordinates even for a non-centered basis
  if wantInfo
    [xloc, yloc] = local_coordinates_S2(v, center_id, S2F.nodes, grid_id);
  end
else
  [xloc, yloc, zloc] = ...
    local_coordinates_S2(v, center_id, S2F.nodes, grid_id);

  G = eval_basis_functions(S2F, vector3d(xloc, yloc, zloc));

  if S2F.antipodal && mod(S2F.degree, 2) == 1
    I = zloc < 0;
    G(I,:) = -G(I,:);
  end
  clear zloc;

  % in centered coordinates evaluation is always at the north pole
  basis_at_centers = eval_basis_functions(S2F, vector3d.Z);
  eval_vector = basis_at_centers.';
end


% compute the compact local weights
I = sub2ind(size(dist), center_id, grid_id);
weights = S2F.w(dist(I) ./ S2F.delta);
weights = weights .* S2F.vor_weights(grid_id) * 4*pi / numel(S2F.nodes);
clear dist I;

if S2F.detectOutliers
  weights = weights .* exp(-S2F.outlierIndicators(grid_id));
end
weights = max(real(weights), 0);


% set up the local function values
grid_vals = reshape(S2F.values(:), numel(S2F.nodes), numf);
f = grid_vals(grid_id,:);
clear grid_vals;


% solve the variable-size systems
solve_args = {'eval_vector', eval_vector};
if S2F.centered
  solve_args = [solve_args, {'centered_evaluation'}];
end
if S2F.regularize
  solve_args = [solve_args, {'regularize', ...
    'mincond', S2F.mincond, 'maxcond', S2F.maxcond, ...
    'targetcond', S2F.targetcond, ...
    'basis_degrees', basis_degrees_S2(S2F), ...
    'degree_laplace_shift', 1}];
end
solve_args = [solve_args, varargin];

if wantInfo
  [c_book, conds(J_idx), info_batch] = ...
    solve_lsq_book_varsize(weights, G, f, nn, solve_args{:});
  % local geometry of the weighted neighborhoods, as it enters the local systems
  info_batch.geometryScore = ...
    local_geometry_score_S2(xloc, yloc, weights, nn);
  info = insertRegInfo(info, J_idx, info_batch);
elseif wantConds
  [c_book, conds(J_idx)] = ...
    solve_lsq_book_varsize(weights, G, f, nn, solve_args{:});
else
  c_book = solve_lsq_book_varsize(weights, G, f, nn, solve_args{:});
end
clear weights G f grid_id solve_args;


% evaluate the local coefficient vectors
vals(J_idx,:) = permute(sum(basis_at_centers .* ...
  permute(c_book, [3, 1, 2]), 2), [1, 3, 2]);

if isalmostreal(S2F.values), vals = real(vals); end

end


function warnings = initWarnings
  warnings = struct;
  warnings.rangeTooFew = false;
  warnings.rangeTooMany = false;
  warnings.smoothTooFew = false;
  warnings.smoothAllCandidates = false;
end


function warnings = mergeWarnings(warnings, other)
  names = fieldnames(warnings);
  for k = 1 : numel(names)
    warnings.(names{k}) = warnings.(names{k}) | other.(names{k});
  end
end


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
  info.geometryScore = NaN(N, 1);
  info.regularizationActive = false(N, 1);
  info.deltaFallback = false(N, 1);
  info.candidateLimit = false(N, 1);
end


function info = insertRegInfo(info, I, info_batch)
  names = fieldnames(info_batch);
  for k = 1 : numel(names)
    name = names{k};
    if isfield(info, name)
      info.(name)(I,:) = info_batch.(name);
    end
  end
end
