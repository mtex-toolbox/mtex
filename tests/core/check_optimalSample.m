function check_optimalSample
% optimalSample has to use the curvature it collects, and keep its contracts
%
% The functional that optimalSample minimizes is badly conditioned - in a
% minimizer of a 92 point sample of SO3Fun.dubna the Hessian has a condition
% number of about 2000 - which is why the orientations are moved by a limited
% memory BFGS iteration and not by gradient descent. That is a property no
% caller can see directly: if the secant pairs stop being used the function
% still returns a plausible sample, only a worse one.
%
% 'method','steepestDescent' selects the plain gradient descent that
% optimalSample used before - it reproduces it to 6e-6 degree - so it is the
% control the comparisons below are made against.
%
% The last cases cover S2Fun/optimalSample, which runs the same iteration on
% the sphere - there the weights are no separate step but a softmax block of
% the very same L-BFGS iteration. This file owns both.
%
% See also
% SO3Fun/optimalSample S2Fun/optimalSample SO3RestrictedDistanceKernel

checkS2Discrepancy;
checkStandardDiscrepancies;

rng(0)

bw = 10;
f = SO3FunHarmonic(SO3Fun.dubna,'bandwidth',bw);

opt = {'bandwidth',bw};

% ------------------- the memory has to buy accuracy ----------------------
oriGD = optimalSample(f,20,opt{:},'maxIter',10,'method','steepestDescent');
oriQN = optimalSample(f,20,opt{:},'maxIter',10);

resGD = discrepancySO3(f,oriGD,[],bw);
resQN = discrepancySO3(f,oriQN,[],bw);

% The measured ratio is 0.67 to 0.75 here and stays around 0.7 for every
% larger bandwidth and iteration budget tried, so 0.9 is a threshold that
% only a broken memory can cross - on a tree without the L-BFGS iteration
% 'method' is an unknown option and both calls return the same sample, i.e.
% the ratio is exactly 1. Keep the sample well above the M = 8 that a smaller
% n gives: with that few nodes the ratio jumps between 0.73 and 0.93.
assert(resQN < 0.9*resGD, ...
  ['optimalSample is no better than gradient descent - discrepancy %.4e ' ...
  'against %.4e for ''method'',''steepestDescent''. The curvature collected ' ...
  'in the secant pairs is not reaching the search direction.'],resQN,resGD)

% ---------------- the weights form a probability distribution ------------
[ori,c] = optimalSample(f,20,opt{:},'maxIter',4);

assert(numel(c) == numel(ori), ...
  'optimalSample returned %d weights for %d orientations.',numel(c),numel(ori))

assert(all(c >= 0), ...
  'optimalSample returned a negative weight, the smallest one is %.3e.',min(c))

assert(abs(sum(c)-1) < 1e-10, ...
  'The weights of optimalSample sum up to %.12f instead of 1.',sum(c))

% the weighted sample has to be the better one - that is what the weights
% are optimized for
assert(discrepancySO3(f,ori,c,bw) < discrepancySO3(f,ori,[],bw), ...
  'The optimized weights of optimalSample do not decrease the discrepancy.')

% ------------- a warm up must not swallow the weight step ----------------
% The orientations may converge before the warm up is over. Since the weights
% are held fixed during the warm up, the termination test then compares them
% against themselves and is satisfied, and optimalSample would return the
% equal weights the caller explicitly asked to have optimized - silently, and
% the more reliably the faster the orientation step is.
[~,cWarm] = optimalSample(f,20,opt{:},'maxIter',12,'tol',2*degree,'warmUp',10);

assert(max(abs(cWarm-1/numel(cWarm))) > 1e-6, ...
  ['optimalSample returned the equal weights 1/M although the weights were ' ...
  'asked for. The iteration terminated inside the warm up, before a single ' ...
  'weight step had run.'])

assert(abs(sum(cWarm)-1) < 1e-10, ...
  'The weights after a warm up sum up to %.12f instead of 1.',sum(cWarm))

