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
% 'memory',0 empties the L-BFGS memory in every iteration and hence walks
% along the negative gradient throughout. It reproduces the gradient descent
% that optimalSample used before to 6e-6 degree, so it is the control the
% first case compares against.
%
% See also
% SO3Fun/optimalSample SO3RestrictedDistanceKernel

rng(0)

bw = 10;
f = SO3FunHarmonic(SO3Fun.dubna,'bandwidth',bw);

opt = {'bandwidth',bw};

% ------------------- the memory has to buy accuracy ----------------------
oriGD = optimalSample(f,20,opt{:},'maxIter',10,'memory',0);
oriQN = optimalSample(f,20,opt{:},'maxIter',10);

resGD = discrepancy(f,oriGD,[],bw);
resQN = discrepancy(f,oriQN,[],bw);

% The measured ratio is 0.67 to 0.75 here and stays around 0.7 for every
% larger bandwidth and iteration budget tried, so 0.9 is a threshold that
% only a broken memory can cross - on a tree without the L-BFGS iteration
% 'memory' is an unknown option and both calls return the same sample, i.e.
% the ratio is exactly 1. Keep the sample well above the M = 8 that a smaller
% n gives: with that few nodes the ratio jumps between 0.73 and 0.93.
assert(resQN < 0.9*resGD, ...
  ['optimalSample is no better than gradient descent - discrepancy %.4e ' ...
  'against %.4e for ''memory'',0. The curvature collected in the secant ' ...
  'pairs is not reaching the search direction.'],resQN,resGD)

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
