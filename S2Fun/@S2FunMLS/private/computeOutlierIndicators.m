function oI = computeOutlierIndicators(S2F)

% Input:
%   nodes  - @vector3d array of nodes
%   values - array of same dimensions as nodes, containing the values
%   k      - number of nearest neighbors (integer) for KNN
%
% Output:
%   v      - N x 1 vector of outlier indicators

% find k nearest neighbors (returns N-by-k index array)
k = S2F.outlierDetectionRange;
id = find(S2F.nodes, S2F.nodes, k);

% gather neighbor values as N-by-k matrix
vals = S2F.values(id);

% local median value of neighborhood, for each node as center (N x 1)
m = median(vals, 2);

% local MAD for each node (N x 1)
absDevs = abs(vals - m);
MAD = median(absDevs, 2);

% node-wise deviation from local median
d = abs(S2F.values(:) - m);

% normalize deviation from median by median local deviation
z = d ./ MAD;

% MAD might be (almost) zero for locally constant data
% there we must punish outliers very hard!
thresh = 1e-2 * median(abs(vals), 2) + 1e-6; % last summand avoids thresh = 0
I = MAD < thresh;
z(I) = 1e2 * d(I);

% compute outlier indicator oI (N x 1), and disregard small values of oI
minimalRequiredNormalizedDeviation = 1;
oI = max(z - minimalRequiredNormalizedDeviation, 0);

end
