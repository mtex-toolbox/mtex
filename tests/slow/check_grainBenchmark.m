function check_grainBenchmark(varargin)
% regression test for the grain reconstruction benchmark, i.e. for
% EBSDGrainBenchmark and scoreGrainBenchmark
%
% Two independent things are locked here.
%
% 1. The invariants of the generator and of the scorer. These are exact
%    mathematical properties (the prescribed misorientation angles, the
%    prescribed intra grain spread, the outlier fractions, ARI = 1 for a
%    perfect reconstruction) and must hold to numerical precision. This
%    part runs in a few seconds.
%
% 2. The scores the EXISTING reconstruction chain achieves on the three
%    difficulty levels. These are the numbers a new, clustering based
%    algorithm has to beat, so they are recorded here rather than only in
%    a notebook. They are asserted with wide bands - the point is to
%    notice drift, not to freeze calcGrains. This part takes ~2 minutes,
%    almost all of it in the denoising filter.
%
% Syntax
%   check_grainBenchmark          % everything
%   check_grainBenchmark('fast')  % invariants only, skip the baselines
%
% See also
%  EBSDGrainBenchmark scoreGrainBenchmark check_calcGrainsCases

% angles well away from 0 are reproduced to ~1e-12 deg, but comparing two
% (nominally) identical orientations goes through acos near 1, which has a
% floor of a few 1e-6 deg - hence the second tolerance
tol     = 1e-9*degree;
tolZero = 1e-4*degree;

%% generator: geometry of the partition

ebsd = EBSDGrainBenchmark((1:7)*degree,[2 4 6]*degree,'grainSize',20);

nGR = ebsd.opt.numGrainRows;
nGC = ebsd.opt.numGrainCols;

check(isequal([nGR nGC],[4 8]),'expected a 4 × 8 grain layout, got %d × %d',nGR,nGC);
check(isequal(size(ebsd),[80 160]),'expected an 80 × 160 pixel map, got %d × %d',size(ebsd,1),size(ebsd,2));

n = accumarray(ebsd.prop.trueGrainId(:),1);
check(numel(n) == nGR*nGC && all(n == 400), ...
  'without roughness every grain must have exactly 400 pixels, got %d..%d in %d grains', ...
  min(n),max(n),numel(n));

%% generator: the misorientation ladder is exact
% the product construction ori(i,j) = u_i * v_j realizes every ladder angle exactly

ori = ebsd.opt.trueMeanOrientation;
check(isequal(size(ori),[nGR nGC]),'trueMeanOrientation must be numGrainRows × numGrainCols');

err = 0;
for i = 1:nGR
  for j = 1:nGC-1
    err = max(err,abs(angle(ori(i,j),ori(i,j+1)) - ebsd.opt.colAngles(j)));
  end
end
check(err < tol,'vertical boundaries are off by %.3g deg',err/degree);

err = 0;
for i = 1:nGR-1
  for j = 1:nGC
    err = max(err,abs(angle(ori(i,j),ori(i+1,j)) - ebsd.opt.rowAngles(i)));
  end
end
check(err < tol,'horizontal boundaries are off by %.3g deg',err/degree);

%% generator: trueGrainId indexes trueMeanOrientation
% trueGrainId is the MATLAB linear index, not a row major one

o   = ebsd.orientations;
err = max(angle(o(:),ori(ebsd.prop.trueGrainId(:))));
check(err < tolZero,'pixel orientations do not match trueMeanOrientation(trueGrainId), off by %.3g deg',err/degree);

%% generator: the intra grain spread is exactly 'deformation'
% on complete grains, the extremes of a linear ramp sit at the grain corners

def  = 5*degree;
ebsd = EBSDGrainBenchmark((1:7)*degree,[2 4 6]*degree, ...
  'grainSize',20,'deformation',def,'seed',7);

