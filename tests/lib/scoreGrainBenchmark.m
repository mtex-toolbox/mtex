function report = scoreGrainBenchmark(ebsd,grains,varargin)
% score a grain reconstruction against the ground truth of
% EBSDGrainBenchmark
%
% The primary output is a per boundary detection table indexed by the
% prescribed misorientation angle, which answers the only question that
% really matters: down to which misorientation angle are boundaries
% recovered. A single scalar (the adjusted Rand index) is reported
% alongside so that regressions can be asserted in a check_ script.
%
% Purity is deliberately NOT reported: it is maximised by shattering the
% map into single pixel grains and therefore cannot be used as a score.
%
% Syntax
%   scoreGrainBenchmark(ebsd,grains)          % prints a report
%   report = scoreGrainBenchmark(ebsd,grains) % returns it as a struct
%
% Input
%  ebsd   - @EBSD as returned by calcGrains, i.e. carrying grainId, and
%           still carrying the prop/opt fields set by EBSDGrainBenchmark
%  grains - @grain2d (optional, only used for the grain count)
%
% Options
%  splitTol - minimum fraction of a true grain that a reconstructed grain
%             must cover to count as a genuine split (default: 0.05)
%
% Output
%  report - struct with fields
%    byAngle          - table of nominal angle (rad), number of boundaries,
%                       number detected, mean fraction of the boundary
%                       actually separated
%    minDetectedAngle - smallest nominal angle (rad) at and above which
%                       every boundary was detected (NaN if even the
%                       largest was missed)
%    numGrains, numTrueGrains
%    fragments        - total number of EXTRA pieces true grains were broken
%                       into, so a shattered map scores badly here even when
%                       every boundary is nominally detected
%    majorSplits      - same, counting only pieces covering at least
%                       splitTol of the true grain
%    ari              - adjusted Rand index over valid pixels
%    wildAbsorbed     - fraction of wild pixels assigned to the grain they
%                       geometrically belong to
%    wildIsolated     - fraction of wild pixels that became their own grain
%    unindexedAssigned- fraction of notIndexed pixels given a nonzero grainId
%
% See also
%  EBSDGrainBenchmark

if nargin < 2, grains = []; end
splitTol = get_option(varargin,'splitTol',0.05);

if ~isfield(ebsd.prop,'trueGrainId')
  error('ebsd does not carry ground truth - was it made by EBSDGrainBenchmark?');
end
if ~isfield(ebsd.prop,'grainId')
  error('ebsd does not carry grainId - pass the ebsd RETURNED by calcGrains');
end

sz  = size(ebsd);
tid = reshape(ebsd.prop.trueGrainId,sz);
gid = reshape(ebsd.grainId,sz);

isWild  = reshape(ebsd.prop.isWild,sz);
isUnind = reshape(ebsd.prop.isUnindexed,sz);

nGR = ebsd.opt.numGrainRows;
nGC = ebsd.opt.numGrainCols;
nP  = nGR*nGC;

% pixels used for partition scoring: indexed, not wild, actually assigned
valid = ~isWild & ~isUnind & gid > 0;

% ------------------------------------------------- contingency true x reco

t = tid(valid); g = gid(valid);
[gLab,~,gIdx] = unique(g);
C = full(sparse(t,gIdx,1,nP,numel(gLab)));

% dominant reconstructed label per true grain
[~,domCol] = max(C,[],2);
dom = nan(nP,1);
ok  = sum(C,2) > 0;
dom(ok) = gLab(domCol(ok));

% ------------------------------------------- per boundary pixel pair counts
% per pair of adjacent true grains: how many pixel pairs straddle it, how many were separated

cnt = zeros(nP); sep = zeros(nP);
[cnt,sep] = tally(cnt,sep,tid(:,1:end-1),tid(:,2:end), ...
  gid(:,1:end-1),gid(:,2:end),valid(:,1:end-1)&valid(:,2:end),nP);
[cnt,sep] = tally(cnt,sep,tid(1:end-1,:),tid(2:end,:), ...
  gid(1:end-1,:),gid(2:end,:),valid(1:end-1,:)&valid(2:end,:),nP);

% ---------------------------------------------------- walk every boundary

colAngles = ebsd.opt.colAngles;
rowAngles = ebsd.opt.rowAngles;

nomAngle = []; detected = []; fracSep = [];

% grain (i,j) has the index i + (j-1)*nGR, see EBSDGrainBenchmark

for i = 1:nGR                     % vertical boundaries, between columns
  for j = 1:nGC-1
    a = i + (j-1)*nGR; b = a + nGR;
    [nomAngle,detected,fracSep] = addBoundary(nomAngle,detected,fracSep, ...
      colAngles(j),a,b,dom,cnt,sep);
  end
end

for i = 1:nGR-1                   % horizontal boundaries, between rows
  for j = 1:nGC
    a = i + (j-1)*nGR; b = a + 1;
    [nomAngle,detected,fracSep] = addBoundary(nomAngle,detected,fracSep, ...
      rowAngles(i),a,b,dom,cnt,sep);
  end
end

% ------------------------------------------------------ aggregate by angle

% group in degree to be robust against round off, report in rad
[uAng,~,idx] = unique(round(nomAngle/degree*1e6)/1e6);
uAng = uAng * degree;
byAngle = struct('angle',num2cell(uAng(:)));
for k = 1:numel(uAng)
  s = idx == k;
  byAngle(k).numBoundaries = sum(s);
  byAngle(k).numDetected   = sum(detected(s));
  byAngle(k).fracSeparated = mean(fracSep(s));
