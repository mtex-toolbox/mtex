function [assignments,rep] = FMC_interpret(AllSals, numClusters, AllPs, A_D, minPixel, W0)
% read a grain labelling off the FMC aggregation hierarchy
%
% FMC_Coarsen never commits a merge: it produces, for every scale s, a soft
% membership matrix and a saliency per aggregate. Saliency is
%
%   Sal = external coupling / internal coupling
%
% so it is LOW for an aggregate that is coherent inside and well separated
% from its surroundings, i.e. exactly for something that deserves to be
% called a grain. This function turns that hierarchy into one label per
% pixel in three steps.
%
% 1 scale selection
%   Every pixel follows its own dominant aggregate up the hierarchy and is
%   read off at the scale where that aggregate is most salient. There is no
%   threshold and no fixed window of scales: a grain that stops being
%   coherent when it is merged with its neighbour is read off before that
%   merge, while a grain whose aggregate survives to the top is read off at
%   the top. This is what lets one region be resolved at scale 7 while the
%   region next to it is still coarsening.
%
% 2 merging nested choices
%   Pixels of one region may well settle on different scales. Where one
%   chosen aggregate is CONTAINED in another chosen one the two describe
%   the same region seen at two scales, and joining them is what keeps a
%   region from being split by its own scale selection. Where two chosen
%   aggregates are siblings - the hierarchy merged two grains and saliency
%   separated them again - nothing is joined, which is the whole point.
%
% 3 spatial split
%   Aggregates are built from couplings, not from geometry, so one may end
%   up covering two places that do not touch. A connected components pass
%   on the neighbour graph splits those.
%
% Input
%  AllSals     - cell, AllSals{s} the saliency of every aggregate at scale s
%  numClusters - number of aggregates at each scale, numClusters(1) = pixels
%  AllPs       - cell, AllPs{s} the membership of the scale s-1 aggregates
%                in the scale s aggregates (AllPs{1} is unused)
%  A_D         - pixel neighbourhood adjacency
%  minPixel    - regions smaller than this are dissolved and their pixels
%                adopted into a neighbour, rather than surviving as tiny
%                grains of their own (default 1, i.e. singletons only)
%  W0          - finest level pixel couplings, used to pick WHICH neighbour
%                a dissolved pixel joins
%
% Output
%  assignments - nPixel x 2, [label confidence], label 0 = unassigned
%  rep         - what FMC_report prints: .readPerScale, the number of
%                pixels read off at each scale, and .numStranded read off
%                at none; .numRegions before and .numGrains after the
%                undersized regions were absorbed, .numAbsorbed pixels
%                moved doing so, .numUnassigned left over at the end
%
% See also
% FMC_MTEX FMC_Coarsen FMC_report gbcFMC

if nargin < 5 || isempty(minPixel), minPixel = 1; end

numS = numel(numClusters);
N    = numClusters(1);

A_D = A_D | A_D.';

% global aggregate id per scale, so labels chosen at different scales can
% never collide numerically
offset = zeros(1,numS);
for s = 3:numS, offset(s) = offset(s-1) + numClusters(s-1); end
numAgg = offset(numS) + numClusters(numS);

% ---------------------------------------------------- 1 scale selection

bestSal = inf(N,1);
bestLab = zeros(N,1);
bestP   = zeros(N,1);

scaleOfAgg = zeros(numAgg,1);   % scale an aggregate lives on
indexOfAgg = zeros(numAgg,1);   % its index within that scale
parent     = cell(1,numS);      % dominant parent one scale up

% B holds the membership of every ORIGINAL pixel in the aggregates of the
% current scale, accumulated forward: one sparse product per scale instead
% of rebuilding the whole chain at every scale
B = AllPs{2};

for s = 2:numS

  if s > 2, B = B * AllPs{s}; end

  nC = numClusters(s);
  scaleOfAgg(offset(s)+(1:nC)) = s;
  indexOfAgg(offset(s)+(1:nC)) = 1:nC;

  [p,a] = max(B,[],2);
  p = full(p);

  % Saliency is not comparable between scales as it stands. It RISES as
  % aggregates grow - on the clean benchmark the median goes 3.6, 6.2, 13,
  % 30, 49, 68 - and then collapses to exactly 0 at the top, because the
  % rebias plus edge dilution eventually cut every edge leaving an
  % aggregate. Zero is the legitimate reading "perfectly separated", but
  % once the whole map has saturated there it says nothing about which
  % scale a region should be read at. Each scale is therefore scored
  % against its OWN median, so what is compared is how salient an aggregate
  % is FOR ITS SCALE.
  sal = full(AllSals{s});
  ref = median(sal(isfinite(sal) & sal > 0));
  if isempty(ref) || ~(ref > 0), ref = 1; end
  sal = sal / ref;

  q = inf(N,1);
  ok = full(p > 0);
  q(ok) = sal(a(ok));
  q(isnan(q)) = inf;
  sal = q;

  % Strictly less, so ties go to the FINEST scale that attains the minimum.
  % This is what makes the selection mean anything: saliency saturates at
  % the top, where every aggregate reads 0, so a rule that broke ties
  % towards the coarse end would read the whole map off the last scale and
  % the hierarchy below it would be wasted. Breaking them towards the fine
  % end reads each region off as soon as it is fully separated - early for
  % a grain that resolves quickly, at the top for one that only separates
  % from its neighbour at the very end.
  take = ok & sal < bestSal;

  bestSal(take) = sal(take);
  bestLab(take) = offset(s) + a(take);
  bestP(take)   = p(take);

  if s < numS
    [~,par]   = max(AllPs{s+1},[],2);
    parent{s} = full(par);
  end