err = 0;
for g = [1 17 32]
  o = ebsd.orientations(ebsd.prop.trueGrainId(:) == g);
  err = max(err,abs(max(max(angle(o(:),o(:).'))) - def));
end
check(err < 1e-5*degree,'intra grain spread is off by %.3g deg',err/degree);

%% generator: outliers

ebsd = EBSDGrainBenchmark('level',2);

nPix = length(ebsd);
w = ebsd.prop.isWild;
u = ebsd.prop.isUnindexed;

check(abs(nnz(w)/nPix - 0.02) < 1e-4,'wild fraction is %.4f, expected 0.02',nnz(w)/nPix);
check(abs(nnz(u)/nPix - 0.05) < 1e-4,'notIndexed fraction is %.4f, expected 0.05',nnz(u)/nPix);
check(~any(w & u),'a pixel is both wild and notIndexed');
check(all(ebsd.isIndexed(~u)) && ~any(ebsd.isIndexed(u)), ...
  'isUnindexed does not agree with the phase of the pixel');
check(all(ebsd.prop.trueGrainId > 0), ...
  'trueGrainId must be set for every pixel, including outliers');

%% generator: reproducible, and explicit options override the level preset
% get_option takes the last occurrence, so the preset has to be prepended

a = EBSDGrainBenchmark('level',2);
b = EBSDGrainBenchmark('level',2);
check(max(angle(a.rotations,b.rotations)) == 0,'a fixed level is not reproducible');

c = EBSDGrainBenchmark('level',2,'noiseLevel',0,'grainSize',10);

check(c.opt.noiseLevel == 0,'noiseLevel was not overridden');
check(c.opt.grainSize == 10,'grainSize was not overridden');
check(isequal(size(c),[40 80]),'grainSize override did not change the map size');

% with the noise switched off, neighbouring pixels inside a grain must be
% identical - the strongest possible statement that the override took
ok  = ~c.prop.isWild & ~c.prop.isUnindexed;
ok  = reshape(ok,size(c));
tid = reshape(c.prop.trueGrainId,size(c));
o   = c.orientations;

s = ok(:,1:end-1) & ok(:,2:end) & tid(:,1:end-1) == tid(:,2:end);
z   = false(size(s,1),1);
err = max(angle(o([z s]),o([s z])));
check(err < tolZero,'noiseLevel 0 still leaves %.3g deg between neighbours',err/degree);

%% scorer: a perfect reconstruction scores perfectly

ebsd = EBSDGrainBenchmark('level',2);
ebsd.grainId = ebsd.prop.trueGrainId;
r = scoreGrainBenchmark(ebsd,[]);

check(r.ari == 1,'a perfect reconstruction gives ARI %.6f',r.ari);
check(r.fragments == 0 && r.majorSplits == 0,'a perfect reconstruction reports %d fragments',r.fragments);
check(all([r.byAngle.numDetected] == [r.byAngle.numBoundaries]), ...
  'a perfect reconstruction misses boundaries');
check(abs(r.minDetectedAngle - 1*degree) < tol, ...
  'minDetectedAngle is %.3g deg, expected 1 deg',r.minDetectedAngle/degree);
check(r.wildAbsorbed == 1 && r.wildIsolated == 0,'wild pixel accounting is wrong');
check(sum([r.byAngle.numBoundaries]) == nGR*(nGC-1) + (nGR-1)*nGC, ...
  'wrong number of boundaries in the table');

%% scorer: shattering must NOT score well
% purity would be 1 here, so the fragment count has to see it

ebsd.grainId = (1:length(ebsd)).';
r = scoreGrainBenchmark(ebsd,[]);

check(r.ari < 0.01,'a shattered map gets ARI %.4f',r.ari);
check(r.fragments > 0.5*length(ebsd),'a shattered map reports only %d fragments',r.fragments);
check(r.wildIsolated == 1,'wild pixels should all be isolated here');

%% scorer: one big grain must NOT score well either

ebsd.grainId = ones(length(ebsd),1);
r = scoreGrainBenchmark(ebsd,[]);

check(r.ari < 0.01,'a single grain map gets ARI %.4f',r.ari);
check(r.fragments == 0,'a single grain map cannot have fragments');
check(all([r.byAngle.numDetected] == 0),'a single grain map cannot detect boundaries');
check(isnan(r.minDetectedAngle),'a single grain map has no detected angle');

if check_option(varargin,'fast')
  disp('check_grainBenchmark: invariants passed (baselines skipped)');
  return
end

%% baselines of the existing chain
% reference values measured 2026-07-25, each at the best threshold of a sweep -
% the bands are wide, what must not change is the qualitative picture

fprintf('\nbaselines of the existing reconstruction chain\n\n');
fprintf('  level             chain   grains      ARI   minDet   wild alone\n');
fprintf('  ----------------------------------------------------------------\n');

ref = struct( ...
  'plainARI'    ,{0.1935,0.2928,0.2125}, ...
  'smoothThr'   ,{0.1*degree,0.1*degree,0.1*degree}, ...
  'smoothARI'   ,{0.9792,0.8384,0.5476}, ...
  'smoothGrains',{192,2512,2619});

for lvl = 1:3

  ebsd0 = EBSDGrainBenchmark('level',lvl);

  [g,ebsd] = calcGrains(ebsd0,'threshold',2*degree);
  rPlain = scoreGrainBenchmark(ebsd,g);
  report(lvl,'calcGrains 2 deg',rPlain);

  F = halfQuadraticFilter; F.alpha = 5;
  e2 = smooth(ebsd0,F,'fill');
  [g2,e2] = calcGrains(e2,'threshold',ref(lvl).smoothThr);
  rSmooth = scoreGrainBenchmark(e2,g2);
  report(lvl,'denoised',rSmooth);

  check(abs(rPlain.ari - ref(lvl).plainARI) < 0.05, ...
    'level %d: plain calcGrains ARI moved from %.4f to %.4f', ...
    lvl,ref(lvl).plainARI,rPlain.ari);
  check(abs(rSmooth.ari - ref(lvl).smoothARI) < 0.05, ...
    'level %d: denoised ARI moved from %.4f to %.4f', ...
    lvl,ref(lvl).smoothARI,rSmooth.ari);
  check(abs(rSmooth.numGrains - ref(lvl).smoothGrains) < 0.25*ref(lvl).smoothGrains + 5, ...
    'level %d: denoised grain count moved from %d to %d', ...
    lvl,ref(lvl).smoothGrains,rSmooth.numGrains);

  % the qualitative statements, which carry the actual meaning
  check(rPlain.ari < 0.5,'level %d: plain calcGrains suddenly works (ARI %.4f) - update this test',lvl,rPlain.ari);

  if lvl == 1
    % denoising finds every boundary, including the 1 deg ones, but pays
    % for it with a six fold over segmentation
    check(rSmooth.minDetectedAngle <= 1*degree, ...
      'level 1: denoising no longer detects the 1 deg boundaries (minDet %.1f deg)', ...
      rSmooth.minDetectedAngle/degree);
    check(rSmooth.numGrains > 3*nGR*nGC, ...
      'level 1: denoising no longer over segments (%d grains) - update this test', ...
      rSmooth.numGrains);
  else
    % levels 2 and 3 fail by shattering on the outliers: essentially every
    % wild pixel ends up as its own grain
    check(rSmooth.wildIsolated > 0.9, ...
      'level %d: only %.1f %% of the wild pixels are isolated - the failure mode changed', ...
      lvl,100*rSmooth.wildIsolated);
    check(rSmooth.numGrains > 10*nGR*nGC, ...
      'level %d: the denoised chain no longer shatters (%d grains) - update this test', ...
      lvl,rSmooth.numGrains);
  end
end

disp(' ');
disp('check_grainBenchmark: passed');

end

% --------------------------------------------------------------- helpers

function check(cond,msg,varargin)

if ~cond, error(['check_grainBenchmark: ' msg],varargin{:}); end

end

function report(lvl,name,r)

if isnan(r.minDetectedAngle), md = '  none'; else, md = sprintf('%4.0f d',r.minDetectedAngle/degree); end
if isnan(r.wildIsolated), wi = '     -'; else, wi = sprintf('%5.1f%%',100*r.wildIsolated); end

fprintf('  %d %-20s %7d   %6.4f   %s   %s\n',lvl,name,r.numGrains,r.ari,md,wi);

end
