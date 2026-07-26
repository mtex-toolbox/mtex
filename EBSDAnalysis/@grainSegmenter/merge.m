function seg = merge(seg,varargin)
% merge regions until no merge shortens the description any further
%
% Every region is described either by a single orientation (3 parameters)
% or by an orientation plus a linear gradient of it (9 parameters), and the
% description length of a region is
%
%   L = SSE/(2 sigma^2) + k*log(maxAngle/sigma) + k/2*log(n)
%
% minimised over the two model orders k. The gradient matters: under a real
% intra grain orientation gradient a constant model has a residual that
% grows with the size of the region, so it eventually pays to cut the grain
% in two - which is exactly the over segmentation deformed material
% produces. A linear model has no such floor, and since it is only paid for
% when it earns its 6 extra parameters back, undeformed grains are still
% described by a constant.
%
% Every pass computes, for each pair of adjacent regions,
%
%   dL = L(union) - L(a) - L(b) - boundaryCost*shared
%
% and merges the pair when dL < 0. The union is evaluated in closed form
% from moment sums carried on each region, so a merge costs O(1) rather
% than a refit over its pixels.
%
% The residual of the union is capped at
% numPixel(smaller)*outlierCost*2*sigma^2, because the pixels of the
% smaller region can always be coded as outliers instead of being fitted.
% Without that cap a single misindexed pixel would be infinitely expensive
% to absorb and would survive as its own grain, which is precisely how
% threshold based reconstruction fails on noisy maps.
%
% Only mutual best pairs are merged in a pass: region a is merged with
% region b if b is the cheapest merge available for a AND a is the cheapest
% merge available for b. Merging is irreversible, so a weak boundary must
% only be crossed after everything better has been used up.
%
% Syntax
%   seg.merge
%   seg.merge('verbose')
%
% Options
%  verbose - report every pass instead of a progress counter
%  silent  - suppress the progress counter
%
% See also
% grainSegmenter grainSegmenter.calcGrains

verbose = check_option(varargin,'verbose');

sigma2 = seg.sigma^2;
costPar = seg.regionCost/3;           % description length of one parameter
resCap = 2*sigma2*seg.outlierCost;    % largest residual a pixel can cost

if isempty(seg.stat), refit(seg,[]); end

% progress is reported as the number of merges carried out, out of the most
% there could ever be - the same measure orientation/doHClustering uses for
% its agglomerative loop. It therefore stops short of 100 %, since the map
% does not collapse into a single region; the counter cleans up after itself
% when merge returns.
nStart = seg.numRegions;

if verbose
  fprintf('\n pass   regions    merges   linear\n');
  fprintf(' -----------------------------------\n');
  pC = progressCounter(0);   % would fight with the per pass table
else
  pC = progressCounter(nStart,'caption',' merging regions: ',varargin{:});
end

