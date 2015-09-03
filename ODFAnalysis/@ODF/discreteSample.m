function ori = discreteSample(odf,npoints,varargin)
% draw a random sample
%
%

ori = orientation.id(npoint,odf.CS,odf.SS);

% which component
icmp = discretesample(odf.weights,npoints);

% compute discrete sample for each component seperately
for ic = 1:length(odf.components)
  
  ori(icmp == ic) = discreteSample(odf.components{ic},sum(icmp==ic),varargin{:});
  
end
  