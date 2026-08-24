function [xloc, yloc, zloc] = ...
  local_coordinates_S2(centers, center_id, nodes, grid_id)

% compute local coordinates of nodes with respect to their evaluation centers
% the local rotation maps every center to the north pole

% center coordinates
cx = centers.x(center_id);
cy = centers.y(center_id);
cz = centers.z(center_id);

% neighbor coordinates
nx = nodes.x(grid_id);
ny = nodes.y(grid_id);
nz = nodes.z(grid_id);

% local z-coordinate is the complete scalar product
d = cx .* nx + cy .* ny;
zloc = d + cz .* nz;

xloc = zeros(size(nx));
yloc = zeros(size(ny));

% Stable shortest-rotation formula away from the south pole. The identity
% (1-cz)/(cx^2+cy^2) = 1/(1+cz) avoids cancellation near the north pole.
south = (1 + cz) < 1e-10;
regular = ~south;
if any(regular)
  h = 1 ./ (1 + cz(regular));
  xloc(regular) = nx(regular) - cx(regular) .* nz(regular) - ...
    cx(regular) .* d(regular) .* h;
  yloc(regular) = ny(regular) - cy(regular) .* nz(regular) - ...
    cy(regular) .* d(regular) .* h;
end

% The shortest-rotation formula is singular at the south pole. There we use a
% deterministic right-handed tangent frame obtained by projecting the x-axis.
if any(south)
  csx = cx(south);
  csy = cy(south);
  csz = cz(south);

  exnorm = sqrt(max(1 - csx.^2, realmin));
  exx = (1 - csx.^2) ./ exnorm;
  exy = (-csx .* csy) ./ exnorm;
  exz = (-csx .* csz) ./ exnorm;

  % ey = center × ex, hence ex × ey = center
  eyx = csy .* exz - csz .* exy;
  eyy = csz .* exx - csx .* exz;
  eyz = csx .* exy - csy .* exx;

  xloc(south) = exx .* nx(south) + exy .* ny(south) + exz .* nz(south);
  yloc(south) = eyx .* nx(south) + eyy .* ny(south) + eyz .* nz(south);
end

end
