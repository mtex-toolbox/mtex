function [vals, conds] = eval_stable(S2F, v, varargin)

% deal with the v where the canonical neighbors are not sufficiently nicely
%   spread around v 

N = numel(v);

% get nearest neighbors of each v in the subNodes
ind = find_stable(S2F, v, S2F.stableFindOptions{:}, varargin{:});
[grid_id, v_id] = find(ind');
nn = sum(ind, 2);
nn_total = sum(nn);
clear ind;


% ================================================
% 1- compute the basis values at all neighbors (G)
% ================================================
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
  rotneighbors = rot .* S2F.nodes(grid_id);

  % determine which basis to use and evaluate it on the grid and on v
  basis_on_grid = eval_basis_functions(S2F, rotneighbors);
  clear rotneighbors;
  G = basis_on_grid.';

  basis_in_pole = eval_basis_functions(S2F, vector3d.Z);
  basis_in_v = repmat(basis_in_pole, N, 1);
end


% ======================
% 2- compute the weights
% ======================
% compute the distances
d = angle(S2F.nodes.subSet(grid_id(:)), v.subSet(v_id(:)));
% also convert d to sparse after computing itntipo
dist = sparse(v_id, grid_id, d, N, numel(S2F.nodes));
maxdist = max(dist, [], 2);
clear d;
% dist(find(ind)) instead of nonzeros(dist), since elements of v might be
%   contained in S2F.nodes ==> distance 0, but in neighborhood
I = sub2ind(size(dist), v_id, grid_id);
weights = S2F.w(dist(I) ./ (maxdist(v_id) * 1.1));
clear dist I;

% readjust the weights of outliers, if outlierDetection is enabled
if (S2F.detectOutliers == true)
  oI = computeOutlierIndicators(S2F);
  oI_factor = exp(-oI(grid_id));
  weights = weights .* oI_factor;
  clear oI oI_factor;
end


% ===========================================
% 3 -compute the values of f at all neighbors
% ===========================================
grid_vals = reshape(S2F.values(:), numel(S2F.nodes), numel(S2F));
f = grid_vals(grid_id,:);
clear col_id grid_vals grid_id;


% ======================
% 4 - solve and evaluate
% ======================
[c_book, conds] = solve_lsq_book_varsize(weights, G.', f, nn, ...
  'regularize', S2F.regularizationOptions{:}, varargin{:});
vals = permute(sum(basis_in_v .* permute(c_book, [3 1 2]), 2), [1 3 2]);

if isalmostreal(S2F.values)
  vals = real(vals); 
end

end