end

% Assigned pixels only. There is no spare bin to put the others in: offset(2)
% is 0, so global aggregate id 1 is a genuine scale 2 aggregate and folding
% bestLab == 0 into it would report unassigned pixels as read off at scale 2.
% They are counted on their own, as rep.numUnassigned below.
sel = bestLab > 0;
rep.readPerScale = accumarray(scaleOfAgg(bestLab(sel)),ones(nnz(sel),1),[numS 1]).';
rep.numStranded  = nnz(~sel);

% ----------------------------------------------- 2 merging nested choices

uLab = unique(bestLab(bestLab > 0));

isChosen = false(numAgg,1);
isChosen(uLab) = true;

src = zeros(numel(uLab),1); dst = zeros(numel(uLab),1); n = 0;

for k = 1:numel(uLab)

  g   = uLab(k);
  cur = indexOfAgg(g);

  % walk up the chain of dominant parents; the first chosen ancestor is
  % enough, anything above it is reached transitively through that one
  for t = scaleOfAgg(g)+1:numS
    cur = parent{t-1}(cur);
    if isChosen(offset(t) + cur)
      n = n+1; src(n) = g; dst(n) = offset(t) + cur;
      break
    end
  end
end

if n > 0
  comp = conncomp(graph(src(1:n),dst(1:n),[],numAgg));
  bestLab(bestLab > 0) = comp(bestLab(bestLab > 0));
end

% -------------------------------------------------------- 3 spatial split

[i,j] = find(triu(A_D,1));
same  = bestLab(i) == bestLab(j) & bestLab(i) > 0;

label = conncomp(graph(i(same),j(same),[],N)).';
label(bestLab == 0) = 0;

% ------------------------------------------- 4 absorb undersized regions
%
% A misindexed pixel reaches this point in one of two states. Either
% part6InterpWeights zeroed its interpolation weight, because it sits
% further than its aggregate's outlier radius from the mean, and it has no
% membership at all; or its couplings were so weak that edge dilution cut
% it loose and it became a seed, and hence an aggregate, of its very own.
% Left alone both end up as single pixel grains, which is the one failure
% mode this algorithm is otherwise free of.
%
% Both are treated the same way, and minPixel simply raises the size below
% which a region counts as too small to stand on its own: undersized
% regions are eaten from the rim inwards by whichever full sized neighbour
% touches them, one shell per round, until nothing undersized is left.
%
% This ABSORBS rather than deletes, which is the opposite of what
% calcGrains' own minPixel does - that one marks undersized pixels
% notIndexed and throws their orientations away. Absorbing suits FMC: the
% pixels it strands are misindexed ones that belong to the grain around
% them, and putting them back there is the whole point.
%
% A region is only ever dissolved into a neighbour that is itself big
% enough, so two undersized regions cannot merge into one, and an
% undersized region with no full sized neighbour anywhere is left alone
% rather than being destroyed.

thr = max(minPixel,2);

% Strongest coupling first. Adopting every stranded pixel at once, one
% shell per round, lets a pixel sitting on a sharp internal boundary take
% whichever side happens to be labelled already - and along such a boundary
% the pixels on BOTH sides are usually stranded, so which side wins is
% decided by nothing at all. Working down from the strongest coupling makes
% each pixel wait until its own side has been settled, which is the same
% reason a priority flood beats a plain flood fill.
mx = max(max(W0));
if ~(mx > 0), mx = 1; end
levels = mx * [0.9 0.7 0.5 0.3 0.15 0.05 0];

label0 = label;

for lv = levels
  for round = 1:(2*thr + 20)

    nLab = max(label);
    if nLab == 0, break, end

    cnt = accumarray(label(label>0),1,[nLab 1]);

    undersized = label == 0;
    undersized(label>0) = cnt(label(label>0)) < thr;
    if ~any(undersized), break, end

    % label of every region big enough to adopt, 0 for the rest
    big = zeros(nLab,1);
    big(cnt >= thr) = find(cnt >= thr);

    target = zeros(N,1);
    target(label>0) = big(label(label>0));

    % Join the MOST SIMILAR full sized neighbour, not an arbitrary one.
    % Picking by largest label id - which is what this did first - glues a
    % stranded pixel to whichever neighbour happens to be numbered highest,
    % and on ebsd2 that turned 389 sharp (>10 degree) pixel steps into
    % INTERNAL steps of a grain, 61 % of them from exactly this. W0 holds
    % the finest level couplings, which fall off with the local
    % misorientation, so the largest coupling is the nearest neighbour in
    % orientation.
    cand = double(A_D(undersized,:)) .* W0(undersized,:);
    cand = cand .* (target(:).' > 0);

    [best,who] = max(cand,[],2);
    best = full(best); who = full(who);

    take = best > lv & best > 0;
    if ~any(take), break, end

    taken = label(undersized);
    taken(take) = target(who(take));
    label(undersized) = taken;
  end
end

rep.numRegions    = numel(unique(label0(label0>0))) + nnz(label0 == 0);
rep.numGrains     = numel(unique(label(label>0)))   + nnz(label == 0);
rep.numAbsorbed   = nnz(label ~= label0);
rep.numUnassigned = nnz(label == 0);

assignments = [label bestP];

end
