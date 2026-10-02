function [hw,E] = selectHalfwidth(x,method,varargin)
% halfwidth of a de la Vallee Poussin kernel for a density estimate of orientations or directions
%
% Description
% Both methods judge a candidate halfwidth by the mean integrated squared
% error of the density estimate. In harmonics orthonormal for the uniform
% distribution it is
%
% $$ \mathrm{MISE} = \sum_{\ell \ge 1} (1 - b_\ell)^2 A_\ell + b_\ell^2 V_\ell, $$
%
% with $b_\ell$ the multipliers of the kernel, $A_\ell$ the degree energies
% of the density and $V_\ell$ the variance of the empirical coefficients of
% degree $\ell$. |'UCV'| inserts unbiased estimates of the energies,
% |'conservative'| lower confidence bounds that vanish above the bandwidth,
% which can only widen the kernel. Both are bounded below by a noise floor:
% the smallest halfwidth at which the sampling noise stays below a fraction
% |tauMax| of the estimate's maximum plus half the local density.
%
% Syntax
%   hw = selectHalfwidth(ori,'UCV')
%   hw = selectHalfwidth(v,'conservative')
%   hw = selectHalfwidth(ori,'UCV','groups',grainId)
%
% Input
%  ori - @orientation
%  v   - @vector3d, @Miller
%
% Output
%  hw - halfwidth
%  E  - struct with the degree energies |E.A|, their errors |E.se| and the sample statistics
%
% Options
%  weights    - weights of the points
%  groups     - ids of mutually dependent points, e.g. the grainId of EBSD pixels
%  bandwidth  - harmonic degree of the energies, default 64 (UCV of orientations), 256 (UCV of directions), 32 (conservative)
%  halfwidths - candidate halfwidths, default 60 between 2° and 40° (orientations) or between 1° and 60° (directions)
%  folds      - number of disjoint parts the energies are cross-fitted over (default 8)
%  z          - multiple of the error the conservative energies are lowered by (default 2)
%  tauMax     - noise floor as a fraction of the estimate's maximum (default 0.2)
%
% Flags
%  noNoiseFloor - do not bound the halfwidth from below by the noise
%
% See also
% orientation/calcKernel vector3d/calcKernel EBSD/calcKernel

isSO3 = isa(x,'quaternion');
isUCV = strcmpi(method,'UCV');
assert(isUCV || strcmpi(method,'conservative'),'MTEX:selectHalfwidth',...
  'The halfwidth selection method is ''UCV'' or ''conservative''.');

if isSO3
  hs = logspace(log10(2),log10(40),60) * degree;
else
  hs = logspace(0,log10(60),60) * degree;
end
hs = get_option(varargin,'halfwidths',hs);
b = arrayfun(@(h) multipliers(isSO3,h),hs,'UniformOutput',false);
deg = cellfun(@numel,b) - 1;

% UCV of independent points needs no errors and takes a single transform
L = get_option(varargin,'bandwidth',32 + isUCV * (32 + 192 * ~isSO3));
F = get_option(varargin,'folds',8);
if isUCV && isempty(get_option(varargin,'groups')), F = 1; end
E = degreeEnergies(x,L,F,max(deg),varargin{:});

% on SO(3) UCV doubles the bandwidth once when it chose the narrowest halfwidth the bandwidth resolves
if isUCV && isSO3 && ~check_option(varargin,'bandwidth') && any(deg > L) && ...
    ucv(E,b,hs,deg) <= min(hs(deg <= L))
  E = degreeEnergies(x,2*L,F,max(deg),varargin{:});
end

if isUCV
  hw = ucv(E,b,hs,deg);
else
  a = max(E.A - get_option(varargin,'z',2) * E.se,0);
  a(1) = 1;
  hw = hs(largestArgmin(riskCurve(E,b,a)));
end

if ~check_option(varargin,'noNoiseFloor')
  hw = max(hw,noiseFloor(E,b,hs,hw,get_option(varargin,'tauMax',0.2)));
end

end

% ------------------------------------------------------------------------

function b = multipliers(isSO3,h)
% the multipliers of the kernel of halfwidth h up to the last one above 1e-3

if isSO3
  psi = SO3DeLaValleePoussinKernel('halfwidth',h);
else
  psi = S2DeLaValleePoussinKernel('halfwidth',h);
