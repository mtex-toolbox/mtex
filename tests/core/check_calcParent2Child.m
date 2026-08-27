function check_calcParent2Child
% fitting a parent to child orientation relationship to c2c misorientations

rng(0);
csP = crystalSymmetry('432',[3.66 3.66 3.66],'mineral','fcc');
csC = crystalSymmetry('432',[2.87 2.87 2.87],'mineral','bcc');
p2c = orientation.KurdjumovSachs(csP,csC);

mori = c2cData(p2c,csP,csC,1500,1*degree,0.2);
p2c0 = perturb(p2c,vector3d(1,2,3),3*degree,csP,csC);

checkRecovery(mori,p2c,p2c0);
checkOrderIndependence(mori,p2c0);
checkFitLength(mori,p2c0);
checkDeterminism(mori,p2c0);

end

% ---------------------------------------------------------------------------------

function checkRecovery(mori,p2c,p2c0)

p = calcParent2Child(mori,p2c0,'local','silent');

assert(angle(p,p2c) < 0.3*degree, ...
  sprintf('calcParent2Child recovered the OR only to %.3f degree',angle(p,p2c)/degree));

assert(angle(p,p2c) < angle(p2c0,p2c), ...
  'calcParent2Child did not improve on its starting point');

end

% ---------------------------------------------------------------------------------

function checkOrderIndependence(mori,p2c0)
% the fit averages over a symmetry spread list, so it must not read element 1 as reference

p = calcParent2Child(mori,p2c0,'local','silent');
q = calcParent2Child(mori(randperm(length(mori))),p2c0,'local','silent');

assert(angle(p,q) < 1e-3*degree, ...
  sprintf('calcParent2Child depends on the input order, by %.4f degree',angle(p,q)/degree));

end

% ---------------------------------------------------------------------------------

function checkFitLength(mori,p2c0)
% the misfit is reported per input misorientation, also when the fit subsamples

[~,fit] = calcParent2Child(mori,p2c0,'local','silent');
assert(numel(fit) == length(mori),'calcParent2Child returned %d misfits for %d misorientations',numel(fit),length(mori));

[~,fit] = calcParent2Child(mori,p2c0,'local','maxSample',300,'silent');
assert(numel(fit) == length(mori),'calcParent2Child returned the misfit of the subsample, not of the input');

end

% ---------------------------------------------------------------------------------

function checkDeterminism(mori,p2c0)
% subsampling must not be random, or two calls on the same data disagree

opt = {'searchResolution',10*degree,'numLocal',1,'maxSample',300,'scanSample',100,'silent'};
p = calcParent2Child(mori,p2c0,opt{:});
q = calcParent2Child(mori,p2c0,opt{:});

assert(angle(p,q) == 0,'calcParent2Child gave two different answers for the same input, by %.4f degree',angle(p,q)/degree);

r = calcParent2Child(mori(randperm(length(mori))),p2c0,opt{:});
assert(angle(p,r) < 1e-3*degree,'the subsample depends on the input order, by %.4f degree',angle(p,r)/degree);

end

% ---------------------------------------------------------------------------------

function mori = c2cData(p2c,csP,csC,n,noise,outlierFraction)
% child to child misorientations of n parent grains, each split into two variants

oriParent = orientation.rand(n,csP);

% variants is a row, so index it as a column or the product expands to n × n
V = reshape(p2c.variants,[],1);
o1 = oriParent .* inv(V(randi(length(V),n,1)));
o2 = oriParent .* inv(V(randi(length(V),n,1)));

mori = perturb(inv(o1) .* o2, vector3d.rand(n), noise*randn(n,1), csC, csC);

k = round(outlierFraction*n);
mori(1:k) = orientation.rand(k,csC,csC);
mori(mori.angle < 5*degree) = [];

% a row times a column expands to n × n, and the fit then runs on n^2 pairs
assert(length(mori) <= n,'c2cData produced %d misorientations for n = %d',length(mori),n);

end

% ---------------------------------------------------------------------------------

function o = perturb(o,ax,omega,cs1,cs2)

o = orientation(quaternion(o) .* quaternion(rotation.byAxisAngle(ax,omega)),cs1,cs2);

end
