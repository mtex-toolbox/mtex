function qqplot(o)
% quantile-quantile of misorientation angle against random angular
% misorientation
%
% Example
%
%     qqplot(SO3Grid(2.5*degree,symmetry('m-3m')))
%

[o,h] = project2FundamentalRegion(o);
[pdf,omegas] = mispdf(o.CS);

pdf = cumsum(pdf);
pdf = pdf./pdf(end);

omegas(pdf == 0) = [];
pdf(pdf == 0) = [];

mof = hist(h,omegas);
mof = cumsum(hist(h,omegas));
mof = mof./mof(end);

figure
plot(pdf,mof,'.')
line([0 1],[0 1])

axis equal tight 
