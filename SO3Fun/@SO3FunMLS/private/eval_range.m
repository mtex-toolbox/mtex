function [vals, warnings, conds, info] = eval_range(SO3F, ori, varargin)

% Evaluate one fixed-radius batch. Warning flags are returned to eval and are
% emitted there only once after all batches have been processed.

ori = ori(:);
N0 = numel(ori);
numf = numel(SO3F);
wantConds = nargout > 2;
wantInfo = nargout > 3;
warnings = initWarnings;

vals = zeros(N0, numf);
if wantConds, conds = zeros(N0, 1); end
if wantInfo, info = initRegInfo(N0); end

[ind, dist] = SO3F.nodes.find(ori, SO3F.delta);
nn = full(sum(ind, 2));

% Avoid exact interpolation; its expected Lebesgue constant is unbounded.
too_few = nn <= SO3F.dim;
if any(too_few)
  warnings.rangeTooFew = true;
  n_few = nnz(too_few);

  if SO3F.use_smooth_delta && isempty(SO3F.auxgrid)
    SO3F = SO3F.init_auxgrid;
  end

  % switch to a minimal KNN neighborhood; assigning oF resets oF_max
  delta_original = SO3F.delta;
  oF_original = SO3F.oF;
  oF_max_original = SO3F.oF_max;
  SO3F.delta = 0;
  SO3F.oF = 1;

  [temp, tempConds, info_batch, warnings_batch] = ...
    SO3F.eval(ori.subSet(too_few), varargin{:});
  warnings = mergeWarnings(warnings, warnings_batch);

  vals(too_few,:) = reshape(temp, n_few, numf);
  if wantConds, conds(too_few) = tempConds; end
  if wantInfo, info = insertRegInfo(info, too_few, info_batch); end

  SO3F.oF = oF_original;
  SO3F.oF_max = oF_max_original;
  SO3F.delta = delta_original;
  if n_few == N0, return; end
end

% Cap very large neighborhoods by a KNN search.
too_many = nn > SO3F.dim * SO3F.oF_max;
if any(too_many)
  warnings.rangeTooMany = true;
  n_big = nnz(too_many);

  if SO3F.use_smooth_delta && isempty(SO3F.auxgrid)
    SO3F = SO3F.init_auxgrid;
  end

  delta_original = SO3F.delta;
  oF_original = SO3F.oF;
  oF_max_original = SO3F.oF_max;
  SO3F.delta = 0;
  SO3F.oF = SO3F.oF_max;

  [temp, tempConds, info_batch, warnings_batch] = ...
    SO3F.eval(ori.subSet(too_many), varargin{:});
  warnings = mergeWarnings(warnings, warnings_batch);

  vals(too_many,:) = reshape(temp, n_big, numf);
  if wantConds, conds(too_many) = tempConds; end
  if wantInfo, info = insertRegInfo(info, too_many, info_batch); end

  SO3F.oF = oF_original;
  SO3F.oF_max = oF_max_original;
  SO3F.delta = delta_original;
  if nnz(too_few | too_many) == N0, return; end
end


% continue with the neighborhoods of moderate size
J = ~(too_few | too_many);
J_idx = find(J);
ori = ori.subSet(J);
ind = ind(J,:);
dist = dist(J,:);
N = nnz(J);

if SO3F.subsample
  ind = SO3F.find_optimal_subset(ind, ori, varargin{:});
end

[grid_id, center_id] = find(ind');
nn = full(sum(ind, 2));
clear ind;

if SO3F.subsample
  localDist = angle(ori.subSet(center_id), SO3F.nodes.subSet(grid_id));
  dist = sparse(center_id, grid_id, localDist, N, numel(SO3F.nodes));
end

nn_total = numel(grid_id);


% evaluate the local basis
if ~SO3F.centered
  % without crystal symmetry no neighbor has to be projected to the
  % fundamental region of its center, so the basis can be reused
  if (SO3F.CS.id == 1) && (nn_total > numel(SO3F.nodes))
    basis_on_grid = eval_basis_functions(SO3F);
    G = basis_on_grid(grid_id, :);
    clear basis_on_grid;

    if SO3F.antipodal && mod(SO3F.degree, 2) == 1
      I = sum(ori.subSet(center_id).abcd .* ...
        SO3F.nodes.subSet(grid_id).abcd, 2) < 0;
      G(I,:) = -G(I,:);
    end
  else
    projected = project2FundamentalRegion( ...
      SO3F.nodes.subSet(grid_id), ori.subSet(center_id));
    G = eval_basis_functions(SO3F, projected);
    clear projected;
  end

  basis_at_centers = eval_basis_functions(SO3F, ori);
  eval_vector = permute(basis_at_centers, [2, 3, 1]);

  % the geometry score describes the local node cloud in the tangent space, so
  % the diagnostic needs local coordinates even for a non-centered basis
  if wantInfo
    [~, ~, bloc, cloc, dloc] = ...
      local_coordinates_SO3(ori, center_id, SO3F.nodes, grid_id);
  end
else
  if wantInfo
    [rotneighbors, aloc, bloc, cloc, dloc] = ...
      local_coordinates_SO3(ori, center_id, SO3F.nodes, grid_id);
  else
    [rotneighbors, aloc] = ...
      local_coordinates_SO3(ori, center_id, SO3F.nodes, grid_id);
  end

  G = eval_basis_functions(SO3F, rotneighbors);
  clear rotneighbors;

  if SO3F.antipodal && mod(SO3F.degree, 2) == 1
    I = aloc < 0;
    G(I,:) = -G(I,:);
  end
  clear aloc;

  % in centered coordinates evaluation is always at the identity
  basis_at_centers = eval_basis_functions(SO3F, orientation.id);
  eval_vector = basis_at_centers.';
end


% compute the compact local weights
I = sub2ind(size(dist), center_id, grid_id);
weights = SO3F.w(dist(I) ./ SO3F.delta);
weights = weights .* SO3F.vor_weights(grid_id) * pi^2 / numel(SO3F.nodes);
clear dist I;

if SO3F.detectOutliers
  weights = weights .* exp(-SO3F.outlierIndicators(grid_id));
end
weights = max(real(weights), 0);


% set up the local function values
grid_vals = reshape(SO3F.values(:), numel(SO3F.nodes), numf);
f = grid_vals(grid_id,:);
clear grid_vals;


% solve the variable-size systems
solve_args = {'eval_vector', eval_vector};
if SO3F.centered
  solve_args = [solve_args, {'centered_evaluation'}];
end
if SO3F.regularize
  solve_args = [solve_args, {'regularize', ...
    'mincond', SO3F.mincond, 'maxcond', SO3F.maxcond, ...
    'targetcond', SO3F.targetcond, ...
    'basis_degrees', basis_degrees_SO3(SO3F), ...
    'degree_laplace_shift', 2}];
end
solve_args = [solve_args, varargin];

if wantInfo
  [c_book, conds(J_idx), info_batch] = ...
    solve_lsq_book_varsize(weights, G, f, nn, solve_args{:});
  % local geometry of the weighted neighborhoods, as it enters the local systems
  info_batch.geometryScore = ...
    local_geometry_score_SO3(bloc, cloc, dloc, weights, nn);
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

if isalmostreal(SO3F.values), vals = real(vals); end

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
