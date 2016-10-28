function qqplot(o)
% quantile-quantile of misorientation angle against random angular
% misorientation
%
% Example
%   cs = crystalSymmetry('-43m');
%   odf1 = unimodalODF(orientation.id(cs),'halfwidth',20*degree);
%   odf2 = unimodalODF(orientation.id(cs),'halfwidth',50*degree);
%
%   qqplot(odf1.calcOrientations(1000))
%   qqplot(odf2.calcOrientations(1000))
% 

angles = o.angle;
[pdf,omegas] = calcAngleDistribution(o.CS,o.SS);

pdf = cumsum(pdf);
pdf = pdf./pdf(end);

omegas(pdf == 0) = [];
pdf(pdf == 0) = [];

mof = cumsum(hist(angles,omegas));
mof = mof./mof(end);

figure
plot(pdf,mof,'.')
line([0 1],[0 1])

axis equal tight 
