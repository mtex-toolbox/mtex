function fmc = FMC_Coarsen(fmc)
%Performs one coarsening step.

fmc.sizeW = fmc.sizeWnext;

fmc = part0EdgeDilution(fmc);
fmc = part1CoarseSeeds(fmc);
fmc = part2CreateP(fmc);
fmc = part3NormalizeP(fmc);
fmc = part5CoarseWeightsUpdate(fmc);
fmc = part6InterpWeights(fmc);
fmc = part7BiasWeights(fmc);
fmc = part8Salieciens(fmc);

fmc.v     = fmc.vcoarse;


end

%% part 0: Edge dilution procedure in Kushnir 2006
function fmc = part0EdgeDilution(fmc)

[i,j,w] = find(fmc.W);
sumW    = sum(fmc.W,2)-diag(fmc.W);                  %Total weights of each entry to its neighbors, not counting itself
n       = sum(fmc.W>0)';  %Total numer of neighbors each entry has

%If the weight between two nodes, (e.g. a to b) is less than the total
%weights of a to all its neighbors normalized by the total number of a's
%neighbors, set that weight to zero. Same for b.
w( w < (sumW(i)./(fmc.gammaW*n(i)))  &...
  w < (sumW(j)./(fmc.gammaW*n(j))) ) = 0;

fmc.W = sparse(i,j,w,fmc.sizeW,fmc.sizeW);

end


%% part 1: Select Coarse Seeds
function fmc = part1CoarseSeeds(fmc)
%F represents whether the nodes are Coarse nodes or not.
%0 means they are, 1 means they aren't

%Celements is the list of nodes that are coarse nodes.
%The nodes are considered in order of descending size
alphaSumV = full(fmc.alpha*(sum(fmc.W,2)-diag(fmc.W)));

% if s == 1 sort by weights
% else sort by size
if fmc.sLevel == 1
  [~,iorder] = sort(sum(fmc.W),'descend');
else
  [~,iorder] = sort(fmc.v, 'descend');
  iorder = iorder';
end

[i,~,w] = find(fmc.W);
cs   = [0 cumsum(full(sum(fmc.W>0,1)))];
Finv = false(fmc.sizeW,1);
% traverse all rows of W and find the indices of all nonzero elements
% that are in F. ind1 is the vector of indices of NZ entries of the rowI'th row
%ind2 contains the indices of ind1 that are coarse nodes
%sum of the weights between I'th pixel and nodes that are coarse

% add most weighted adjacent node if degree of weights less than alphasum
for k = iorder
  s    = cs(k)+1:cs(k+1);
  wsub = w(s); % weights of row
  Finv(k) = sum(wsub(Finv(i(s)))) < alphaSumV(k);
end

fmc.sizeWnext = nnz(Finv);
fmc.Celements = find(Finv)';
fmc.F         = ~Finv;

end

%% part 2: Create P
function fmc = part2CreateP(fmc)

% if F(i)==1, P(i,:)=W(i,Celements);
%populate the rows of P that correspond to fine nodes with weights between themselves and the coarse nods
Pfine = sparse(fmc.sizeW, fmc.sizeWnext);
Pfine(fmc.F,:) = fmc.W(fmc.F,fmc.Celements);

% if F(i)==0, P(i, Celements == i )=1;
%coarse nodes are fully weighted with their seeds
Pcoarse = sparse(fmc.Celements, 1:fmc.sizeWnext, 1, fmc.sizeW, fmc.sizeWnext);

fmc.P = Pfine + Pcoarse;

end

%% part 3: Normalize P
function fmc = part3NormalizeP(fmc)

% if sum(P(i,:))>0, P(i,:)=P(i,:)/sum(P(i,:));
Psum = sum(fmc.P,2);
[i,j,p] = find(fmc.P);
fmc.P = sparse(i,j,p./Psum(i),fmc.sizeW,fmc.sizeWnext);

