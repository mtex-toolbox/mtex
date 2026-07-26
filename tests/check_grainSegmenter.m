function check_grainSegmenter(varargin)
% regression test for the MDL clustering grain segmenter
%
% Locks three things:
%
% 1. the invariants - the segmentation handed to calcGrains is exactly the
%    one the segmenter computed, outliers are the misindexed pixels and
%    nothing else, and no wild pixel survives as its own grain
% 2. the scores on the three benchmark levels
% 3. that the segmenter beats the existing chain on every level, and that
%    the model order is earned rather than assumed: the undeformed levels
%    must be described by a constant orientation per region, level 3 by a
%    linear one
%
% Syntax
%   check_grainSegmenter          % everything (~1 min)
%   check_grainSegmenter('fast')  % invariants on a small map only
%
% See also
% grainSegmenter EBSDGrainBenchmark check_grainBenchmark

%% a small clean map must come out essentially exact

ebsd = EBSDGrainBenchmark((1:7)*degree,[2 4 6]*degree, ...
  'grainSize',15,'noiseLevel',1.5*degree,'seed',3);

seg = grainSegmenter(ebsd);
seg.merge;

check(abs(seg.sigma - 0.72*degree) < 0.15*degree, ...
  'noise estimate is %.3f deg, expected about 0.72 deg',seg.sigma/degree);

check(seg.numRegions >= 32 && seg.numRegions <= 40, ...
  'expected roughly 32 regions on the clean map, got %d',seg.numRegions);

check(all(seg.numPixel > 0),'a region without pixels was produced');
check(sum(seg.numPixel) == numel(seg.pixelId), ...
  'the region sizes do not add up to the number of pixels');

[grains,ebsd2] = seg.calcGrains;

% the reconstruction chain must reproduce the segmentation exactly, since
% all it is given is the labelling itself
gid = ebsd2.grainId(seg.pixelId);
sid = seg.id(seg.pixelId);
% the two labellings must induce the SAME partition, which they do exactly
% when the number of distinct (grainId,regionId) pairs equals the number of
% distinct labels on either side
nG = numel(unique(gid));
nS = numel(unique(sid));
nPair = size(unique([gid(:) sid(:)],'rows'),1);
check(nG == nS && nPair == nG, ...
  'calcGrains did not reproduce the segmentation: %d grains, %d regions, %d pairs', ...
  nG,nS,nPair);

check(length(grains) >= numel(unique(sid)), ...
  'fewer grains than regions came back from calcGrains');

r = scoreGrainBenchmark(ebsd2,grains);
% 225 pixels per grain is little statistical power, so this is lower
% than on the full size benchmark maps
check(r.ari > 0.93,'clean small map gives ARI %.4f',r.ari);
check(r.minDetectedAngle <= 1*degree, ...
  'clean small map does not resolve the 1 deg boundaries');

if check_option(varargin,'fast')
  disp('check_grainSegmenter: invariants passed (levels skipped)');
  return
end

%% the three benchmark levels

ref = struct( ...
  'regions' ,{  32,    32,    33}, ...
  'ari'     ,{0.9931,0.9905,0.9826}, ...
  'linear'  ,{     0,     0,    28}, ...   % regions that adopt a gradient
  'baseline',{0.9792,0.8384,0.5476});   % best existing chain, see check_grainBenchmark

fprintf('\n level   regions   linear      ARI   minDet   wild absorbed / alone\n');
fprintf(' ---------------------------------------------------------------------\n');

for lvl = 1:3

  ebsd = EBSDGrainBenchmark('level',lvl);

  seg = grainSegmenter(ebsd);
  seg.merge;
  [grains,ebsd2] = seg.calcGrains;
  r = scoreGrainBenchmark(ebsd2,grains);

  fprintf('   %d   %7d  %7d   %6.4f   %4.1f deg', ...
    lvl,seg.numRegions,nnz(seg.modelOrder > 3),r.ari,r.minDetectedAngle/degree);
  if isnan(r.wildAbsorbed), fprintf('        -\n');
  else, fprintf('    %5.1f %% / %.1f %%\n',100*r.wildAbsorbed,100*r.wildIsolated); end

  check(abs(r.ari - ref(lvl).ari) < 0.05, ...
    'level %d: ARI moved from %.4f to %.4f',lvl,ref(lvl).ari,r.ari);
  check(abs(seg.numRegions - ref(lvl).regions) < 0.3*ref(lvl).regions + 5, ...
    'level %d: region count moved from %d to %d',lvl,ref(lvl).regions,seg.numRegions);

  % every boundary is found on every level - detection was never the
  % problem, model selection was
  check(r.minDetectedAngle <= 1*degree, ...
    'level %d: the 1 deg boundaries are no longer detected',lvl);

  check(r.ari > ref(lvl).baseline, ...
    'level %d: no longer better than the existing chain (%.4f vs %.4f)', ...
    lvl,r.ari,ref(lvl).baseline);

  % the model order has to be earned: a gradient costs six extra
  % parameters, so it may only be adopted where there IS one. Levels 1 and
  % 2 are undeformed and must stay constant throughout; level 3 carries a
  % 5 deg gradient in every grain and must pick it up in essentially all of
  % the large regions.
  nLin = nnz(seg.modelOrder > 3);
  if ref(lvl).linear == 0
    check(nLin == 0, ...
      'level %d is undeformed but %d regions adopted a gradient',lvl,nLin);
  else
    big = seg.numPixel > 500;
    check(nnz(seg.modelOrder(big) > 3) >= 0.9*nnz(big), ...
      'level %d: only %d of %d large regions adopted a gradient', ...
      lvl,nnz(seg.modelOrder(big) > 3),nnz(big));

    % and the gradient has to be the RIGHT one: once it is fitted, what is
    % left over must be noise. A constant model on the same pixels leaves
    % the full 5 deg ramp behind, about twice this.
    res = sqrt(seg.SSE(big)./(3*seg.numPixel(big)));
    check(max(res) < 1.1*seg.sigma, ...
      'level %d: residual after the linear fit is %.3f deg, sigma is %.3f deg', ...
      lvl,max(res)/degree,seg.sigma/degree);
  end

  % outlier handling. Recall is the requirement: a misindexed pixel left in
  % the data corrupts every statistic computed from the grain afterwards.
  % Precision is a deliberate trade - boundaryCost 2 buys a much better
  % segmentation at the price of blanking a few good pixels as well - so
  % what is bounded here is the share of the MAP that is needlessly
  % blanked, not the precision, which depends on how many wild pixels the
  % level happens to contain.
  if any(ebsd.prop.isWild)
    isOut = seg.isOutlier(seg.pixelId);
    isW   = ebsd.prop.isWild(seg.pixelId);
    check(mean(isOut(isW)) > 0.99, ...
      'level %d: only %.1f %% of the wild pixels were flagged',lvl,100*mean(isOut(isW)));
    check(mean(isOut & ~isW) < 0.01, ...
      'level %d: %.2f %% of the good pixels were blanked as outliers', ...
      lvl,100*mean(isOut & ~isW));
    check(r.wildIsolated < 0.01, ...
      'level %d: %.1f %% of the wild pixels became their own grain',lvl,100*r.wildIsolated);
  end
end

disp(' ');
disp('check_grainSegmenter: passed');

end

% --------------------------------------------------------------- helpers

function check(cond,msg,varargin)

if ~cond, error(['check_grainSegmenter: ' msg],varargin{:}); end

end
