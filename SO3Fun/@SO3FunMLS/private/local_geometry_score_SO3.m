function geometryScore = local_geometry_score_SO3(xloc, yloc, zloc, weights, sizes)

% local geometric badness of the weighted tangent node cloud
% 4 inputs: constant-size neighborhoods, all inputs are nn × N
% 5 inputs: variable-size neighborhoods, entries are ordered center-by-center
%
% The score is based on the centered weighted covariance in T_x SO(3).
% In three dimensions, the geometric-mean / arithmetic-mean eigenvalue ratio
% is used instead of the raw determinant ratio. This is much less sensitive to
% harmless sampling fluctuations while it still tends to zero for planar or
% line-like neighborhoods.

beta = 1;

% constant-size case, e.g. knn-search
if nargin == 4
  weights = reshape(weights, size(xloc));

  % compute total weight of each neighborhood
  Wsum = max(sum(weights, 1), realmin);

  % weight local tangent coordinates once and reuse them
  wx = weights .* xloc;
  wy = weights .* yloc;
  wz = weights .* zloc;

  % compute weighted center
  mux = sum(wx, 1) ./ Wsum;
  muy = sum(wy, 1) ./ Wsum;
  muz = sum(wz, 1) ./ Wsum;

  % compute weighted second moments
  M11 = sum(wx .* xloc, 1) ./ Wsum;
  M12 = sum(wx .* yloc, 1) ./ Wsum;
  M13 = sum(wx .* zloc, 1) ./ Wsum;
  M22 = sum(wy .* yloc, 1) ./ Wsum;
  M23 = sum(wy .* zloc, 1) ./ Wsum;
  M33 = sum(wz .* zloc, 1) ./ Wsum;

% variable-size case, e.g. range-search
else
  N = numel(sizes);

  % center ids of all local neighbors
  center_id = repelem((1:N)', sizes);

  % compute total weight of each neighborhood
  Wsum = accumarray(center_id, weights, [N, 1]);
  Wsum = max(Wsum, realmin);

  % weight local tangent coordinates once and reuse them
  wx = weights .* xloc;
  wy = weights .* yloc;
  wz = weights .* zloc;

  % compute weighted center
  mux = accumarray(center_id, wx, [N, 1]) ./ Wsum;
  muy = accumarray(center_id, wy, [N, 1]) ./ Wsum;
  muz = accumarray(center_id, wz, [N, 1]) ./ Wsum;

  % compute weighted second moments
  M11 = accumarray(center_id, wx .* xloc, [N, 1]) ./ Wsum;
  M12 = accumarray(center_id, wx .* yloc, [N, 1]) ./ Wsum;
  M13 = accumarray(center_id, wx .* zloc, [N, 1]) ./ Wsum;
  M22 = accumarray(center_id, wy .* yloc, [N, 1]) ./ Wsum;
  M23 = accumarray(center_id, wy .* zloc, [N, 1]) ./ Wsum;
  M33 = accumarray(center_id, wz .* zloc, [N, 1]) ./ Wsum;
end

% centered covariance: this is the affine Schur-complement geometry
C11 = M11 - mux.^2;
C12 = M12 - mux .* muy;
C13 = M13 - mux .* muz;
C22 = M22 - muy.^2;
C23 = M23 - muy .* muz;
C33 = M33 - muz.^2;

trC = C11 + C22 + C33;
detC = C11 .* (C22 .* C33 - C23.^2) ...
  - C12 .* (C12 .* C33 - C13 .* C23) ...
  + C13 .* (C12 .* C23 - C13 .* C22);

% 3 * geometric mean / sum of the covariance eigenvalues = (27 det(C) / trace(C)^3)^(1/3)
iso = 27 .* detC ./ max(trC.^3, realmin);
iso = min(max(real(iso), 0), 1) .^ (1/3);

% mild penalty for one-sided neighborhoods
trM = M11 + M22 + M33;
balance = sqrt(mux.^2 + muy.^2 + muz.^2) ./ sqrt(max(trM, realmin));

quality = iso .* exp(-beta .* balance.^2);
quality = min(max(real(quality), 0), 1);

% geometryScore is close to zero for good neighborhoods and close to one for
% genuinely anisotropic, lower-dimensional, or strongly one-sided ones
geometryScore = (1 - quality).^2;
geometryScore = geometryScore(:);

end