i = find(Psum <= 0);
fmc.Celements = [fmc.Celements i'];
fmc.sizeWnext = numel(fmc.Celements);

[~,j] = ismember(i,fmc.Celements);
fmc.P = sparseConcat(fmc.P,i,j,ones(numel(i),1), [fmc.sizeW, fmc.sizeWnext]);

end


%% part 5:
function fmc = part5CoarseWeightsUpdate(fmc)

P = fmc.P;
%Calculate the new W and links
fmc.W   = P'*fmc.W*P;
fmc.A_D = P'*fmc.A_D*P;
%calculate the number of data points in each new node
fmc.vcoarse=P'*fmc.v;

end

%% part 6: Interpolate weights
function fmc = part6InterpWeights(fmc)
% aggregate statistics: mean orientation, centroid and orientation variance
%
% Every aggregate pools its seed and the fine nodes that interpolate into
% it. Two things are computed for each aggregate: the weighted mean
% orientation, and the orientation variance Qvar around it that
% part7BiasWeights then measures neighbouring aggregates against.
%
% This is done in one vectorised pass over all fine-coarse pairs rather
% than by folding the pairs in one at a time. The sequential version made
% the aggregate mean drift while it was being used as the reference for the
% quatmax outlier test, so which pixels counted as outliers - and hence the
% result - depended on the order the pairs happened to appear in. Here the
% mean is formed from all members at once and the outlier test is repeated
% against the converged mean, which is both order independent and exact.
%
% Qvar is the residual around a LINEAR orientation field, not around a
% constant one, whenever the aggregate is big enough for the gradient to
% pay for its six extra parameters. Without that a deformed grain looks
% like a grain with a large scatter: its Qvar keeps growing as it coarsens,
% the rebias in part7 keeps suppressing its internal couplings, and the
% hierarchy stalls before the grain is ever assembled. The gradient is the
% lattice curvature, and removing it leaves only the noise.

Celements = fmc.Celements(:);
nC = fmc.sizeWnext;

[ii,jj,pp] = find(fmc.P);
t = pp > .05 & ii ~= Celements(jj);

% Forced to columns. find on a 1x1 sparse returns 0x0 empties, and 0x0 is
% not a valid subs argument for accumarray below ("at least one column"),
% while 0x1 is. The last coarsening level can be a single node whose only
% pair is dropped by t, and mtexdata single reached exactly that.
i = ii(t); i = i(:);
j = jj(t); j = j(:);
p = pp(t); p = p(:);

O  = fmc.O(i);
Oc = fmc.O(Celements);

% project to fundamental region of Ocoarse_j
O = project2FundamentalRegion(quaternion(O),fmc.CS,quaternion(Oc(j)));

O  = reshape(squeeze(double(O)),[],4);
Oc = reshape(squeeze(double(Oc)),[],4);

vi = fmc.v(i).*p;
vc = fmc.v(Celements);

% ------------------------------------------------- mean orientation
%
% The members of an aggregate all lie within quatmax of each other, so the
% normalised weighted sum of their quaternions and the principal eigenvector
% of their weighted scatter matrix agree to well below the angular
% resolution that matters here, and the sum needs no per aggregate eigen
% decomposition.

% Outlier radius, per aggregate: kappa standard deviations of its own
% spread, held inside the band [0.4 quatmax, quatmax]. A hard radius puts a
% fixed angular scale back into an algorithm whose whole point is not to
% have one, but letting it follow the spread all the way down is worse, so
% quatmax sets the band and the spread picks the value inside it.
%
% The floor is not cosmetic. The radius exists to keep MISINDEXED pixels
% out of the statistics, and those are tens of degrees away; it must never
% become so tight that ordinary intra-grain variation is thrown out with
% them. Tying it to the noise alone does exactly that on clean data: on
% data/EBSD/EMSphinx.h5 the noise is 0.11 degree, the radius collapsed to
% 0.75 degree, and the map shattered into 11846 grains where a 5 degree
% radius gives 1563. The floor costs nothing on the synthetic benchmark,
% whose noise is high enough that it never binds:
%
%   floor        1 deg     2 deg     3 deg     5 deg
%   EMSphinx     3281      2136      1882      1563   grains
%   benchmark    0.9887    0.9887    0.9889    0.9667 (level 1 ARI)
%
% The EMSphinx column was measured with all three phases in one graph, i.e.
% before doEvaluate started clustering each phase on its own; the numbers
% shifted with that (1563 -> 1293 at the 5 degree floor), the ordering did
% not.
%
% kappa = 4 was measured over five benchmark realisations per level, where
% it beat 3, 6 and a fixed 5 degree radius (0.9875 +-0.0013 on level 1
% against 0.969 +-0.017 for the fixed radius). Note that the benchmark's
% level 3 carries a 5 degree gradient, exactly the old quatmax, so some of
% what the adaptive radius fixed there was that coincidence; the floor
% above is what keeps it honest on data the benchmark does not resemble.
kappa = 4;

rad = kappa * sqrt(max(fmc.Qvar(Celements),fmc.sigma^2));
rad = min(max(rad,0.4*fmc.quatmax),fmc.quatmax);
thr = cos(rad/2*degree);

mu   = Oc;
keep = true(numel(i),1);

for iter = 1:2

  d = sum(O .* mu(j,:),2);
  keep = abs(d) > thr(j);

  sgn = sign(d); sgn(sgn == 0) = 1;

  acc = vc .* Oc;                        % the seed, at its own weight
  w   = vi .* sgn .* keep;
  for c = 1:4
    acc(:,c) = acc(:,c) + accumarray(j,w.*O(:,c),[nC 1]);
  end

  nrm = sqrt(sum(acc.^2,2));
  nrm(nrm <= 0) = 1;
  mu = acc ./ nrm;
end

p(~keep) = 0;      % a member further than quatmax away is not one

% --------------------------------- member list: kept fine nodes + seeds

% Indices rather than a logical mask, and forced to a column. Logical
% indexing of a SCALAR with a false scalar returns 0x0, where the same
% index into any longer vector returns 0x1, and 0x10 .* 0x0 is a size
% error while 0x10 .* 0x1 is not. The last coarsening level can be left
% with a single fine-coarse pair, and if that one pair is an outlier the
% whole run used to die there.
kp = reshape(find(keep),[],1);

jm = [j(kp); (1:nC).'];
wm = [vi(kp); vc];
xm = [fmc.pos(i(kp),:); fmc.pos(Celements,:)];

% a member joining with fractional membership brings that fraction of its
% moments with it; a seed joins whole
Mm = [fmc.M(i(kp),:).*p(kp); fmc.M(Celements,:)];

tm = tangent(mu(jm,:),[O(kp,:); Oc]);   % member offsets, in degree

% ----------------------------------------------------- moment sums
%
% The moments are carried UP the hierarchy rather than recomputed from the
% member means at each level, and that is the whole point of them. An
% aggregate high up has only a handful of members, far too few to fit nine
% parameters to, but between them those members hold the moments of every
% pixel underneath. Shifting a member's moments into its parent's frame is
% exact for the spatial part and first order in the angles for the
% orientation part, which is the same approximation the tangent space model
% rests on throughout:
%
%   x = x' + u,  t = t' + d      u = c_member - c_parent
%                                d = tangent(mu_parent,mu_member)
%
% and since x' and t' are centred within the member, all the cross terms
% drop out and only  Sxx_k + w u^2,  Sxv_k + w u d,  Stt_k + w |d|^2  remain.

n  = accumarray(jm,wm,[nC 1]);
n(n <= 0) = 1;

cx = accumarray(jm,wm.*xm(:,1),[nC 1])./n;
cy = accumarray(jm,wm.*xm(:,2),[nC 1])./n;

dx = xm(:,1) - cx(jm);
dy = xm(:,2) - cy(jm);

Sxx = accumarray(jm,Mm(:,1) + wm.*dx.^2   ,[nC 1]);
Sxy = accumarray(jm,Mm(:,2) + wm.*dx.*dy  ,[nC 1]);
Syy = accumarray(jm,Mm(:,3) + wm.*dy.^2   ,[nC 1]);

Sxv = zeros(nC,3); Syv = zeros(nC,3); Sv = zeros(nC,3);
for c = 1:3
  Sxv(:,c) = accumarray(jm,Mm(:,3+c) + wm.*dx.*tm(:,c),[nC 1]);
  Syv(:,c) = accumarray(jm,Mm(:,6+c) + wm.*dy.*tm(:,c),[nC 1]);
  Sv(:,c)  = accumarray(jm,             wm.*tm(:,c)   ,[nC 1]);
end

Stt = accumarray(jm,Mm(:,10) + wm.*sum(tm.^2,2),[nC 1]);

sseConst = max(Stt - sum(Sv.^2,2)./n, 0);

% ------------------------------------------------------ linear model
%
% Written in aggregate centred coordinates, so the constant term is
% orthogonal to the two gradient terms and the linear residual is the
% constant residual minus the gain of one 2x2 solve per component. No
% matrix inversion, and nothing to condition.

det = Sxx.*Syy - Sxy.^2;
ok  = det > 0 & n >= 12;

idet = zeros(nC,1); idet(ok) = 1./det(ok);

gx = (  Syy.*Sxv - Sxy.*Syv) .* idet;
gy = (- Sxy.*Sxv + Sxx.*Syv) .* idet;

gain = min(max(sum(gx.*Sxv + gy.*Syv,2),0),sseConst);
sseLin = sseConst - gain;

% Adopt the gradient only where it earns its parameters back, by minimum
% description length in nats:
%
%   L = SSE/(2 sigma^2) + k log(maxAngle/sigma) + k/2 log(n)
%
% with k = 3 for the constant model and k = 9 for the linear one. Comparing
% the two residuals per remaining degree of freedom instead - an F test in
% all but name - was tried first and is far too lenient: it adopts a
% gradient on the CLEAN benchmark, where there is none to find, and the
% shrunken Qvar then lets the rebias merge the 1 degree boundaries away.
% The parameters have to be paid for at the resolution the data actually
% has, which is what ties the penalty to sigma.

sigma  = fmc.sigma;
bits   = 3*log(max(fmc.maxAng,2*sigma)/sigma);
lConst = sseConst/(2*sigma^2) +   bits + 1.5*log(max(n,2));
lLin   = sseLin  /(2*sigma^2) + 3*bits + 4.5*log(max(n,2));

useLin = ok & lLin < lConst;

sse = sseConst;
sse(useLin) = sseLin(useLin);

% the fitted lattice curvature, kept so that part7BiasWeights can predict
% what misorientation two aggregates of one deformed grain SHOULD show
gx(~useLin,:) = 0;
gy(~useLin,:) = 0;

% Floored at the noise. A one or two pixel aggregate has no measurable
% spread and comes out at Qvar = 0, and an aggregate of zero spread makes
% the rebias below infinitely discriminating: every edge touching it is
% cut, and it is frozen out of the hierarchy for good. No orientation is
% ever known better than the noise it was measured with, so that is the
% floor.
Qvar = max(sse./n, sigma^2);

% The TOTAL spread, i.e. before the gradient is taken out. part7BiasWeights
% measures against this rather than against the residual, and the two are
% deliberately different things: the gradient is used to PREDICT what the
% offset to a neighbour ought to be, but the yardstick that offset is
% judged against has to be how much this region varies internally. Letting
% the gradient shrink the yardstick as well makes the rebias hypersensitive
% on clean data - with sigma around 0.1 degree the model is adopted for
% nearly every aggregate, Qvar collapses to the noise, and a neighbour
% 1.7 degree away reads as a 17 sigma event and is cut off, even from a
% region that varies by 12 degree across itself.
QvarTot = max(sseConst./n, sigma^2);

% reported by FMC_report, not printed here - one line per coarsening level
% interleaved with the rest of the log is unreadable
fmc.nLin = sum(useLin);

% ------------------------------------------------------------- write back

P = sparse(i,j,p,fmc.sizeW,fmc.sizeWnext) + ...
  sparse(ii(~t),jj(~t),pp(~t),fmc.sizeW,fmc.sizeWnext);

fmc.Qvar    = Qvar;
fmc.QvarTot = QvarTot;
fmc.O    = quaternion(mu(:,1),mu(:,2),mu(:,3),mu(:,4));
fmc.pos  = [cx cy];
fmc.M    = [Sxx Sxy Syy Sxv Syv Stt];
fmc.G    = [gx gy];
fmc.P    = P;

end

%% tangent vectors of b in the frame of a, in degree
function v = tangent(a,b)

% conj(a) .* b, both unit quaternions
w = a(:,1).*b(:,1) + a(:,2).*b(:,2) + a(:,3).*b(:,3) + a(:,4).*b(:,4);
x = a(:,1).*b(:,2) - a(:,2).*b(:,1) - a(:,3).*b(:,4) + a(:,4).*b(:,3);
y = a(:,1).*b(:,3) + a(:,2).*b(:,4) - a(:,3).*b(:,1) - a(:,4).*b(:,2);
z = a(:,1).*b(:,4) - a(:,2).*b(:,3) + a(:,3).*b(:,2) - a(:,4).*b(:,1);

% q and -q are the same rotation; take the representative with w >= 0 so
% the logarithm is the short way round
sgn = sign(w); sgn(sgn == 0) = 1;
w = w.*sgn; x = x.*sgn; y = y.*sgn; z = z.*sgn;

nv = sqrt(x.^2 + y.^2 + z.^2);

% angle/sin(angle/2), the limit 2 being taken where the two coincide
s = 2*ones(size(nv));
big = nv > 1e-12;
s(big) = 2*atan2(nv(big),w(big))./nv(big);

v = [x y z] .* (s / degree);

end

%% part 7: Bias weights
function fmc = part7BiasWeights(fmc)
% rescale the coupling between two aggregates by how surprising the
% misorientation between them is, given what each of them knows
%
% The measure is Mahalanobis in spirit: the misorientation is compared to
% the aggregates' OWN internal spread sqrt(Qvar) rather than to any fixed
% threshold angle, which is what frees FMC from having a threshold at all.
%
% What is compared is the RESIDUAL misorientation, not the raw one. Two
% aggregates inside one deformed grain are separated by a misorientation
% that grows with the distance between them, so measuring the raw
% misorientation against a Qvar from which the lattice curvature has been
% removed would cut every deformed grain to pieces - more surely than
% before the curvature was removed, not less. Each side therefore predicts
% what the offset to the other should be from its own fitted gradient, and
% only what neither can explain counts. Where no gradient was adopted the
% prediction is zero and this reduces exactly to the raw misorientation.

nC = fmc.sizeWnext;

[i,j] = find(triu(fmc.W));

Oi = quaternion(fmc.O(i));
Oj = project2FundamentalRegion(quaternion(fmc.O(j)),fmc.CS,Oi);

v = tangent(reshape(squeeze(double(Oi)),[],4), ...
            reshape(squeeze(double(Oj)),[],4));      % in degree

dc = fmc.pos(j,:) - fmc.pos(i,:);

predI = fmc.G(i,1:3).*dc(:,1) + fmc.G(i,4:6).*dc(:,2);
predJ = fmc.G(j,1:3).*dc(:,1) + fmc.G(j,4:6).*dc(:,2);

res = min(sqrt(sum((v-predI).^2,2)),sqrt(sum((v-predJ).^2,2)));

Wthreshold = 1e-3;
small = res <= Wthreshold;

i1 = i(~small); j1 = j(~small);
i2 = i(small);  j2 = j(small);

sqrtstuff = sqrt(min(fmc.QvarTot(i1),fmc.QvarTot(j1)));
sqrtstuff = max(sqrtstuff,Wthreshold);

bias = exp(-fmc.cmaha*(res(~small)-sqrtstuff)./sqrtstuff);

bias = sparse(i1,j1,bias,nC,nC) + sparse(i2,j2,1,nC,nC);
bias = bias + triu(bias,1)';

fmc.W = fmc.W.*bias;

end

%% part 8: Calculate saliencies
function fmc = part8Salieciens(fmc)

fmc.Sal = 2*((sum(fmc.W)' - diag(fmc.W)).*diag(fmc.A_D))./ ...
  (diag(fmc.W).*(sum(fmc.A_D,2)-diag(fmc.A_D)));

end

