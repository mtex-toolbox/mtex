function [aloc, bloc, cloc, dloc, rotneighbors] = ...
  local_coordinates_SO3(centers, center_id, nodes, grid_id)

% compute local coordinates of nodes w.r.t. centers
% the rotation maps each center to the identity
% centers(center_id) and nodes(grid_id) are assumed to be column-compatible

% project neighbors to the representer that belongs to the center
projected = project2FundamentalRegion(nodes(grid_id), centers(center_id));

% shift the local problems to be centered around orientation.id
inv_centers = inv(centers);
inv_centers = reshape(inv_centers(center_id), size(projected));
rotneighbors = inv_centers .* projected;

% local quaternion coordinates
abcd = rotneighbors.abcd;
aloc = abcd(:,1);
bloc = abcd(:,2);
cloc = abcd(:,3);
dloc = abcd(:,4);

end
