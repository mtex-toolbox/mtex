function ind = find_stable(S2F, v, varargin)

% find for some v the neighborhoods in a grid nodes, such that there is at least
%   one neighbor in each quadrant with respect to this center

% get parameters
% number of voronoi neighbors we begin with
nn_voronoi = get_option(varargin, {'nn_voronoi','nnvoronoi','nn voronoi'}, 64);
% minimal number of neighbors we want per quadrant
nn_min = get_option(varargin, {'nn_min','nnmin','nn min'}, S2F.dim);
% use at most nn_max neighbors per quadrant
nn_max = get_option(varargin, {'nn_max','nnmax','nn max'}, 2 * S2F.dim);

N = numel(v);

voronoi_neighbor_indices = S2F.voronoiCenters.find(v, nn_voronoi, 'sortindices', true);

% determine normal vectors of orthogonal planes through w 
%   (through the origin, parallel to the tangent plane at w)
% TODO: choose the splitters according to pca on the canonical nearest neighbors
splitterCandidates = [vector3d.X; vector3d.Y; vector3d.Z];
[~, id] = min(abs(v.xyz), [], 2);
splitter1 = cross(v, splitterCandidates.subSet(id)).normalize;
splitter2 = cross(v, splitter1).normalize;

% for all neighbors, determine its quadrant w.r.t. their center
v_id = repmat((1 : N)', 1, nn_voronoi);
updown = dot(S2F.voronoiCenters(voronoi_neighbor_indices), ...
  splitter1(v_id)) >= 0;
leftright = dot(S2F.voronoiCenters(voronoi_neighbor_indices), ...
  splitter2(v_id)) >= 0;
quadrants = 2 * leftright + updown + 1;

updown = updown';
leftright = leftright';
voronoi_neighbor_indices = voronoi_neighbor_indices';

count_in_quadrant = zeros(nn_voronoi,N);

% quadrant 1
quadrant_marker = ~leftright & ~updown;
temp = cumsum(quadrant_marker, 1);
count_in_quadrant(quadrant_marker) = temp(quadrant_marker);

% quadrant 2
quadrant_marker = ~leftright & updown;
temp = cumsum(quadrant_marker, 1);
count_in_quadrant(quadrant_marker) = temp(quadrant_marker);

% quadrant 3
quadrant_marker = leftright & ~updown;
temp = cumsum(quadrant_marker, 1);
count_in_quadrant(quadrant_marker) = temp(quadrant_marker);

% quadrant 4
quadrant_marker = leftright & updown;
temp = cumsum(quadrant_marker, 1);
count_in_quadrant(quadrant_marker) = temp(quadrant_marker);

% habe: voronoi-nachbarn pro quadrant. 
% ziel: die naehesten S2F.dim nachbarn pro quadrant auswaehlen

% ansatz (fuer jedes v):
%   schreibe indice der voronoi-zentren pro quadrant in zeile
% quadrants' are row_index
voronoi_idx_per_quadrant = zeros(nn_voronoi, 4, N);
page_idx = repmat((1 : N), nn_voronoi, 1);
idx = sub2ind(size(voronoi_idx_per_quadrant), count_in_quadrant, quadrants', page_idx);
voronoi_idx_per_quadrant(idx) = voronoi_neighbor_indices;

%   erstelle matrix der entsprechenden counts
quadrant_has_neighbors = voronoi_idx_per_quadrant > 0;
counts_per_quadrant = zeros(size(voronoi_idx_per_quadrant));
counts_per_quadrant(quadrant_has_neighbors) = ...
  S2F.voronoiCounts(voronoi_idx_per_quadrant(quadrant_has_neighbors));

%   nehme davon die cumsum
counts_per_quadrant = cumsum(counts_per_quadrant, 1);

%   finde pro spalte den index, ab dem zuerst die minimal erforderliche anzahl
%     an nachbarn ueberschritten wird
enough_neighbors = counts_per_quadrant >= nn_min;
[enough_neighbors, stop_here] = max(enough_neighbors, [], 1);
enough_neighbors = logical(enough_neighbors);

%   fallback zum letzten nicht-0-eintrag, falls nie enough_neighbors
[~, last_entry] = max(counts_per_quadrant, [], 1);
idx = stop_here;
idx(~enough_neighbors) = last_entry(~enough_neighbors);

%   falls eine zeile nur nullen hat, soll der index 0 sein
quadrant_has_nodes = logical(max(voronoi_idx_per_quadrant, [], 1) > 0);
idx = idx .* quadrant_has_nodes;

% schreibe resultierende in 4*nn_voronoi x N array
r = (1 : nn_voronoi)';
voronoi_idx_per_quadrant(r > idx) = 0;
voronoi_idx_per_quadrant = reshape(voronoi_idx_per_quadrant, nn_voronoi*4, N);

% remove zeros, store number of voronoi neighbors per w
num_used_voronoi_centers_per_v = sum(voronoi_idx_per_quadrant > 0, 1)';
voronoi_idx_per_quadrant = nonzeros(voronoi_idx_per_quadrant);

% if a voronoi center has many nodes we only use the 2*S2F.dim ones closest to v
num_nodes_per_voronoi_cell = S2F.voronoiCounts(voronoi_idx_per_quadrant);
too_large = num_nodes_per_voronoi_cell > nn_max;

% we need this later
voronoi_id = repelem((1 : N)', num_used_voronoi_centers_per_v);
max_nodes_per_voronoi_cell = max(accumarray(voronoi_id, min(num_nodes_per_voronoi_cell, nn_max)));

% create a sparse matrix of size (max_nodes_per_voronoi_cell x N) 
% first only add neighbors from voronoi centers where too_large == false
num_neighbors_per_v = accumarray(voronoi_id(~too_large), num_nodes_per_voronoi_cell(~too_large), [N, 1]);
[row_idx_small, col_idx_small] = sizes2sub(num_neighbors_per_v);
indices_small = nonzeros(S2F.voronoiIndices(:,voronoi_idx_per_quadrant(~too_large)));

% also add neighbors from voronoi centers where too_large == true
% find the indices somehow
% TODO: nehme die naechsten paar nachbarn des globalen grids IMMER mit dazu
num_nodes_per_voronoi_cell = num_nodes_per_voronoi_cell(too_large);
v_id = repelem((1 : N)', num_used_voronoi_centers_per_v);
v_id = repelem(v_id(too_large), num_nodes_per_voronoi_cell);
voronoi_idx_per_quadrant = voronoi_idx_per_quadrant(too_large);
grid_id = nonzeros(S2F.voronoiIndices(:, voronoi_idx_per_quadrant));
dists = angle(v.subSet(v_id), S2F.nodes.subSet(grid_id));
[row_idx, col_idx] = sizes2sub(num_nodes_per_voronoi_cell);

% get indice of <nn_max> smallest non-zero distances per column
[~, perm] = sortrows([col_idx, dists, row_idx], [1, 2, 3]);
row_idx = row_idx(perm);
col_idx = col_idx(perm);
start_of_new_voronoi_cell = cumsum([1; num_nodes_per_voronoi_cell(1:end-1)]);

% get row indices for dealing grid_indices to a sparse matrix 
r = (1 : numel(col_idx))' - repelem(start_of_new_voronoi_cell, num_nodes_per_voronoi_cell) + 1;
mask = r <= nn_max;

row_idx2 = row_idx(mask);
offsets2 = cumsum([0; num_nodes_per_voronoi_cell]);
offsets2(end) = [];
offsets2 = repelem(offsets2, nn_max);
thisisit = offsets2 + row_idx2;

offsets = num_neighbors_per_v;
indices_large = grid_id(thisisit);
v_id = repelem((1 : N)', num_used_voronoi_centers_per_v);
num_neighbors_per_v = accumarray(v_id(too_large), nn_max, [N, 1]);
row_idx_large = sizes2sub(num_neighbors_per_v) + repelem(offsets(v_id(too_large)), nn_max);
col_idx_large = repelem(voronoi_id(too_large), nn_max);

% TODO: MAKE THIS FASTER!
%       use unique on voronoi_id for more performance
%       also loop over batches of voronoi cells of similar size
%       in each cell just work with full matrices, use sort to get the inds
%       then use the first nn_max inds per row, and done 

indexmat = sparse([row_idx_small; row_idx_large], [col_idx_small; col_idx_large], ...
  [indices_small; indices_large], max_nodes_per_voronoi_cell, N, numel(row_idx_small) + numel(row_idx_large));

% add the nearest neighbors too each column, and do unique afterwards
idclosest = S2F.nodes.find(v, 2*S2F.dim)';
indexmat = [idclosest; indexmat];

% do column-wise unique
[~, col, id] = find(indexmat);
maxId = max(id);
P = sparse(id, col, true, maxId, N);
[idU, colU] = find(P);
pairs = sortrows([colU, idU], [1, 2]);

% make it logical
ind = sparse(pairs(:,1), pairs(:,2), true, N, numel(S2F.nodes), size(pairs, 1));

end