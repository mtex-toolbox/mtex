function ori = discreteSample(odf,npoints,varargin)
% draw a random sample
%

if numel(odf.c) == 1
  ic = ones(npoints,1);
else
  ic = discretesample(odf.c, points);
end
    
axis = randv(npoints,1);
angle = randomSample(odf.psi,npoints);

ori = orientation(quaternion(odf.center,ic) .* axis2quat(axis,angle),odf.CS,odf.SS);
