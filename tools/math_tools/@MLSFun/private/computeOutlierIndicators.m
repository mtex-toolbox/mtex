function oI = computeOutlierIndicators(F)
% outlier indicators, one column per function component
%
% The indicator is the deviation of a value from the median of its
% outlierDetectionRange nearest neighbors, in units of their median
% absolute deviation, minus one. Bigger numbers indicate outliers.

id = F.nodes.find(F.nodes,F.outlierDetectionRange);

gridVals = reshape(F.values(:),numel(F.nodes),numel(F));
oI = zeros(size(gridVals));

for j = 1:numel(F)
  % neighbor values as N × k, linear indexing would return a single column
  vals = reshape(gridVals(id,j),size(id));

  m = median(vals,2);
  MAD = median(abs(vals - m),2);
  d = abs(gridVals(:,j) - m);
  z = d ./ MAD;

  % for (almost) locally constant data the MAD vanishes, punish outliers hard
  I = MAD < 1e-2 * median(abs(vals),2) + 1e-6;
  z(I) = 1e2 * d(I);

  oI(:,j) = max(z - 1,0);
end

if isscalar(F), oI = oI(:); end

end
