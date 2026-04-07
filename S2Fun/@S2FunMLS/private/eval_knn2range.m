function [vals, conds, warn_smallnn, warn_bignn] = eval_knn2range(S2F, v, varargin)

% idea: set delta to .99 times the distance to the (nn+1)-th neighbor

% get parameters
v = v(:);
N = size(v, 1);
vals = zeros(N, numel(S2F));
conds = zeros(N, 1);
 
% get the neighbors 
[ind, dist] = S2F.nodes.find(v, S2F.nn + 1, varargin{:}, 'searcher', S2F.searcher);

% treat bad nodes separately, but only if the stablefind-option is true
iscvx = S2F.checkConvexity(v, ind);
if (S2F.stableFind && sum(iscvx) < N)
  [valstmp, conds(~iscvx)] = eval_stable(S2F, v.subSet(~iscvx), ...
    varargin{:}, S2F.stableFindOptions{:});
  vals(~iscvx,:) = reshape(valstmp, sum(~iscvx), numel(S2F));
  clear valstmp;

  % restrict varibales to their new domain (where iscvx is true)
  N = sum(iscvx);
  v = v.subSet(iscvx);
  ind = ind(iscvx, :);
  dist = dist(iscvx, :);
else
  iscvx = true(N, 1);
end

% set delta to 99% of distance of (nn+1)-th neighbor
% throw away points that are outside this delta-range
% create index vectors, since neighborhoods now have different sizes
delta = dist(:, end) * .99;
inrange = (dist < delta)';
nn = sum(inrange, 1)';
nn_total = sum(nn);
v_id = repelem((1:N)', nn);

ind = ind';
grid_id = ind(inrange);
clear ind;
dist = dist';
dist = dist(inrange);

if (S2F.subsample == true && S2F.stableFind == false)
  dist = angle(v.subSet(v_id), S2F.nodes.subSet(grid_id));
  dist = sparse(v_id, grid_id, dist, N, numel(S2F.nodes));
end

% compute for every center from v the matrix of all basis functions evaluated at
%   all neighbors of this center 
% evaluate the basis functions on the nodes
if (~S2F.centered)
  % choose faster way between computing all values and reusing them or
  % computing values on fibgrid(grid_id)
  if nn_total > numel(S2F.nodes.x)
    basis_on_grid = eval_basis_functions(S2F);
    G = basis_on_grid(grid_id, :).';
  else
    G = eval_basis_functions(S2F, S2F.nodes(grid_id)).';
  end

  % odd basis functions may clash with antipodal option, since (-v) = -p(v)
  % thus make sure to use the representer which is closer to the center
  if (mod(S2F.degree, 2) > 0)
    I = sum(v.subSet(v_id).xyz .* S2F.nodes.subSet(grid_id).xyz, 2) < 0;
    G(:,I) = G(:,I) * (-1);
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
  basis_on_grid = eval_basis_functions(S2F, rotneighbors);
  clear rotneighbors;
  G = basis_on_grid.';
  clear basis_on_grid;

  % ensure correct representer for antipodal S2F with odd degree (same as above)
  if (S2F.antipodal && (mod(S2F.degree, 2) == 1))
    I = sum(v.subSet(v_id).xyz .* S2F.nodes.subSet(grid_id).xyz, 2) < 0;
    G(:,I) = G(:,I) * (-1);
  end

  basis_in_pole = eval_basis_functions(S2F, vector3d.Z);
  basis_in_v = repmat(basis_in_pole, N, 1);
end
G = G.';

% compute the weights
% dist(find(ind)) instead of nonzeros(dist), since elements of v might be
%   contained in S2F.nodes ==> distance 0, but in neighborhood
weights = S2F.w(dist ./ repelem(delta, nn, 1));
clear dist I;

if (S2F.detectOutliers == true)
  oI = computeOutlierIndicators(S2F);
  oI_factor = exp(-oI(grid_id));
  weights = weights .* oI_factor;
  clear oI oI_factor;
end

% set up right hand side
grid_vals = reshape(S2F.values(:), numel(S2F.nodes), numel(S2F));
f = grid_vals(grid_id,:);

if S2F.regularize
  [c_book, conds(iscvx)] = solve_lsq_book_varsize(weights, G, f, nn, ...
    'regularize', 'maxcond', S2F.maxcond, 'mincond', S2F.mincond, ...
    'basis_weights', S2F.basis_weights, varargin{:});
else
  [c_book, conds(iscvx)]  = solve_lsq_book_varsize(weights, G, f, nn, varargin{:});
end

vals(iscvx,:) = permute(sum(basis_in_v .* permute(c_book, [3 1 2]), 2), [1 3 2]);

if isalmostreal(S2F.values)
  vals = real(vals); 
end

end