for pass = 1:seg.maxPass

  R   = seg.numRegions;
  lab = seg.id;
  st  = seg.stat;

  % ------------------------------------------- current region adjacency

  a = lab(seg.E(:,1));
  b = lab(seg.E(:,2));

  keep = a ~= b;
  if ~any(keep), break, end

  [P,~,ic] = unique([min(a(keep),b(keep)) max(a(keep),b(keep))],'rows');
  shared   = accumarray(ic,1);

  A = P(:,1); B = P(:,2);

  % ------------------------------------------ description length of a merge
  %
  % region B's tangent statistics are taken at B's own mean orientation and
  % have to be moved into A's tangent space first. To first order - the same
  % approximation the whole tangent space model rests on - that is a shift
  % of every tangent vector by delta = log(inv(muA)*muB).

  % the tangent space bookkeeping is dropped right away - all that is
  % wanted are the coordinates, and keeping it would retain a copy of the
  % reference orientations, one per adjacent pair
  d  = vector3d(log(seg.meanRotation(B),seg.meanRotation(A), ...
    SO3TangentSpace.rightVector));
  dv = [d.x d.y d.z];

  nB = st.n(B);

  u.n   = st.n(A)   + nB;
  u.Sx  = st.Sx(A)  + st.Sx(B);
  u.Sy  = st.Sy(A)  + st.Sy(B);
  u.Sxx = st.Sxx(A) + st.Sxx(B);
  u.Sxy = st.Sxy(A) + st.Sxy(B);
  u.Syy = st.Syy(A) + st.Syy(B);

  u.Sv  = st.Sv(A,:)  + st.Sv(B,:)  + nB.*dv;
  u.Sxv = st.Sxv(A,:) + st.Sxv(B,:) + st.Sx(B).*dv;
  u.Syv = st.Syv(A,:) + st.Syv(B,:) + st.Sy(B).*dv;

  u.q = st.q(A) + st.q(B) + 2*sum(dv.*st.Sv(B,:),2) + nB.*sum(dv.^2,2);

  [SSEc,SSEl,linOk] = modelSSE(u,seg.minPixelLinear);

  % the pixels of the smaller region may be coded as outliers instead
  base = seg.SSE(A) + seg.SSE(B) + min(st.n(A),nB)*resCap;
  SSEc = min(SSEc,base);
  SSEl = min(SSEl,base);

  Lu = modelCost(SSEc,SSEl,linOk,u.n,sigma2,costPar);

  dL = Lu - seg.cost(A) - seg.cost(B) - seg.boundaryCost*shared;

  cand = find(dL < 0);
  if isempty(cand), break, end

  % --------------------------------------------------- mutual best pairs

  reg = [A(cand); B(cand)];
  val = [dL(cand); dL(cand)];
  eid = [cand; cand];

  % write the candidates in order of decreasing gain, so that the last
  % write - and therefore the surviving entry - is the best one
  [~,ord] = sort(val,'descend');
  best = zeros(R,1);
  best(reg(ord)) = eid(ord);

  sel = cand(best(A(cand)) == cand & best(B(cand)) == cand);
  if isempty(sel), break, end

  % ------------------------------------------------------------- relabel
  %
  % mutual best pairs are disjoint, so this is a matching and every region
  % takes part in at most one merge

  mA = A(sel); mB = B(sel);

  % the merged region starts from the pixel weighted mean of both parents.
  % Taking one parent's mean instead would be fatal when a small region
  % swallows a large one: every pixel of the large one then sits beyond the
  % outlier cap, gets excluded from the refit, and the wrong mean confirms
  % itself for good.
  wAB = log(seg.meanRotation(mB),seg.meanRotation(mA), ...
    SO3TangentSpace.rightVector);
  seg.meanRotation(mA) = exp(wAB .* (st.n(mB)./(st.n(mA)+st.n(mB))), ...
    seg.meanRotation(mA),SO3TangentSpace.rightVector);

  map = (1:R).';
  map(mB) = mA;

  [surviving,~,newId] = unique(map);

  seg.id(seg.pixelId) = newId(lab(seg.pixelId));
  seg.numPixel        = accumarray(newId,seg.numPixel);
  seg.meanRotation    = seg.meanRotation(surviving);

  % only the regions that actually took part in a merge need a new fit,
  % which is what makes the long tail of the merge tree cheap
  refit(seg,newId(mA),surviving);

  seg.history(end+1,:) = [seg.numRegions numel(sel)]; %#ok<AGROW>

  if verbose
    fprintf(' %4d  %8d  %8d %8d\n', ...
      pass,seg.numRegions,numel(sel),nnz(seg.modelOrder > 3));
  end

  pC.show(nStart - seg.numRegions);

end

if verbose, fprintf('\n'); end

end

% --------------------------------------------------------------- helpers

function refit(seg,regs,surviving)
% recompute the model of the given regions from all of their pixels
%
% The mean carried through a merge is only the pixel weighted mean of the
% two parents, and the gradient is not carried at all, so every merge is
% followed by a proper fit. Pixels whose residual exceeds the outlier cap
% are left out - unless a region has no pixel left at all, in which case
% all of them are used: a region whose model is momentarily wrong must be
% able to recover, otherwise the exclusion is self confirming and the
% region is lost for good.
%
% regs      - new ids of the regions to refit, empty for all of them
% surviving - old ids of the surviving regions, to carry the untouched
%             statistics over the relabelling

