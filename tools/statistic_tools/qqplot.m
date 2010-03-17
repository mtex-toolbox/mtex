function qqplot(o)
% qqplot(SO3Grid(2.5*degree,symmetry('m-3m')))

h = angle(o);

[pd degr ] = mispdf(get(o,'CS'));
pd = cumsum(pd);
pd = pd./pd(end);

degr(pd == 0) = [];
pd(pd == 0) = [];

n = hist(angle(o),degr*degree);
nn = cumsum(n);
nn = nn./nn(end);

plot(pd,nn,'.-')
line([0 1],[0 1])

axis equal tight 