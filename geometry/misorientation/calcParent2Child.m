function [p2c, omega] = calcParent2Child(mori,p2c,varargin)
%
% Syntax
%
%   p2c = calcParent2Child(childOri,p2c0)
%
%   p2c = calcParent2Child(c2c,p2c0)
%   p2c = calcParent2Child(c2c,p2c0,'quantile',0.8)
%
%   % search the entire fundamental zone instead of starting from p2c0
%   p2c = calcParent2Child(c2c,p2c0,'global')
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
%  global       - scan the misorientation fundamental zone for the best starting point
%  maxIteration - maximum number of iterations (default - 30)
%  quantile     - fraction of the misorientations the fit is based on (default 0.9)
%  threshold    - misorientations misfitting by more are treated as outliers (default - inf)
%  maxSample    - fit on at most this many misorientations (default - 50000), the
%                 subsample is drawn at random, so beyond it repeated calls differ
%  searchResolution - grid resolution of the global scan (default - 4*degree)
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
maxSample = get_option(varargin,'maxSample',50000);
moriAll = mori;
if length(mori) > maxSample, mori = discreteSample(mori,maxSample); end
h = ceil(quant * length(mori));

vdisp(' ',varargin{:});
vdisp(' optimizing parent to child orientation relationship',varargin{:});

% the iteration is local, so a bad p2c0 costs more than the scan does
if check_option(varargin,'global')
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
    if s == 1, pNew = pTrial; else, pNew = mean([p2c,pTrial],'weights',[1-s s]); end
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
sub = mori;
if length(sub) > 3000, sub = discreteSample(sub,3000); end
hSub = ceil(h / length(mori) * length(sub));

g = orientation(equispacedSO3Grid(p2c.CS,p2c.SS,'resolution',res));
g = [p2c; g(:)];

vdisp(['  scanning ' int2str(length(g)) ' orientations'],varargin{:});
fit = zeros(size(g));
for j = 1:length(g)
  s = misfit(sub,g(j),hSub,tau);
  fit(j) = s.fit;
end

% keep the best basins, well separated so that they are not the same one twice
[~,order] = sort(fit);
seed = g(order(1));
for j = order(2:end).'
  if length(seed) >= nBasin, break; end
  if min(angle(seed,g(j))) > res, seed = [seed; g(j)]; end %#ok<AGROW>
end

% score every basin with the one functional the iteration itself uses
opt = [delete_option(varargin,'global'),{'silent'}];
best = inf;
for j = 1:length(seed)
  pj = calcParent2Child(mori,seed(j),opt{:});
  s = misfit(mori,pj,h,tau);
  if s.fit < best, best = s.fit; p2c = pj; end
end

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
