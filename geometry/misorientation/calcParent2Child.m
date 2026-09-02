function [p2c, omega] = calcParent2Child(mori,p2c,varargin)
%
% Syntax
%
%   p2c = calcParent2Child(childOri,p2c0)
%
%   p2c = calcParent2Child(c2c,p2c0)
%   p2c = calcParent2Child(c2c,p2c0,'quantile',0.8)
%
%   % start the iteration at p2c0 instead of searching the fundamental zone
%   p2c = calcParent2Child(c2c,p2c0,'local')
%
%   [p2c, fit] = calcParent2Child(c2c,p2c0)
%
% Input
%  childOri - child @orientation
%  c2c      - child to child mis@orientation
%  p2c0     - initial guess of the parent to child orientation relationship
%
% Output
%  p2c      - parent to child orientation relationship
%  fit      - disorientation angle between all c2c misorientations and the computed one
%
% Options
%  local        - iterate from p2c0 only, skipping the fundamental zone scan
%  maxIteration - maximum number of iterations (default - 30)
%  quantile     - fraction of the misorientations the fit is based on (default 0.9)
%  threshold    - misorientations misfitting by more are treated as outliers (default - inf)
%  maxSample    - fit on at most this many misorientations (default - 50000)
%  searchResolution - grid resolution of the global scan (default - 4*degree)
%  scanSample   - misorientations used to rank basins during the scan (default - 250)
%  numLocal     - basins of the scan that are fitted locally (default - 5)
%
% References
%
% * Tuomo Nyyssönen, <https://www.researchgate.net/deref/http%3A%2F%2Fdx.doi.org%2F10.1007%2Fs11661-018-4904-9?_sg%5B0%5D=gRJGzFvY4PyFk-FFoOIj2jDqqumCsy3e8TU6qDnJoVtZaeUoXjzpsGmpe3TDKsNukQYQX9AtKGniFzbdpymYvzYwhg.5jfOl5Ohgg7pW_6yACRXN3QiR-oTn8UsxZjTbJoS_XqwSaaB7r8NgifJyjSES2iXP6iOVx57sy8HC4q2XyZZaA
% Crystallography, Morphology, and Martensite Transformation of Prior
% Austenite in Intercritically Annealed High-Aluminum Steel>
%
% * objective, algorithm and convergence: docs/adr/0005-parent-to-child-fit.md
%

% compute misorientations if pairs of orientations are given
if isa(mori.SS, 'specimenSymmetry'), mori = inv(mori(:,1)) .* mori(:,2); end

threshold = get_option(varargin,'threshold',inf);
quant = get_option(varargin,'quantile',0.9);
maxIt = get_option(varargin,'maxIteration',30);

% outliers are capped, not dropped, so that the misfit stays a function of p2c alone
tau = 1 - cos(min(threshold,pi));

% subsample once - redrawing inside the loop would make successive misfits incomparable
moriAll = mori;
mori = subSample(mori,get_option(varargin,'maxSample',50000));
h = ceil(quant * length(mori));

vdisp(' ',varargin{:});
vdisp(' optimizing parent to child orientation relationship',varargin{:});

% the iteration is local, so a bad p2c0 costs more than the scan does
if ~check_option(varargin,'local')
  p2c = globalSearch(mori,p2c,h,tau,varargin{:});
end

fitState = misfit(mori,p2c,h,tau);
report(p2c,fitState.fit,varargin{:});

for k = 1:maxIt

  % every misorientation together with its variant is a measurement of p2c
  pTrial = voteMean(mori,p2c,fitState);
  if isempty(pTrial), break; end

  % the update is a fixed point step, not a descent step - backtrack until it descends
  % ties are accepted, otherwise rounding at a flat minimum stops the step test early
  s = 1; ok = fitState.fit * (1 + 1e-9);
  while true
    pNew = mean([p2c,pTrial],'weights',[1-s s]);
    newState = misfit(mori,pNew,h,tau);
    if newState.fit <= ok || s < 2^-6, break; end
    s = s/2;
  end

  if newState.fit > ok, break; end

  step = angle(pNew,p2c);
  p2c = pNew; fitState = newState;
  report(p2c,fitState.fit,varargin{:});

  if step < 0.01*degree, break; end

end

vdisp(' ',varargin{:});

if nargout > 1
  s = misfit(moriAll,p2c,length(moriAll),tau);
  omega = s.omega;
end

end

% ---------------------------------------------------------------------------------

