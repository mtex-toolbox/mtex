function geometryScore = local_geometry_score_S2(xloc, yloc, weights, sizes)

% local geometric badness of the weighted tangent node cloud
% 3 inputs: constant-size neighborhoods, all inputs are nn x N
% 4 inputs: variable-size neighborhoods, entries are ordered center-by-center

beta = 2;

% constant-size case, e.g. knn-search
if nargin == 3
  weights = reshape(weights, size(xloc));
  % compute 'total weight' of each neighborhood
  Wsum = sum(weights, 1);

  % weight local tangent coordinates once and reuse them
  wx = weights .* xloc;
  wy = weights .* yloc;

  % compute weighted center
  mux = sum(wx, 1) ./ Wsum;
  muy = sum(wy, 1) ./ Wsum;

  % compute weighted second moments
  M11 = sum(wx .* xloc, 1) ./ Wsum;
  M12 = sum(wx .* yloc, 1) ./ Wsum;
  M22 = sum(wy .* yloc, 1) ./ Wsum;

% variable-size case, e.g. range-search
else
  N = numel(sizes);

  % center ids of all local neighbors
  center_id = repelem((1:N)', sizes);

  % compute 'total weight' of each neighborhood
  Wsum = accumarray(center_id, weights, [N, 1]);

  % weight local tangent coordinates once and reuse them
  wx = weights .* xloc;
  wy = weights .* yloc;

  % compute weighted center
  mux = accumarray(center_id, wx, [N, 1]) ./ Wsum;
  muy = accumarray(center_id, wy, [N, 1]) ./ Wsum;

  % compute weighted second moments
  M11 = accumarray(center_id, wx .* xloc, [N, 1]) ./ Wsum;
  M12 = accumarray(center_id, wx .* yloc, [N, 1]) ./ Wsum;
  M22 = accumarray(center_id, wy .* yloc, [N, 1]) ./ Wsum;
end

% compute trace and determinant of the local moment matrix M
trM  = M11 + M22;
detM = M11 .* M22 - M12.^2;

% measure how two-dimensional the local neighborhood is
% iso is close to 1 for isotropic neighborhoods and close to 0 for line-like ones
iso = 4 .* detM ./ trM.^2;

% measure how much the local neighborhood is shifted away from the center
% balance is small for centered neighborhoods and large for one-sided ones
balance = sqrt(mux.^2 + muy.^2) ./ sqrt(trM);

% combine isotropy and balance into one local geometry quality
% quality is close to 1 for good neighborhoods and close to 0 for bad ones
quality = iso .* exp(-beta .* balance.^2);

% convert quality into a score
% geometryScore is close to 0 for good neighborhoods and close to 1 for bad ones
geometryScore = (1 - quality).^2;
geometryScore = geometryScore(:);

end