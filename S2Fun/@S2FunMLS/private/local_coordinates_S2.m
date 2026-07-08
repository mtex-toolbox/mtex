function [xloc, yloc, zloc] = local_coordinates_S2(centers, center_id, nodes, grid_id)

% compute local coordinates of nodes w.r.t. centers
% the rotation maps each center to the north pole
% centers(center_id) and nodes(grid_id) are assumed to be column-compatible

% get center coordinates
cx = centers.x(center_id);
cy = centers.y(center_id);
cz = centers.z(center_id);

% get neighbor coordinates
nx = nodes.x(grid_id);
ny = nodes.y(grid_id);
nz = nodes.z(grid_id);

% tangent dot product of center and node
d = cx .* nx + cy .* ny;

% local z-coordinate is the full scalar product
zloc = d + cz .* nz;

% stable form of the shortest rotation center -> north pole
% the identity (1-cz)/(cx^2+cy^2) = 1/(1+cz) avoids instability near north pole
h = 1 ./ (1 + cz);

xloc = nx - cx .* nz - cx .* d .* h;
yloc = ny - cy .* nz - cy .* d .* h;

end