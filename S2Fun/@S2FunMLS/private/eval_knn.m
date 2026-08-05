function [vals, conds, info] = eval_knn(S2F, v, varargin)

% get parameters
v = v(:);
N = numel(v);
supportMargin = 1.10;

% Smooth support radii require additional candidate neighbors because some
% candidates lie outside the final compact support.
nn = S2F.nn * (1 + S2F.use_smooth_delta);
nn_total = nn * N;

% find neighbors and optionally select an optimal subset
[ind, dist] = S2F.nodes.find(v, nn, varargin{:});
if S2F.subsample
  ind = S2F.find_optimal_subset(ind, v, varargin{:});
  nn_total = N * S2F.dim;
  nn = S2F.dim;
end

% neighbor and center ids ordered center-by-center
grid_id = reshape(ind', nn_total, 1);
v_id = repelem((1:N)', nn);

if S2F.subsample
  dist = angle(v.subSet(v_id), S2F.nodes.subSet(grid_id));
  dist = reshape(dist, S2F.dim, N)';
end


% evaluate the local basis
if ~S2F.centered
  if nn_total > numel(S2F.nodes.x)
    G = eval_basis_functions(S2F);
    G = G(grid_id, :).';
  else
    G = eval_basis_functions(S2F, S2F.nodes(grid_id)).';
  end

  % choose the representative on the same hemisphere for odd antipodal bases
  if S2F.antipodal && mod(S2F.degree, 2) == 1
    I = sum(v.subSet(v_id).xyz .* ...
      S2F.nodes.subSet(grid_id).xyz, 2) < 0;
    G(:,I) = -G(:,I);
  end

  g_book = reshape(eval_basis_functions(S2F, v).', S2F.dim, 1, N);
else
  % rotate every neighborhood center to the north pole
  [xloc, yloc, zloc] = ...
    local_coordinates_S2(v, v_id, S2F.nodes, grid_id);

  G = eval_basis_functions(S2F, vector3d(xloc, yloc, zloc));
  G = permute(G, [2,1]);

  if S2F.antipodal && mod(S2F.degree, 2) == 1
    I = zloc < 0;
    G(:,I) = -G(:,I);
  end
  clear xloc yloc zloc;

  % in centered coordinates evaluation is always at the north pole
  g_book = eval_basis_functions(S2F, vector3d.Z).';
end

G_book = permute(reshape(G, S2F.dim, nn, N), [2, 1, 3]);
clear G v_id;


% compute the compact support radius and weights
if S2F.use_smooth_delta
  deltas = supportMargin * get_option(varargin, 'smoothDelta', []);

  % Smoothing may locally underestimate the required radius. The pointwise
  % lower bound keeps all selected nodes inside the effective support.
  if S2F.subsample
    fallbackDelta = supportMargin * max(dist, [], 2);
  else
    fallbackDelta = supportMargin * dist(:,S2F.nn);
  end
  deltaFallback = deltas(:) < fallbackDelta;
  deltas = max(deltas(:), fallbackDelta);
else
  deltas = supportMargin * max(dist, [], 2);
  deltaFallback = false(N, 1);
end

deltas = max(real(deltas(:)), realmin);
weights = S2F.w(dist ./ deltas);

vor_weights = reshape(S2F.vor_weights(grid_id), nn, N)';
weights = weights .* vor_weights * 4*pi / numel(S2F.nodes);
clear deltas dist vor_weights;

if S2F.detectOutliers
  oI = reshape(S2F.outlierIndicators(grid_id), nn, N)';
  weights = weights .* exp(-oI);
  clear oI;
end

W_book = permute(max(real(weights), 0), [2, 3, 1]);
clear weights;

if S2F.use_smooth_delta
  nn_smooth = reshape(sum(W_book > 0, 1), [], 1);
  if min(nn_smooth) < S2F.dim
    warning(['Due to smoothing the support radius, some centers did not ' ...
      'have sufficiently many positive-weight neighbors.']);
  end
end

% set up local function values
grid_vals = reshape(S2F.values(:), numel(S2F.nodes), numel(S2F));
f_book = permute(reshape(grid_vals(grid_id,:), ...
  nn, N, numel(S2F)), [1, 3, 2]);
clear grid_id grid_vals;


% solve the local systems
solve_args = {'eval_vector', g_book};
if S2F.centered
  solve_args = [solve_args, {'centered_evaluation'}];
end
if S2F.regularize
  solve_args = [solve_args, {'regularize', ...
    'mincond', S2F.mincond, 'maxcond', S2F.maxcond, ...
    'targetcond', S2F.targetcond}];
end
solve_args = [solve_args, varargin];

if nargout <= 1
  c_book = solve_lsq_book_constsize(W_book, G_book, f_book, solve_args{:});
elseif nargout == 2
  [c_book, conds] = ...
    solve_lsq_book_constsize(W_book, G_book, f_book, solve_args{:});
else
  [c_book, conds, info] = ...
    solve_lsq_book_constsize(W_book, G_book, f_book, solve_args{:});
  info.deltaFallback = deltaFallback;
end
clear f_book G_book W_book solve_args;

vals = permute(sum(c_book .* g_book, 1), [3, 2, 1]);

if isalmostreal(S2F.values)
  vals = real(vals);
end

end
