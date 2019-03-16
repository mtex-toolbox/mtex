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


%%


rot1 = rotation.byAxisAngle(xvector,30*degree)
rot2 = rotation.byAxisAngle(vector3d(1,2,3),30*degree)

% the matrix is flipped !!
matrix(rot1)
tensor(rot1)

%%

% the spin tensor
spin = spinTensor(rot2)

% the spin vector
v = vector3d(spin)
v = log(rot2)

%% go back to rotation

% to compare with
rot2

exp(spin)
rotation(expquat(v))


end


function test
  % some testing code

  cs = crystalSymmetry('321');
  ori1 = orientation.rand(cs);
  ori2 = orientation.rand(cs);

  v = log(ori2,ori1);

  % this should be the same
  [norm(v),angle(ori1,ori2)] ./ degree

  % and this too
  [ori1 * orientation.byAxisAngle(v,norm(v)) ,project2FundamentalRegion(ori2,ori1)]

  % in specimen coordinates
  r = log(ori2,ori1,'left');

  % now we have to multiply from the left
  [rotation.byAxisAngle(r,norm(v)) * ori1 ,project2FundamentalRegion(ori2,ori1)]

  % the following output should be constant
  % gO = log(ori1,ori2.symmetrise) % but not true for this
  % gO = log(ori1.symmetrise,ori2) % true for this
  %
  % gO = ori2.symmetrise .* log(ori1,ori2.symmetrise) % true for this
  % gO = ori2 .* log(ori1.symmetrise,ori2) % true for this

end










