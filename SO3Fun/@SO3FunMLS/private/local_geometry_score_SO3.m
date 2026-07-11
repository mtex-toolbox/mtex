function geometryScore = local_geometry_score_SO3(xloc, yloc, zloc, weights, sizes)

% local geometric badness of the weighted tangent node cloud
% 4 inputs: constant-size neighborhoods, all inputs are nn x N
% 5 inputs: variable-size neighborhoods, entries are ordered center-by-center

beta = 1;

% constant-size case, e.g. knn-search
if nargin == 4
  weights = reshape(weights, size(xloc));
  % compute 'total weight' of each neighborhood
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

  % compute 'total weight' of each neighborhood
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

% use the centered covariance matrix for the shape of the tangent node cloud
C11 = M11 - mux.^2;
C12 = M12 - mux .* muy;
C13 = M13 - mux .* muz;
C22 = M22 - muy.^2;
C23 = M23 - muy .* muz;
C33 = M33 - muz.^2;

% determinant based isotropy of the centered covariance matrix
%   the cube root makes the volume measure comparable to a one-dimensional
%   scale and avoids an overly sensitive score in three tangent dimensions
trC = C11 + C22 + C33;
detC = C11 .* (C22 .* C33 - C23.^2) ...
  - C12 .* (C12 .* C33 - C13 .* C23) ...
  + C13 .* (C12 .* C23 - C13 .* C22);

iso = 27 .* detC ./ max(trC.^3, realmin);
iso = min(max(real(iso), 0), 1);
iso = iso .^ (1/3);

% measure how much the weighted neighborhood is shifted away from the center
%   this is included more mildly than in the S2 score, since density-adaptive
%   SO(3) node sets naturally produce some local imbalance
trM = M11 + M22 + M33;
balance = sqrt(mux.^2 + muy.^2 + muz.^2) ./ sqrt(max(trM, realmin));

% combine isotropy and balance into one geometry quality
quality = iso .* exp(-beta .* balance.^2);
quality = min(max(real(quality), 0), 1);

% geometryScore is close to 0 for good neighborhoods and close to 1 for bad ones
geometryScore = (1 - quality).^2;
geometryScore = geometryScore(:);

end