end

% smallest angle at and above which everything was detected
minDet = NaN;
for k = numel(uAng):-1:1
  if all([byAngle(k:end).numDetected] == [byAngle(k:end).numBoundaries])
    minDet = uAng(k);
  else
    break
  end
end

% ------------------------------------------------------------ over/under

% 'fragments' counts every extra piece, 'majorSplits' only the genuine splits
nTruePix = sum(C,2);
fragments = 0; majorSplits = 0;
for k = 1:nP
  if nTruePix(k) == 0, continue, end
  fragments   = fragments   + max(0,sum(C(k,:) > 0) - 1);
  majorSplits = majorSplits + max(0,sum(C(k,:) >= splitTol*nTruePix(k)) - 1);
end

% ------------------------------------------------------------- outliers

wildAbsorbed = NaN; wildIsolated = NaN;
if any(isWild(:))
  wt = tid(isWild); wg = gid(isWild);
  wildAbsorbed = mean(wg == dom(wt) & wg > 0);
  gCount = accumarray(gid(gid>0),1);
  own = wg > 0 & gCount(max(wg,1)) == 1;
  wildIsolated = mean(own);
end

unindAssigned = NaN;
if any(isUnind(:)), unindAssigned = mean(gid(isUnind) > 0); end

% ------------------------------------------------------------------ output

report = struct;
report.byAngle          = byAngle;
report.minDetectedAngle = minDet;
report.numTrueGrains    = nP;
if isempty(grains)
  report.numGrains = numel(unique(gid(gid>0)));
else
  report.numGrains = length(grains);
end
report.fragments         = fragments;
report.majorSplits       = majorSplits;
report.ari               = adjustedRand(C);
report.wildAbsorbed      = wildAbsorbed;
report.wildIsolated      = wildIsolated;
report.unindexedAssigned = unindAssigned;

if nargout == 0, printReport(report,ebsd); clear report; end

end

% ------------------------------------------------------------- helpers

function [cnt,sep] = tally(cnt,sep,ta,tb,ga,gb,v,nP)
% accumulate straddling pixel pairs per pair of adjacent true grains

s = v & ta ~= tb;
if ~any(s(:)), return, end

lo = min(ta(s),tb(s)); hi = max(ta(s),tb(s));
lin = sub2ind([nP nP],lo,hi);

cnt = cnt + reshape(accumarray(lin,1,[nP*nP 1]),nP,nP);
sep = sep + reshape(accumarray(lin,double(ga(s) ~= gb(s)),[nP*nP 1]),nP,nP);

end

function [nom,det,frac] = addBoundary(nom,det,frac,angle,a,b,dom,cnt,sep)

lo = min(a,b); hi = max(a,b);

nom(end+1)  = angle; %#ok<AGROW>
det(end+1)  = ~isnan(dom(a)) && ~isnan(dom(b)) && dom(a) ~= dom(b); %#ok<AGROW>
if cnt(lo,hi) > 0
  frac(end+1) = sep(lo,hi)/cnt(lo,hi); %#ok<AGROW>
else
  frac(end+1) = NaN; %#ok<AGROW>
end

end

function ari = adjustedRand(C)
% adjusted Rand index of a contingency table

n = sum(C(:));
if n < 2, ari = NaN; return, end

nij = sum(nchoose2(C(:)));
ai  = sum(nchoose2(sum(C,2)));
bj  = sum(nchoose2(sum(C,1)));
ex  = ai*bj/nchoose2(n);

den = 0.5*(ai+bj) - ex;
if den == 0, ari = 1; else, ari = (nij - ex)/den; end

end

function y = nchoose2(x), y = x.*(x-1)/2; end

function printReport(r,ebsd)

fprintf('\n grain benchmark: %d x %d grains, %d pixels', ...
  ebsd.opt.numGrainRows,ebsd.opt.numGrainCols,length(ebsd));
fprintf('  (noise %.2f deg, deformation %.2f deg)\n', ...
  ebsd.opt.noiseLevel/degree,ebsd.opt.deformation/degree);

fprintf('\n  angle    boundaries   detected   separated\n');
fprintf(  ' ------------------------------------------\n');
for k = 1:numel(r.byAngle)
  b = r.byAngle(k);
  fprintf('  %4.1f deg     %3d        %3d/%-3d    %6.1f %%\n', ...
    b.angle/degree,b.numBoundaries,b.numDetected,b.numBoundaries,100*b.fracSeparated);
end

fprintf('\n  minimum fully detected angle : ');
if isnan(r.minDetectedAngle), fprintf('none\n');
else, fprintf('%.1f deg\n',r.minDetectedAngle/degree); end

fprintf('  grains  reconstructed / true : %d / %d\n',r.numGrains,r.numTrueGrains);
fprintf('  excess fragments / major     : %d / %d\n',r.fragments,r.majorSplits);
fprintf('  adjusted Rand index          : %.4f\n',r.ari);
if ~isnan(r.wildAbsorbed)
  fprintf('  wild pixels absorbed / alone : %.1f %% / %.1f %%\n', ...
    100*r.wildAbsorbed,100*r.wildIsolated);
end
if ~isnan(r.unindexedAssigned)
  fprintf('  notIndexed pixels assigned   : %.1f %%\n',100*r.unindexedAssigned);
end
fprintf('\n');

end
