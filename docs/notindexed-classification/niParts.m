function [T,P,info] = niParts(ebsd,grainId,grains,r0)
% split the notIndexed pixels of a square map into parts and measure them
%
% Input
%  ebsd    - @EBSD on a square grid, notIndexed pixels included
%  grainId - grainId of every pixel of ebsd from a small-alpha segmentation
%  grains  - the grains of that segmentation
%  r0      - opening radius in pixels separating thick parts from thin ones
%
% Output
%  T    - table, one row per part
%  P    - grid image of part ids, 0 on indexed pixels and outside the scan
%  info - grid size, indexed mask, footprint, distance transform, region ids
%
% Prototype for docs/notindexed-classification.md, needs the Image Processing
% Toolbox.

g = ebsd.gridify;
sz = size(g);
isInd = reshape(g.isIndexed,sz);
gId = zeros(sz);
gId(:) = grainId(g.id);

% the scan is the convex hull of the indexed pixels
[r,c] = find(isInd);
k = convhull(c,r);
foot = poly2mask(c(k)+0.5*sign(c(k)-mean(c)),r(k)+0.5*sign(r(k)-mean(r)),sz(1),sz(2)) | isInd;

NI = foot & ~isInd;
region = bwlabel(NI,8);

% outside = off the footprint, padded by one cell
outside = padarray(~foot,[1 1],true);
touchOut = imdilate(outside,true(3));
touchOut = touchOut(2:end-1,2:end-1);

% inscribed radius of every notIndexed pixel
D = double(bwdist(~NI));

% thick = the opening by a disk of radius r0, thin = the rest
thick = imopen(NI,strel('disk',r0,0));
Lthick = bwlabel(thick,8);
thin = NI & ~thick;
Lthin = bwlabel(thin,8);

% a thin piece within r0 of a thick part is its rim, not a part of its own
[Dt,idx] = bwdist(thick); Dt = double(Dt);
nThin = max(Lthin(:));
maxDt = accumarray(Lthin(thin),Dt(thin),[nThin 1],@max,0);
isRim = maxDt <= r0 & nThin > 0;
isRim = isRim & accumarray(Lthin(thin),Dt(thin) <= 1.5,[nThin 1],@any,false);
rimPx = thin & ismember(Lthin,find(isRim)) & region(max(idx,1)) == region;
Lthick(rimPx) = Lthick(idx(rimPx));

nThick = max(Lthick(:));
tp = thin & ~rimPx;
Ltp = bwlabel(tp,8);
P = Lthick + (Ltp + nThick).*tp;
nP = max(P(:));
isThick = (1:nP).' <= nThick;

% per part features
px = find(P);
pid = P(px);
area   = accumarray(pid,1,[nP 1]);
rMax   = accumarray(pid,D(px),[nP 1],@max);
border = accumarray(pid,touchOut(px),[nP 1],@any);
regId  = accumarray(pid,region(px),[nP 1],@mode);
regArea = accumarray(region(NI),1);
regArea = regArea(regId);

% skeleton length, mean width along the skeleton
sk = bwskel(P > 0) & P > 0;
skl = accumarray(P(sk),1,[nP 1]);
wSk = 2*accumarray(P(sk),D(sk),[nP 1],@mean,0);
rp = regionprops(P,'MaxFeretProperties');
feret = [rp.MaxFeretDiameter].';
if numel(feret) < nP, feret(end+1:nP) = 0; end

% indexed pixels around each part and the grains they belong to
[pp,gg] = deal([]);
for s = [-1 0 1 -1 1 -1 0 1; -1 -1 -1 0 0 1 1 1]
  Ps = circshift(P,s.');
  m = Ps > 0 & isInd & gId > 0;
  pp = [pp; Ps(m)]; gg = [gg; gId(m)]; %#ok<AGROW>
end
% contacts per part and grain, a rim pixel counts once per neighbour in the part
[pg,~,jj] = unique([pp gg],'rows');
cnt = accumarray(jj,1);
rimN = accumarray(pg(:,1),cnt,[nP 1]);
share = cnt ./ rimN(pg(:,1));
share1 = accumarray(pg(:,1),share,[nP 1],@max,0);

nG = accumarray(pg(:,1),share >= 0.05,[nP 1]);

% the rim grains of a part, merged when their mean orientations are within 10 degree
I = sparse(1:size(pg,1),pg(:,1),1,size(pg,1),nP);
[a,b] = find(triu(I*I',1));
same = false(size(a));
phaseG = grains.phaseId; rotG = grains.prop.meanRotation;
ga = pg(a,2); gb = pg(b,2);
for ph = unique(phaseG(ga)).'
  s = phaseG(ga) == ph & phaseG(gb) == ph;
  if ~any(s) || ph < 2, continue; end
  cs = grains.CSList(ph);
  same(s) = angle(orientation(rotG(ga(s)),cs),orientation(rotG(gb(s)),cs)) < 10*degree;
end
cl = conncomp(graph(a(same),b(same),[],size(pg,1))).';
oriShare = accumarray(cl,share);
oriShare1 = accumarray(pg(:,1),oriShare(cl),[nP 1],@max,0);
[pc,~] = unique([pg(:,1) cl],'rows');
nOri = accumarray(pc(:,1),oriShare(pc(:,2)) >= 0.05,[nP 1]);

id = (1:nP).';
T = table(id,regId,isThick,area,regArea,rMax,wSk,skl,feret,border,rimN,share1,nG,oriShare1,nOri);
T.elong = T.area ./ (pi*max(T.rMax,0.5).^2);
T.straight = T.feret ./ max(T.skl,1);

info = struct('sz',sz,'isInd',isInd,'foot',foot,'D',D,'region',region,'gId',gId);
end