lab = seg.id(seg.pixelId);
R   = seg.numRegions;
cap = 2*seg.sigma^2*seg.outlierCost;
mu  = seg.meanRotation;

if isempty(regs)

  sub = true(numel(lab),1);
  seg.stat      = emptyStat(R);
  seg.modelOrder = 3*ones(R,1);
  seg.SSE       = zeros(R,1);
  seg.cost      = zeros(R,1);

else

  % carry everything that did not change through the relabelling
  seg.stat       = selectStat(seg.stat,surviving);
  seg.modelOrder = seg.modelOrder(surviving);
  seg.SSE        = seg.SSE(surviving);
  seg.cost       = seg.cost(surviving);

  touched = false(R,1); touched(regs) = true;
  sub = touched(lab);

end

l = lab(sub);
o = seg.ori(sub);
X = seg.pos(sub,1);
Y = seg.pos(sub,2);

nAll = accumarray(l,1,[R 1]);
isOut = false(numel(l),1);

for iter = 1:2

  % as above - only the coordinates are needed, and this one is per pixel
  v = vector3d(log(o,mu(l),SO3TangentSpace.rightVector));
  V = [v.x v.y v.z];

  % fit once on the pixels currently accepted, use it to decide which
  % pixels the model fails to explain, then fit again without them
  for stage = 1:2

    if stage == 2
      isOut = sum((V - pred).^2,2) > cap;

      dead = accumarray(l(~isOut),1,[R 1]) == 0 & nAll > 0;
      if any(dead), isOut(dead(l)) = false; end
    end

    w  = ~isOut;
    st = accumStat(l(w),X(w),Y(w),V(w,:),R);

    [SSEc,SSEl,linOk] = modelSSE(st,seg.minPixelLinear);
    [L,order] = modelCost(SSEc,SSEl,linOk,st.n,seg.sigma^2,seg.regionCost/3);

    [c,gx,gy,xb,yb] = fitCoefficients(st,order);

    pred = c(l,:) + gx(l,:).*(X - xb(l)) + gy(l,:).*(Y - yb(l));

  end

  % move the reference orientation onto the fitted constant term, so that
  % the tangent vectors stay small and Sv stays near zero
  touchedReg = st.n > 0;
  tr = find(touchedReg);
  mu(tr) = exp(vector3d(c(tr,1),c(tr,2),c(tr,3)), ...
    mu(tr),SO3TangentSpace.rightVector);

  st = shiftStat(st,c);

end

seg.meanRotation = mu;

keepReg = st.n > 0;
seg.stat       = assignStat(seg.stat,st,keepReg);
SSEbest = SSEc;
SSEbest(order > 3) = SSEl(order > 3);

seg.modelOrder(keepReg) = order(keepReg);
seg.SSE(keepReg)        = SSEbest(keepReg);
seg.cost(keepReg)       = L(keepReg);

seg.isOutlier(seg.pixelId(sub)) = isOut;

end

% ------------------------------------------------------------------------

function st = emptyStat(R)

z = zeros(R,1); z3 = zeros(R,3);
st = struct('n',z,'Sx',z,'Sy',z,'Sxx',z,'Sxy',z,'Syy',z, ...
  'Sv',z3,'Sxv',z3,'Syv',z3,'q',z);

end

function st = accumStat(l,X,Y,V,R)

st.n   = accumarray(l,1,[R 1]);
st.Sx  = accumarray(l,X,[R 1]);
st.Sy  = accumarray(l,Y,[R 1]);
st.Sxx = accumarray(l,X.*X,[R 1]);
st.Sxy = accumarray(l,X.*Y,[R 1]);
st.Syy = accumarray(l,Y.*Y,[R 1]);

