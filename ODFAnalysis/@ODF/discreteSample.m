function ori = discreteSample(odf,npoints,varargin)
% draw a random sample
%
%

% preallocate orientations
q = quaternion.id(npoints,1);

% which component
if numel(odf.weights) == 1
  icmp = ones(size(q));
else
  icmp = discretesample(odf.weights,npoints);
end

% compute discrete sample for each component seperately
for ic = 1:length(odf.components)
  q(icmp == ic) = discreteSample(odf.components{ic},sum(icmp==ic),varargin{:});  
end

% take random symmetrically equivalent samples
cs = odf.CS.properGroup;
ss = odf.SS.properGroup;
ics = discretesample(length(cs),npoints,1);
iss = discretesample(length(ss),npoints,1);

ori = orientation(ss(iss(:)) .* q .* cs(ics(:)),odf.CS,odf.SS);