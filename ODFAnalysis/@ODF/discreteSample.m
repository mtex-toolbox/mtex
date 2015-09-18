function ori = discreteSample(odf,npoints,varargin)
% draw a random sample
%
%

ori = orientation.id(npoints,1,odf.CS,odf.SS);

% which component
if numel(odf.weights) == 1
  icmp = ones(size(ori));
else
  icmp = discretesample(odf.weights,npoints);
end

% compute discrete sample for each component seperately
for ic = 1:length(odf.components)
  
  ori(icmp == ic) = discreteSample(odf.components{ic},sum(icmp==ic),varargin{:});
  
end
  