% ------------------------- starting nodes --------------------------------
% a given list of orientations is taken as it is, in particular the sample
% keeps its size
ori0 = orientation.byEuler((10:10:50).'*degree,20*degree,30*degree,f.CS,f.SS);
ori5 = optimalSample(f,ori0,opt{:},'maxIter',2);

assert(numel(ori5) == numel(ori0), ...
  'optimalSample returned %d orientations for %d starting nodes.', ...
  numel(ori5),numel(ori0))

% a single orientation degenerates every direction the iteration could take -
% the simplex is the point c = 1 and mlsq would divide by a vanishing search
% direction - but it has to come back rather than error
ori1 = optimalSample(f,ori0(1),opt{:},'maxIter',2);

assert(numel(ori1) == 1, ...
  'optimalSample returned %d orientations for a single starting node.', ...
  numel(ori1))

% --------------------- the same on the sphere ----------------------------
% S2Fun/optimalSample runs the same iteration along the geodesics of the
% sphere. There the tangent plane turns with the node, so the stored pairs
% have to be parallel transported along every step - if that transport is
% wrong the pairs are added up across different tangent planes and the
% memory becomes worse than useless, which this case would see.
sF = S2FunHandle(@(x) real( exp(-5*acos(dot(x,xvector)).^2) ...
  + exp(-5*acos(dot(x,yvector)).^2) + exp(-5*acos(dot(x,zvector)).^2) ));

vGD = optimalSample(sF,100,'bandwidth',32,'maxIter',20,'method','steepestDescent');
vQN = optimalSample(sF,100,'bandwidth',32,'maxIter',20);

% the nodes have to stay on the sphere - the geodesic step is what keeps
% them there, and a direction that is not tangential would leave it
assert(max(abs(norm(vQN)-1)) < 1e-12, ...
  'optimalSample moved a direction off the sphere by %.3e.', ...
  max(abs(norm(vQN)-1)))

resGD = discrepancyS2(sF,vGD,[],32);
resQN = discrepancyS2(sF,vQN,[],32);

% measured at 0.49 here, and between 0.40 and 0.84 over the bandwidths,
% sample sizes and iteration budgets tried
assert(resQN < 0.9*resGD, ...
  ['S2Fun/optimalSample is no better than gradient descent - discrepancy ' ...
  '%.4e against %.4e for ''method'',''steepestDescent''.'],resQN,resGD)

% ------------------- an antipodal density, the same ----------------------
% Pole figures are antipodal, and for an antipodal vector3d dot returns the
% absolute value - so the projection that keeps the search direction in the
% tangent plane silently added the radial part instead of removing it. Only
% the quasi Newton direction is affected, gradient descent is tangential
% anyway, hence the same comparison sees it. It takes a sharp function and a
% bandwidth of 64 to bite: below that both runs are bit identical, here the
% unfixed one ends up 80 times worse than gradient descent.
sFa = S2FunHandle(@(x) exp(150*(dot(x,vector3d(1,2,3),'noAntipodal')./sqrt(14)).^2) ...
  + exp(150*(dot(x,vector3d(1,-1,0),'noAntipodal')./sqrt(2)).^2));
sFa.antipodal = true;

aGD = optimalSample(sFa,200,'bandwidth',64,'maxIter',100,'method','steepestDescent');
aQN = optimalSample(sFa,200,'bandwidth',64,'maxIter',100);

resGDa = discrepancyS2(sFa,aGD,[],64);
resQNa = discrepancyS2(sFa,aQN,[],64);

% measured at 0.012 with the projection and 0.25 without it
assert(resQNa < 0.1*resGDa, ...
  ['S2Fun/optimalSample does not use its memory on an antipodal function - ' ...
  'discrepancy %.4e against %.4e for gradient descent. The search direction ' ...
  'is not tangential.'],resQNa,resGDa)

% ---------------- the weights on the sphere, same contracts --------------
[vw,cw] = optimalSample(sF,100,'bandwidth',32,'maxIter',20);

assert(numel(cw) == numel(vw), ...
  'S2Fun/optimalSample returned %d weights for %d directions.', ...
  numel(cw),numel(vw))

assert(all(cw >= 0) && abs(sum(cw)-1) < 1e-10, ...
  ['The weights of S2Fun/optimalSample are no probability distribution - ' ...
  'smallest %.3e, sum %.12f.'],min(cw),sum(cw))

assert(discrepancyS2(sF,vw,cw,32) < discrepancyS2(sF,vw,[],32), ...
  'The optimized weights of S2Fun/optimalSample do not decrease the discrepancy.')

% ------------- a warm up must not swallow the weight step ----------------
% the same trap as on SO(3) above, and one the softmax block falls into in
% its own way: the gradient the L-BFGS iteration carries over from the warm
% up has no weight component yet, so a weight step that starts from it moves
% nothing and the termination test right after it is satisfied again
[~,cWarmS2] = optimalSample(sF,100,'bandwidth',32,'maxIter',12, ...
  'tol',2*degree,'warmUp',10);

assert(max(abs(cWarmS2-1/numel(cWarmS2))) > 1e-6, ...
  ['S2Fun/optimalSample returned the equal weights 1/M although the weights ' ...
  'were asked for. The iteration terminated as the warm up ended, before the ' ...
  'weights had moved once.'])

end


function res = discrepancySO3(f,ori,c,bw)
% the functional optimalSample minimizes: the squared norm of mu - f, taken
% degreewise in the Chebyshev coefficients of the restricted distance kernel
% and with degree 0 - the one with a negative coefficient - dropped

if isempty(c), c = ones(numel(ori),1)/numel(ori); end

psi = SO3RestrictedDistanceKernel(bw+1);
lambda = sum(f);

w = zeros(deg2dim(bw+1),1);
for l = 1:bw
  w(deg2dim(l)+1:deg2dim(l+1)) = sqrt( 8*pi^2 * psi.A(l+1)/(2*l+1) );
end

mu = SO3FunHarmonic.adjointNFSOFT(ori,c(:)/sum(c),'bandwidth',bw);
mu.bandwidth = bw;

D = (lambda/(sqrt(8)*pi)) * mu - (sqrt(8)*pi) * f;
D.bandwidth = bw;

res = sum(abs(w.*D.fhat).^2);

end

function checkS2Discrepancy
% The public pairwise API agrees with independent spectral/spatial formulas.
rng(23);
bw = 6;
v = reshape(vector3d.rand(12,1),3,4);
u = vector3d.rand(7,1);
c = (1:12).'; d = (7:-1:1).';
c = c/sum(c); d = d/sum(d);
opts = {'bandwidth',bw,'weights',c,'weights2',d};
actual = legacyMetric(v,u,opts{:});
expected = c.'*restrictedKernel(dot(v(:),v(:).'),bw)*c + ...
  d.'*restrictedKernel(dot(u,u.'),bw)*d - ...
  2*c.'*restrictedKernel(dot(v(:),u.'),bw)*d;