end
b = psi.A(:) ./ (2*(0:numel(psi.A)-1).'+1) ./ psi.A(1);
b = b(1:max(2,find(abs(b) >= 1e-3,1,'last')));

end

function h = ucv(E,b,hs,deg)
% the unbiased risk over the candidates the bandwidth of the energies resolves

ok = deg <= E.L;
assert(any(ok),'MTEX:selectHalfwidth',...
  'No candidate halfwidth is resolved at bandwidth %d - raise the bandwidth.',E.L);
hs = hs(ok);
h = hs(largestArgmin(riskCurve(E,b(ok),E.A)));

end

function k = largestArgmin(r)
% the widest of equally good candidates, the side the conservative argument needs
k = find(r == min(r),1,'last');
end

function r = riskCurve(E,b,a)
% the risk at every candidate, the energies above the kernel's degree all bias

a = a(:);
tail = [flipud(cumsum(flipud(a))); 0];
r = zeros(size(b));
for k = 1:numel(b)
  Lk = numel(b{k}) - 1;
  m = min(numel(a),Lk+1);
  ak = zeros(Lk+1,1); ak(1:m) = a(1:m);
  t = (1-b{k}).^2 .* ak + b{k}.^2 .* variance(E,ak);
  r(k) = sum(t(2:end)) + tail(m+1);
end

end

function V = variance(E,a)
% s2 (c_l - a_l) for independent points; for groups the measured excess of the
% energies up to their bandwidth and the iid form times the design effect above

Lk = numel(a) - 1;
if E.grouped
  k = min(E.L,Lk) + 1;
  a = zeros(Lk+1,1); a(1:k) = max(E.A(1:k),0);
end
V = E.s2 * max(E.cbar(1:Lk+1) - a,0);
if E.grouped
  V(1:k) = max(E.energy(1:k) - E.A(1:k),V(1:k));
  V(k+1:end) = V(k+1:end) * E.designEffect;
end
V(1) = 0;

end

function h = noiseFloor(E,b,hs,pilot,tauMax)
% the smallest halfwidth at which, by Bennett's inequality at every independent
% kernel footprint, no fluctuation exceeds tauMax M + y/2, M the maximum of the
% pilot estimate and y the smoothed density

alpha = 0.05;
M = estimateMax(E,pilot);
y = M * logspace(-3,0,48);
excess = zeros(size(hs));
for k = 1:numel(hs)
  Lk = numel(b{k}) - 1;
  B = sum(b{k} .* E.cmax(1:Lk+1));
  R = sum(b{k}.^2 .* E.cbar(1:Lk+1));
  if E.isSO3
    nf = pi / (hs(k) - sin(hs(k)));
  else
    nf = 2 / (1 - cos(hs(k)));
  end
  t = bennett(E.s2 * R * y, E.wmax * B, log(2 * max(nf / E.nSym,1) / alpha));
  excess(k) = max(t - y/2) - tauMax * M;
end
ok = find(excess <= 0,1);
if isempty(ok), ok = numel(hs); end
h = hs(ok);

end

function t = bennett(sigma2,b,Lam)
% the deviation of a sum of independent summands below b with variance sigma2
% exceeded with probability exp(-Lam), solving (sigma2/b^2) g(b t/sigma2) = Lam,
% g(u) = (1+u) log(1+u) - u, by bisection

sigma2 = max(sigma2,1e-300);
c = Lam * b^2 ./ sigma2;
lo = zeros(size(c)); hi = c + 10;
for i = 1:60
  mid = (lo + hi) / 2;
  big = (1+mid) .* log1p(mid) - mid > c;
  hi(big) = mid(big); lo(~big) = mid(~big);
end
t = sigma2 / b .* hi;

end

function M = estimateMax(E,h)
% the largest value of the pilot estimate of halfwidth h at the first 200 pilot points

if E.isSO3
  psi = SO3DeLaValleePoussinKernel('halfwidth',h);
  t0 = cos(min(3*h,pi)/2);
else
  psi = S2DeLaValleePoussinKernel('halfwidth',h);
  t0 = cos(min(3*h,pi));
end
at = E.pilot(1:min(200,end),:);
g = symmetricCopies(E,E.pilot);
f = 0;
for k = 1:numel(g)
  t = at * g{k}.';
  if E.isSO3, t = abs(t); end
  % beyond three halfwidths the kernel is below 2e-3 of its peak
  f = f + (psi.eval(max(min(t,1),t0)) .* (t > t0)) * E.pilotW;
end
M = max(f) / numel(g);

end

% ------------------------------------------------------------------------

function E = degreeEnergies(x,L,F,Ltr,varargin)
% the empirical degree energies, cross-fitted over F folds
%
%  E.energy - ||mu_l||^2 of the weighted sample, l = 0..L
%  E.A      - unbiased estimate of the degree energies of the density
%  E.se     - jackknife error of E.A over the folds, NaN for F = 1
%  E.s2     - sum of the squared weights of the independent units
%  E.cbar   - the traces c_l averaged by w^2, l = 0..max(L,Ltr)
%  E.cmax   - their maximum over the subsample

w = get_option(varargin,'weights',ones(length(x),1));
groups = get_option(varargin,'groups',[]);
keep = ~isnan(x(:)) & w(:) > 0;
x = subSet(x,keep); w = w(keep); w = w(:) / sum(w);
if ~isempty(groups), groups = groups(keep); end
n = numel(w);
assert(n >= 2,'MTEX:selectHalfwidth','At least two points are needed.');
rs = RandStream('mt19937ar','Seed',0);

E.isSO3 = isa(x,'quaternion');
E.L = L;
E.grouped = ~isempty(groups);
if E.grouped
  [~,~,unit] = unique(groups(:));
  W = accumarray(unit,w);
else
  unit = (1:n).'; W = w;
end
E.s2 = sum(W.^2);
E.wmax = max(W);
assert(numel(W) >= 2,'MTEX:selectHalfwidth','At least two independent groups are needed.');

% the symmetry acting on the points, and the points as plain arrays
if E.isSO3
  if ~isa(x,'orientation'), x = orientation(x); end
  E.antipodal = x.antipodal;
  E.GS = quat2array(x.SS.properGroup.rot);
  E.GC = quat2array(x.CS.properGroup.rot);
  E.nSym = size(E.GS,1) * size(E.GC,1) * (1 + E.antipodal);
  P = quat2array(x);
  starts = deg2dim(0:L+1);
  % oversampling 1.25 with cutoff 6 is three times faster at an error of 1e-8
  coefficients = @(V) SO3FunHarmonic.adjoint(x,V,'bandwidth',L,...
    'oversampling',1.25,'cutoffParameter',6,'silent').fhat;
else
  antipodal = x.antipodal;
  if isa(x,'Miller')
    sym = x.CS;
    if sym.isLaue, sym = sym.properSubGroup; antipodal = true; end
    R = sym.rot;
  else
    R = rotation.id;
  end
  % the group as matrices, from the action of its elements on the axes
  E.M = zeros(3,3,numel(R));
  for k = 1:numel(R), E.M(:,:,k) = squeeze(double(R(k) * [xvector,yvector,zvector])).'; end
  if antipodal, E.M = cat(3,E.M,-E.M); end
  E.nSym = size(E.M,3);
  P = normalize(vector3d(x)).xyz;
  starts = (0:L+1).^2;
  coefficients = @(V) s2Coefficients(E,P,V,L);
end

% equal points fall into folds at random, groups and weighted points into folds of equal weight
F = min(F,numel(W));
if F < 2
  assert(~E.grouped,'MTEX:selectHalfwidth','Grouped points need folds.');
  fold = ones(n,1);
elseif ~E.grouped && ~check_option(varargin,'weights')
  fold = randi(rs,F,n,1);
else
  order = randperm(rs,numel(W)).';
  foldOfUnit(order,1) = min(floor(F * (cumsum(W(order)) - W(order)/2)),F-1) + 1;
  fold = foldOfUnit(unit);
end

% the coefficients of every fold in one transform
C = coefficients(w .* (fold == 1:F));
if F < 2
  E.energy = blockSum(abs(C).^2,starts);
  E.se = nan(L+1,1);
else
  [E.energy,E.A,E.se] = crossFit(C,accumarray(fold,w,[F 1]),starts);
end

% the traces on a subsample drawn by w^2, the weight of a point in the variance
m = 2000;
k = draw(rs,w.^2 / sum(w.^2),m,~check_option(varargin,'weights'));
sampleW = w(k).^2 / sum(w(k).^2);
if numel(k) < n, sampleW(:) = 1/numel(k); end
c = traces(E,P(k,:),max(L,Ltr));
E.cbar = c * sampleW;
E.cmax = max(c,[],2);

if F < 2
  E.A = (E.energy - E.s2 * E.cbar(1:L+1)) / (1 - E.s2);
end
E.A(1) = 1; E.se(1) = 0;

% the ratio of the measured to the iid variance over the upper quarter of the degrees
if E.grouped
  lo = max(1,floor(3*L/4)) + 1;
  iid = E.s2 * max(E.cbar(lo:L+1) - E.A(lo:end),1e-300);
  E.designEffect = max(1,median((E.energy(lo:end) - E.A(lo:end)) ./ iid));
end

% the pilot sample the maximum of the estimate is taken from
m = max(floor(20000 / E.nSym),2000);
k = draw(rs,w,m,~check_option(varargin,'weights'));
E.pilot = P(k,:);
E.pilotW = w(k);
if numel(k) < n, E.pilotW(:) = 1/numel(k); end

end

function [energy,A,se] = crossFit(C,Wf,starts)
% the energies from the products of disjoint folds, E <C_f,C_g> = W_f W_g A_l,
% and their jackknife error over the folds

F = numel(Wf);
L = numel(starts) - 2;
[energy,A,se] = deal(zeros(L+1,1));
D = 1 - sum(Wf.^2);
Dk = (1-Wf).^2 - (sum(Wf.^2) - Wf.^2);
for l = 0:L
  Cl = C(starts(l+1)+1:starts(l+2),:);
  G = real(Cl' * Cl);
  energy(l+1) = sum(G(:));
  S = energy(l+1) - trace(G);
  A(l+1) = S / D;
  Ak = (S - 2 * (sum(G,2) - diag(G))) ./ Dk;
  se(l+1) = sqrt((F-1)/F * sum((Ak - mean(Ak)).^2));
end

end

function c = s2Coefficients(E,P,V,L)
% the coefficients of the symmetrised point measures with the weights in the
% columns of V, orthonormal for the uniform probability
g = symmetricCopies(E,P);
g = vertcat(g{:});
c = sqrt(4*pi) * S2FunHarmonic.quadrature(vector3d(g(:,1),g(:,2),g(:,3)),...
  repmat(V,E.nSym,1) / E.nSym,'bandwidth',L).fhat;
end

function e = blockSum(v,starts)
% the sums over the degree blocks
cs = cumsum([0; v]);
e = reshape(cs(starts(2:end)+1) - cs(starts(1:end-1)+1),[],1);
end

function c = traces(E,P,L)
% c_l(x), the diagonal of the reproducing kernel of degree l projected by the
% symmetry: (2l+1) mean_s P_l(x . s x) on S2, (2l+1) mean_(a,b) chi_l(x^-1 a x b) on SO(3)

g = symmetricCopies(E,P);
t = zeros(size(P,1),numel(g));
for k = 1:numel(g), t(:,k) = sum(P .* g{k},2); end
c = ones(L+1,size(P,1));
if E.isSO3
  % the characters U_2l(cos(omega/2)) by U_2l+2 = (4t^2-2) U_2l - U_2l-2
  y = 4*t.^2 - 2;
  u0 = ones(size(t)); u1 = y + 1;
  for l = 1:L
    c(l+1,:) = (2*l+1) * mean(u1,2);
    [u0,u1] = deal(u1,y .* u1 - u0);
  end
else
  t = min(max(t,-1),1);
  p0 = ones(size(t)); p1 = t;
  for l = 1:L
    c(l+1,:) = (2*l+1) * mean(p1,2);
    [p0,p1] = deal(p1,((2*l+1) * t .* p1 - l * p0) / (l+1));
  end
end

end

function g = symmetricCopies(E,P)
% the symmetric copies of points: M x on S2; a x b on SO(3), and a x^-1 b for antipodal ones

if E.isSO3
  sides = {P};
  if E.antipodal, sides{2} = P .* [1 -1 -1 -1]; end
  g = cell(numel(sides),size(E.GS,1),size(E.GC,1));
  for s = 1:numel(sides)
    for i = 1:size(E.GS,1)
      for j = 1:size(E.GC,1)
        g{s,i,j} = qmul(qmul(E.GS(i,:),sides{s}),E.GC(j,:));
      end
    end
  end
  g = g(:).';
else
  g = arrayfun(@(k) P * E.M(:,:,k).',1:E.nSym,'UniformOutput',false);
end

end

function k = draw(rs,p,m,equal)
% m indices: all when there are no more, distinct ones for equal weights, else by weight

n = numel(p);
if n <= m
  k = (1:n).';
elseif equal
  k = randperm(rs,n,m).';
else
  edges = [0; cumsum(p(:))]; edges(end) = inf;
  k = discretize(rand(rs,m,1),edges);
end

end

function q = quat2array(q)
q = [q.a(:),q.b(:),q.c(:),q.d(:)];
end

function r = qmul(p,q)
% the quaternion product of the rows of p and q, either may be a single row
r = [p(:,1).*q(:,1) - p(:,2).*q(:,2) - p(:,3).*q(:,3) - p(:,4).*q(:,4), ...
     p(:,1).*q(:,2) + p(:,2).*q(:,1) + p(:,3).*q(:,4) - p(:,4).*q(:,3), ...
     p(:,1).*q(:,3) - p(:,2).*q(:,4) + p(:,3).*q(:,1) + p(:,4).*q(:,2), ...
     p(:,1).*q(:,4) + p(:,2).*q(:,3) - p(:,3).*q(:,2) + p(:,4).*q(:,1)];
end
