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
qcs = reshape(quaternion(odf.CS.properGroup),[],1);
qss = reshape(quaternion(odf.SS.properGroup),[],1);
ics = discretesample(length(qcs),npoints,1);
iss = discretesample(length(qss),npoints,1);

ori = orientation(qss(iss(:)) .* q .* qcs(ics(:)),odf.CS,odf.SS);

% the antipodal case
if  odf.antipodal
  ori.antipodal =true;
  doInv = 1==discretesample(2,npoints,1);
  ori(doInv)=inv(ori(doInv));
end