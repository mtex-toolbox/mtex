function [x,y,z] = localCoordinatesS2(centers,centerId,nodes,gridId)
% coordinates of the nodes after the rotation that maps their center to the north pole

% center and neighbor coordinates
cx = centers.x(centerId);
cy = centers.y(centerId);
cz = centers.z(centerId);
nx = nodes.x(gridId);
ny = nodes.y(gridId);
nz = nodes.z(gridId);

% the local z-coordinate is the scalar product
d = cx .* nx + cy .* ny;
z = d + cz .* nz;

x = zeros(size(nx));
y = zeros(size(ny));

% the shortest rotation, with (1-cz)/(cx^2+cy^2) = 1/(1+cz) against
% cancellation near the north pole
south = (1 + cz) < 1e-10;
regular = ~south;
if any(regular)
  h = 1 ./ (1 + cz(regular));
  x(regular) = nx(regular) - cx(regular) .* nz(regular) - cx(regular) .* d(regular) .* h;
  y(regular) = ny(regular) - cy(regular) .* nz(regular) - cy(regular) .* d(regular) .* h;
end

% the shortest rotation is singular at the south pole, where a right-handed
% tangent frame from the projected x-axis takes its place
if any(south)
  csx = cx(south);
  csy = cy(south);
  csz = cz(south);

  exnorm = sqrt(max(1 - csx.^2,realmin));
  exx = (1 - csx.^2) ./ exnorm;
  exy = (-csx .* csy) ./ exnorm;
  exz = (-csx .* csz) ./ exnorm;

  % ey = center × ex, hence ex × ey = center
  eyx = csy .* exz - csz .* exy;
  eyy = csz .* exx - csx .* exz;
  eyz = csx .* exy - csy .* exx;

  x(south) = exx .* nx(south) + exy .* ny(south) + exz .* nz(south);
  y(south) = eyx .* nx(south) + eyy .* ny(south) + eyz .* nz(south);
end

end