assert(abs(actual-expected)<1e-10,'Point discrepancy differs from its spatial kernel.');
assert(abs(actual-legacyMetric(u,v,'weights',d,'weights2',c,'bandwidth',bw))<1e-12);
assert(abs(actual-legacyMetric(v,u,'weights',10*c,'weights2',3*d,'bandwidth',bw))<1e-12);
assert(legacyMetric(v,v,'bandwidth',bw)<1e-20);
assert(abs(legacyMetric(v,u)-legacyMetric(v,u,'bandwidth',128))<1e-12);

mu = S2FunHarmonic.adjointNFSFT(v(:),c,'bandwidth',bw); mu.bandwidth = bw;
nu = S2FunHarmonic.adjointNFSFT(u,d,'bandwidth',bw); nu.bandwidth = bw;
assert(abs(actual-legacyMetric(mu,nu,'bandwidth',bw))<1e-10);
assert(abs(actual-legacyMetric(mu,u,'weights',d,'bandwidth',bw))<1e-10);
assert(abs(actual-legacyMetric(u,mu,'weights',d,'bandwidth',bw))<1e-10);

% The maximum of the two bandwidths is the symmetric default for functions.
f = S2FunHarmonic([1/sqrt(4*pi);0;0.03;0]);
g = f; g.bandwidth = 4; g.fhat(21) = 0.02;
expected = 16*pi/(7*9*11)*0.02^2;
assert(abs(legacyMetric(f,g)-expected)<1e-14);
assert(abs(legacyMetric(g,f)-expected)<1e-14);
assert(legacyMetric(f,g,'bandwidth',1)<1e-20);
assert(legacyMetric(f,f)<1e-20);
assert(abs(legacyMetric(3*f,3*g)-9*expected)<1e-13);
fHandle = S2FunHandle(@(x) f.eval(x));
assert(abs(legacyMetric(fHandle,g,'bandwidth',4)-expected)<1e-10);
assert(abs(legacyMetric(fHandle,g)-legacyMetric(fHandle,g,'bandwidth',128))<1e-12);

