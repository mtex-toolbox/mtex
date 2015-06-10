function qqplot(o)
% quantile-quantile of misorientation angle against random angular
% misorientation
%
% Example
%
%     qqplot(SO3Grid(2.5*degree,crystalSymmetry('m-3m')))
%

angles = o.angle;
[pdf,omegas] = o.CS.angleDistribution;

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
