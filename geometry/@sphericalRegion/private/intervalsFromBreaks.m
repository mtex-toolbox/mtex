function [aMin,aMax] = intervalsFromBreaks(sR,breaks,lo,hi,gridLine,mkVec)
% turn the crossings of the bounding circles into intervals
%
% Syntax
%   [aMin,aMax] = intervalsFromBreaks(sR,breaks,lo,hi,gridLine,mkVec)
%
% Input
%  sR       - @sphericalRegion
%  breaks   - nB × n, the angles where a bounding circle is crossed
%  lo, hi   - the range the angle is searched in
%  gridLine - 1 × n, the value of the other angle
%  mkVec    - @(angle,gridLine) the @vector3d those two stand for
%
% Output
%  aMin - nInt × n, padded with NaN
%  aMax - nInt × n, padded with NaN
%
% Description
% Between two consecutive crossings the region can not change, so testing
% one point per gap decides the whole gap, and the intervals are the maximal
% runs of neighbouring gaps that are inside. The crossings themselves are
% tested as well, because a bounding circle may touch a grid line rather
% than cross it - the region is then a single point there, which is what
% makes the grid reach into a vertex of a sector.

n = numel(gridLine);

% only crossings within the range are breaks, and lo and hi always are
breaks(breaks < lo | breaks > hi) = NaN;
breaks = [repmat([lo;hi],1,n); breaks];

% sort each grid line and merge crossings that coincide
b = cell(1,n); mid = cell(1,n);
for k = 1:n
  bk = sort(breaks(~isnan(breaks(:,k)),k));
  bk = bk([true;diff(bk) > 1e-9]);
  b{k} = bk;
  mid{k} = 0.5*(bk(1:end-1) + bk(2:end));
end

% decide all gaps and all breaks of all grid lines in one go
nMid = reshape(cellfun(@numel,mid),[],1);
nB = reshape(cellfun(@numel,b),[],1);

% note repelem returns a row for a scalar gridLine, so reshape is required
inside = sR.checkInside(mkVec(...
  [vertcat(mid{:});vertcat(b{:})],...
  [reshape(repelem(gridLine(:),nMid),[],1);reshape(repelem(gridLine(:),nB),[],1)]));

inMid = reshape(inside(1:sum(nMid)),[],1);
inB = reshape(inside(sum(nMid)+1:end),[],1);

lower = cell(1,n); upper = cell(1,n);
posMid = 0; posB = 0;
for k = 1:n

  gap = inMid(posMid+(1:nMid(k))); posMid = posMid + nMid(k);
  pnt = inB(posB+(1:nB(k))); posB = posB + nB(k);

  % the maximal runs of gaps inside the region
  d = diff([false;gap;false]);
  s = find(d > 0); e = find(d < 0);

  % plus the isolated points of contact, i.e. a break that is inside while
  % neither of its two gaps is
  iso = find(pnt & ~[false;gap] & ~[gap;false]);

  [l,ord] = sort([b{k}(s);b{k}(iso)]);
  u = [b{k}(e);b{k}(iso)];
  lower{k} = l; upper{k} = u(ord);
end

nInt = max([1,cellfun(@numel,lower)]);
aMin = nan(nInt,n);
aMax = nan(nInt,n);
for k = 1:n
  aMin(1:numel(lower{k}),k) = lower{k};
  aMax(1:numel(upper{k}),k) = upper{k};
end

end