st.Sv  = [accumarray(l,V(:,1),[R 1]) accumarray(l,V(:,2),[R 1]) accumarray(l,V(:,3),[R 1])];
st.Sxv = [accumarray(l,X.*V(:,1),[R 1]) accumarray(l,X.*V(:,2),[R 1]) accumarray(l,X.*V(:,3),[R 1])];
st.Syv = [accumarray(l,Y.*V(:,1),[R 1]) accumarray(l,Y.*V(:,2),[R 1]) accumarray(l,Y.*V(:,3),[R 1])];

st.q   = accumarray(l,sum(V.^2,2),[R 1]);

end

function st = shiftStat(st,c)
% statistics after the reference orientation was moved by c, i.e. after
% every tangent vector v was replaced by v - c

st.q   = st.q - 2*sum(c.*st.Sv,2) + st.n.*sum(c.^2,2);
st.Sv  = st.Sv  - st.n.*c;
st.Sxv = st.Sxv - st.Sx.*c;
st.Syv = st.Syv - st.Sy.*c;

end

function st = selectStat(st,idx)

f = fieldnames(st);
for i = 1:numel(f), st.(f{i}) = st.(f{i})(idx,:); end

end

function st = assignStat(st,new,mask)

f = fieldnames(st);
for i = 1:numel(f), st.(f{i})(mask,:) = new.(f{i})(mask,:); end

end

% ------------------------------------------------------------------------

function [SSEc,SSEl,linOk] = modelSSE(st,minPixelLinear)
% residual sum of squares of the constant and of the linear model
%
% Both come out of the same moment sums: writing the design in coordinates
% centred on the region makes the constant term orthogonal to the gradient,
% so the linear model is the constant one minus the gain of a 2x2 solve.

n  = max(st.n,1);
xb = st.Sx./n;
yb = st.Sy./n;

SSEc = max(st.q - sum(st.Sv.^2,2)./n, 0);

Kxx = st.Sxx - n.*xb.^2;
Kxy = st.Sxy - n.*xb.*yb;
Kyy = st.Syy - n.*yb.^2;

Cx = st.Sxv - xb.*st.Sv;
Cy = st.Syv - yb.*st.Sv;

dt = Kxx.*Kyy - Kxy.^2;

gain = (Kyy.*sum(Cx.^2,2) - 2*Kxy.*sum(Cx.*Cy,2) + Kxx.*sum(Cy.^2,2))./dt;

linOk = st.n >= minPixelLinear & dt > 0 & isfinite(gain);

gain(~linOk) = 0;
SSEl = max(SSEc - max(gain,0), 0);

end

function [L,order] = modelCost(SSEc,SSEl,linOk,n,sigma2,cP)
% description length of a region, minimised over the two model orders
%
% k parameters stored to the precision sqrt(n) pixels justify cost
% k*log(maxAngle/sigma) + k/2*log(n) nats.

ln = log(max(n,1));

Lc = SSEc./(2*sigma2) + 3*cP + 1.5*ln;
Ll = SSEl./(2*sigma2) + 9*cP + 4.5*ln;

Ll(~linOk) = inf;

order = 3 + 6*(Ll < Lc);
L     = min(Lc,Ll);

end

function [c,gx,gy,xb,yb] = fitCoefficients(st,order)

n  = max(st.n,1);
xb = st.Sx./n;
yb = st.Sy./n;

c = st.Sv./n;

Kxx = st.Sxx - n.*xb.^2;
Kxy = st.Sxy - n.*xb.*yb;
Kyy = st.Syy - n.*yb.^2;

Cx = st.Sxv - xb.*st.Sv;
Cy = st.Syv - yb.*st.Sv;

dt = Kxx.*Kyy - Kxy.^2;
dt(dt <= 0) = inf;

gx = (Kyy.*Cx - Kxy.*Cy)./dt;
gy = (Kxx.*Cy - Kxy.*Cx)./dt;

isConst = order <= 3;
gx(isConst,:) = 0;
gy(isConst,:) = 0;

end
