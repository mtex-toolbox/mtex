function check_explog(varargin)
% test log, exp, grad

% define some crystal symmetry
cs = crystalSymmetry('432');
n = 1000;
o1 = orientation.rand(cs,n);
o2 = orientation.rand(cs,n);

% check log and exp in crystal coordinates
v1 = log(o2,o1);
assert(max(abs(angle(o2,exp(o1,v1))))<1e-5)

% check log and exp in specimen coordinates
v2 = log(o2,o1,'left');
assert(max(abs(angle(o2,exp(o1,v2,'left'))))<1e-5)

% check gradient
o1 = orientation.rand(cs,1);
o2 = orientation.rand(cs,10000);
id = find(angle(o1,o2)<10*degree,1);
o2 = o2(id);

odf = unimodalODF(o1,'halfwidth',20*degree);

v = normalize(grad(odf,o2));
angle(normalize(log(o1,o2)),v)
o2.exp(normalize(v)*5*degree)

omega = linspace(0,10*degree);
plot(omega./degree,odf.eval(o2.exp(normalize(v)*omega)))

v = normalize(grad(odf,o2,'left'))
vv = normalize(log(o1,o2,'left'))
o2.exp(normalize(v)*5*degree,'left')
hold on
plot(omega./degree,odf.eval(o2.exp(normalize(v)*omega,'left')))
hold off


%%

vv = -odf.grad(ori,'left');