function s = misfit(mori,p2c,h,tau)
% trimmed chordal misfit of mori to the c2c variants of p2c, plus the inlier assignment

% the identity variant is c2c = id whatever p2c is, so it fits nothing and only damps
s.pVariants = p2c.variants;
s.c2c = p2c * inv(s.pVariants); %#ok<MINV>
isId = angle(s.c2c) < 1e-3*degree;
s.pVariants(isId) = []; s.c2c(isId) = [];

[s.omega, s.variant] = min(angle_outer(mori,s.c2c),[],2);
r = min(1-cos(s.omega),tau);

% cut on the residual value, not on the rank - ties would make the inlier set order dependent
rs = sort(r);
s.ind = r <= rs(min(h,numel(rs)));
s.fit = mean(r(s.ind));
s.ind = s.ind & r < tau;

end

% ---------------------------------------------------------------------------------

function p2c = globalSearch(mori,p2c,h,tau,varargin)
% scan the misorientation fundamental zone, then locally fit the best basins

res = get_option(varargin,'searchResolution',4*degree);
nBasin = get_option(varargin,'numLocal',5);

% the scan only has to rank basins, so a subsample is enough
sub = subSample(mori,get_option(varargin,'scanSample',250));
hSub = max(1,ceil(h / length(mori) * length(sub)));

g = orientation(equispacedSO3Grid(p2c.CS,p2c.SS,'resolution',res));
g = [p2c; reshape(g,[],1)];

% conjugating the parent group directly avoids a variants call per grid point - the
% duplicates that variants would remove cannot change a minimum over the variants
S = p2c.CS.properGroup.rot;
S = reshape(S(angle(S) > 1e-3*degree),1,[]);

vdisp(['  scanning ' int2str(length(g)) ' orientations'],varargin{:});

% grid points in blocks, sized so that the residual matrix stays a few million entries
fit = zeros(length(g),1);
block = max(1,round(2e6 / (length(sub)*length(S))));
for a = 1:block:length(g)

  b = min(a+block-1,length(g));
  q = reshape(quaternion(g(a:b)),[],1);
  c2c = orientation(reshape(q .* inv(S) .* inv(q),[],1),p2c.SS,p2c.SS); %#ok<MINV>

  omega = min(reshape(angle_outer(sub,c2c),length(sub),b-a+1,[]),[],3);
  r = sort(min(1-cos(omega),tau),1);
  fit(a:b) = mean(r(1:hSub,:),1).';

end

% always fit from p2c0 too, so that the search can never do worse than 'local'
% then the best grid basins, well separated so that one is not fitted twice
[~,order] = sort(fit);
seed = p2c;
for j = order(:).'
  if length(seed) >= nBasin + 1, break; end
  if min(angle(seed,g(j))) > res, seed = [seed; g(j)]; end %#ok<AGROW>
end

% iterating a candidate only has to reach its basin, so it may use a subsample - but
% every candidate is scored on all the data, and the caller refines the winner there
opt = [varargin,{'local','silent'}];
pSub = subSample(mori,3000);

best = inf;
for j = 1:length(seed)
  pj = calcParent2Child(pSub,seed(j),opt{:});
  s = misfit(mori,pj,h,tau);
  if s.fit < best, best = s.fit; p2c = pj; end
end

end

% ---------------------------------------------------------------------------------

function mori = subSample(mori,n)
% deterministic stand in for a random subsample
%
% a random draw would make two calls on the same data disagree, and picking every
% k-th row would make the answer depend on the row order - striding an angle sorted
% list depends only on the misorientations themselves and spans their distribution

if length(mori) <= n, return; end

[~,order] = sort(angle(mori));
mori = mori(order(unique(round(linspace(1,length(mori),n)))));

end

% ---------------------------------------------------------------------------------

function p = voteMean(mori,p2c,s)
% chordal mean of the votes mori * p2c * S, one per inlier misorientation

votes = [];
for iv = 1:length(s.pVariants)
  sel = s.ind & s.variant == iv;
  if ~any(sel), continue; end
  votes = [votes; project2FundamentalRegion(mori(sel),s.c2c(iv)) * s.pVariants(iv)]; %#ok<AGROW>
end

if isempty(votes), p = []; else, p = mean(votes,'q0',p2c); end

end

% ---------------------------------------------------------------------------------

function report(p2c,fit,varargin)

vdisp(['  ' fillStr(char(p2c,'Euler'),22) xnum2str(acos(1-fit)./degree)],varargin{:})

end
