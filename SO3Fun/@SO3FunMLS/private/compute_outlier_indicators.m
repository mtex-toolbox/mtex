function oI = compute_outlier_indicators(SO3F)

% Input:
%   SO3F   - @SO3FunMLS; nodes, values and outlierDetectionRange are used
%
% Output:
%   oI     - N x numel(SO3F) matrix of outlier indicators,
%            one column per function component

% find k nearest neighbors (returns N-by-k index array)
k = SO3F.outlierDetectionRange;
id = SO3F.nodes.find(SO3F.nodes, k);

% reshape function values to node x function format
grid_vals = reshape(SO3F.values(:), numel(SO3F.nodes), numel(SO3F));
oI = zeros(numel(SO3F.nodes), numel(SO3F));

for j = 1 : numel(SO3F)
  % gather neighbor values as N-by-k matrix
  % NOTE: linear indexing of a column with the N-by-k index array returns a
  %   single column, so the neighborhood layout has to be restored
  vals = reshape(grid_vals(id,j), size(id));

  % local median value of neighborhood, for each node as center (N x 1)
  m = median(vals, 2);

  % local MAD for each node (N x 1)
  absDevs = abs(vals - m);
  MAD = median(absDevs, 2);

  % node-wise deviation from local median
  d = abs(grid_vals(:,j) - m);

  % normalize deviation from median by median local deviation
  z = d ./ MAD;

  % MAD might be (almost) zero for locally constant data
  % there we must punish outliers very hard!
  thresh = 1e-2 * median(abs(vals), 2) + 1e-6; % last summand avoids thresh = 0
  I = MAD < thresh;
  z(I) = 1e2 * d(I);

  % compute outlier indicator oI (N x 1), and disregard small values of oI
  minimalRequiredNormalizedDeviation = 1;
  oI(:,j) = max(z - minimalRequiredNormalizedDeviation, 0);
end

if isscalar(SO3F)
  oI = oI(:);
end

end
