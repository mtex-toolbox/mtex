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

rng(0)

bw = 10;
f = SO3FunHarmonic(SO3Fun.dubna,'bandwidth',bw);

opt = {'bandwidth',bw};

% ------------------- the memory has to buy accuracy ----------------------
oriGD = optimalSample(f,20,opt{:},'maxIter',10,'method','steepestDescent');
oriQN = optimalSample(f,20,opt{:},'maxIter',10);

resGD = discrepancy(f,oriGD,[],bw);
resQN = discrepancy(f,oriQN,[],bw);

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
assert(discrepancy(f,ori,c,bw) < discrepancy(f,ori,[],bw), ...
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


function res = discrepancy(f,ori,c,bw)
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


function res = discrepancyS2(sF,v,c,bw)
% the same functional on the sphere, see S2Fun/optimalSample

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