% Normalized handles remain comparable even if coarse quadrature changes
% their constant terms by different amounts.
p = S2FunHandle(@(x) exp(3*x.z)); p = p/sum(p);
q = S2FunHandle(@(x) exp(3*x.x)); q = q/sum(q);
coarse = legacyMetric(p,q,'bandwidth',4);
assert(isfinite(coarse) && coarse>0);
assert(abs(coarse-legacyMetric(q,p,'bandwidth',4))<1e-10);

% An even target must not hide the odd part of another function.
uniform = S2FunHarmonic(1/sqrt(4*pi));
assert(abs(legacyMetric(uniform,f)-16*pi/15*0.03^2)<1e-14);
assert(abs(legacyMetric(f,uniform)-legacyMetric(uniform,f))<1e-14);

% Preserve the old density/sample functional, scaling, and antipodal behavior.
for target = {f,uniform}
  sF = target{1};
  old = discrepancyS2(sF,v,c,bw);
  assert(abs(legacyMetric(sF,v,'weights',c,'bandwidth',bw)-old)<1e-12);
  assert(abs(legacyMetric(v,sF,'weights',c,'bandwidth',bw)-old)<1e-12);
  assert(abs(legacyMetric(3*sF,v,'weights',c,'bandwidth',bw)-9*old)<1e-11);
end

% Antipodal point measures equal explicit +/- copies of their support.
va = v(:); ua = u; va.antipodal = true; ua.antipodal = true;
axial = legacyMetric(va,ua,'weights',c,'weights2',d,'bandwidth',bw);
copies = legacyMetric([v(:);-v(:)],[u;-u], ...
  'weights',[c;c]/2,'weights2',[d;d]/2,'bandwidth',bw);
assert(abs(axial-copies)<1e-10);
rot = rotation.rand;
assert(abs(actual-legacyMetric(rot.*v,rot.*u,opts{:}))<1e-10);
assert(legacyMetric(v,u,'bandwidth',0)==0);

% Equal spectral weights give the genuine squared norm of the bandlimited
% difference, including odd degrees when a directed sample meets an even f.
assert(abs(legacyMetric(f,g,'metric','L2','squared')-norm(f-g)^2)<1e-14);
l2 = sum(abs(mu.fhat(2:end)-nu.fhat(2:end)).^2);
assert(abs(legacyMetric(v,u,opts{:},'metric','L2','squared')-l2)<1e-10);
assert(abs(legacyMetric(mu,nu,'metric','L2','squared','bandwidth',bw)-l2)<1e-10);
assert(abs(legacyMetric(mu,u,'weights',d,'metric','L2','squared','bandwidth',bw)-l2)<1e-10);
assert(abs(legacyMetric(u,mu,'weights',d,'metric','L2','squared','bandwidth',bw)-l2)<1e-10);
assert(abs(legacyMetric(uniform,vector3d.Z,'metric','L2','squared','bandwidth',1)-3/(4*pi))<1e-12);
assert(legacyMetric(uniform,vector3d.Z,'metric','kernel','bandwidth',1)==0);
assert(legacyMetric(v,u,opts{:},'metric','kernel')==actual);
assert(legacyMetric(v,u,'metric','L2','squared','bandwidth',0)==0);
assert(legacyMetric(f,f,'metric','L2','squared')==0);
mustReject(@() legacyMetric(f,g,'metric','unknown'),'S2Fun:discrepancy:metric');
mustReject(@() legacyMetric(v,u,'metric','unknown','bandwidth',0), ...
  'S2Fun:discrepancy:metric');

mustReject(@() legacyMetric(f,2*g),'S2Fun:discrepancy:massMismatch');
mustReject(@() legacyMetric(v,u,'bandwidth',-1),'S2Fun:discrepancy:bandwidth');
mustReject(@() legacyMetric(v,u,'weights',zeros(12,1)), ...
  'S2Fun:discrepancy:weights');
mustReject(@() legacyMetric(v,vector3d),'S2Fun:discrepancy:emptySample');
end

function k = restrictedKernel(t,bw)
% Independent finite Legendre expansion, with the negative constant omitted.
previous = ones(size(t)); current = t; k = zeros(size(t));
for l = 1:bw
  k = k + 4/((2*l-1)*(2*l+3))*current;
  next = ((2*l+1)*t.*current-l*previous)/(l+1);
  previous = current; current = next;
end
end

function mustReject(fun,id)
try
  fun();
catch err
  assert(strcmp(err.identifier,id),'Unexpected error: %s',err.message);
  return
end
error('Expected error %s.',id);
end

function res = discrepancyS2(sF,v,c,bw)
% the same functional on the sphere, see S2Fun/optimalSample. S2Fun/discrepancy
% computes it as well - this stays a copy on purpose, so that the assertions
% above measure the shipped code against something that is not the shipped code

if isempty(c), c = ones(numel(v),1)/numel(v); end

sF = S2FunHarmonic(sF,'bandwidth',bw);
sF.bandwidth = bw;

psi = S2RestrictedDistanceKernel(bw+1);
if sF.antipodal, psi.A(2:2:end) = 0; end
lambda = sum(sF);

w = zeros((bw+1)^2,1);
for l = 1:bw
  w(l^2+1:(l+1)^2) = sqrt( 4*pi * psi.A(l+1)/(2*l+1) );
end

mu = S2FunHarmonic.adjointNFSFT(v(:),c(:)/sum(c),'bandwidth',bw);
mu.bandwidth = bw;

D = sF;
D.fhat = lambda * mu.fhat - sF.fhat;

res = sum(abs(w.*D.fhat).^2);

end

function res = legacyMetric(a,b,varargin)
if ~check_option(varargin,'metric'), varargin = [varargin,{'metric','kernel'}]; end
res = discrepancy(a,b,varargin{:});
end

function checkStandardDiscrepancies
% Analytic cases fix the cap measure, square-root convention and atomic tail.
u = S2FunHarmonic(1/sqrt(4*pi));
z = vector3d.Z; x = vector3d.X;
assert(abs(discrepancy(u,z)-sqrt(1/3))<1e-12);
assert(abs(discrepancy(u,z,'squared')-1/3)<1e-12);
assert(abs(discrepancy(z,-z)-1)<1e-12);
assert(abs(discrepancy(z,x,'squared')-sqrt(2)/2)<1e-12);
assert(abs(discrepancy(z,x,'bandwidth',0)-discrepancy(z,x,'bandwidth',8))<1e-12);
assert(discrepancy(z,z)==0);
a = z; a.antipodal = true;
assert(abs(discrepancy(u,a,'squared')-1/12)<1e-12);
assert(abs(discrepancy(u,a)-discrepancy(u,[z;-z]))<1e-12);
assert(abs(discrepancy(3*u,z)-3*discrepancy(u,z))<1e-12);

% f-u = alpha*z: cap integral is pi*alpha*m.z*(1-t^2).
alpha = 0.03;
f = S2FunHarmonic([1/sqrt(4*pi);0;alpha*sqrt(4*pi/3);0]);
assert(abs(discrepancy(f,u,'squared')-16*pi^2*alpha^2/45)<1e-12);
assert(abs(discrepancy(f,u,'metric','L2')-alpha*sqrt(4*pi/3))<1e-12);
assert(abs(discrepancy(f,u,'metric','L2','degreeWeights',[0;4])- ...
  2*discrepancy(f,u,'metric','L2'))<1e-12);
assert(abs(discrepancy(f,u,'metric','E_L','degreeWeights',@(l) 1./(1+l.*(l+1)))- ...
  discrepancy(f,u,'metric','L2')/sqrt(3))<1e-12);
% Mixed D2 agrees with an independent continuous-discrete calculation.
expected = 1/3 + 16*pi^2*alpha^2/45 - 8*pi*alpha/15;
assert(abs(discrepancy(f,z,'squared')-expected)<1e-12);
assert(abs(discrepancy(z,f)-discrepancy(f,z))<1e-12);

cap = {'metric','D_cap','numCenters',17,'numHeights',17};
[d,info] = discrepancy(f,u,cap{:});
assert(abs(d-pi*alpha)<1e-12 && ~info.isExact);
assert(abs(info.signedDifference)==d);
assert(abs(discrepancy(u,z,cap{:})-1)<1e-12);
assert(abs(discrepancy(z,-z,cap{:})-1)<1e-12);
assert(discrepancy(z,z,cap{:})==0);
assert(abs(discrepancy(u,a,cap{:})-0.5)<1e-12);
assert(abs(discrepancy(3*f,3*u,cap{:})-3*d)<1e-12);
assert(abs(discrepancy(f,u,cap{:},'squared')-d^2)<1e-12);
assert(abs(discrepancy(u,f,cap{:})-d)<1e-12);
assert(discrepancy(f,u,'metric','D_cap','centers',x)<1e-12);
% Tied atoms must move together, so interleaving + and - weights cannot
% create a discrepancy between identical weighted measures.
assert(discrepancy([z;z;x],[x;z],cap{:},'weights',[1;1;2],'weights2',[1;1])<1e-12);

rng(42); v = vector3d.rand(8,1); w = vector3d.rand(6,1);
c = (1:8).'; c = c/sum(c); e = (1:6).'; e = e/sum(e);
opts = {'weights',c,'weights2',e};
actual = discrepancy(v,w,opts{:},'squared');
spatial = @(a,b) sqrt(max(0,2-2*dot(a,b.')));
vv = spatial(v,v); vv(1:9:end) = 0;
ww = spatial(w,w); ww(1:7:end) = 0;
expected = (2*c.'*spatial(v,w)*e-c.'*vv*c-e.'*ww*e)/4;
assert(abs(actual-expected)<1e-12);
r = rotation.rand;
assert(abs(actual-discrepancy(r.*v,r.*w,opts{:},'squared'))<1e-12);
assert(abs(actual-discrepancy(w,v,'weights',e,'weights2',c,'squared'))<1e-12);
assert(abs(discrepancy(v,w,opts{:},cap{:})- ...
  discrepancy(w,v,'weights',e,'weights2',c,cap{:}))<1e-12);
% Truncated kernel converges to full point energy from below, without its
% factor four; a finite truncation must not be labelled exact atomic D2.
k4 = discrepancy(v,w,opts{:},'metric','kernel','bandwidth',4)/4;
k16 = discrepancy(v,w,opts{:},'metric','kernel','bandwidth',16)/4;
assert(k4<k16 && k16<actual);
for metric = {'D_2','D_cap','L2'}
  mustReject(@() discrepancy(f,2*u,'metric',metric{1}), ...
    'S2Fun:discrepancy:massMismatch');
end
mustReject(@() discrepancy(f,u,'metric','L2','degreeWeights',[1;-1]), ...
  'S2Fun:discrepancy:degreeWeights');
mustReject(@() discrepancy(v,w,'metric','D_cap','numHeights',1), ...
  'S2Fun:discrepancy:capGrid');
end
