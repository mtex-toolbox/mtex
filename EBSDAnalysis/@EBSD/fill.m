function ebsd = fill(ebsd,varargin)
% fill missing orientations by nearest neighbor within each grain
%
% Syntax
%   ebsd_filled = fill(ebsd)
%   ebsd_filled = fill(ebsd,grains)
%   ebsd_filled = fill(ebsd,mask)
%
% Input
%  ebsd   - @EBSD
%  grains - @grain2d, the outlines that decide the grain of an empty site
%  mask   - logical, the pixels filling is restricted to
%
% Options
%  gridify - return a gridded map
%
% Description
% A pixel that was not measured and a notIndexed pixel are the same to
% fill: every pixel without orientation inside the convex hull of the
% indexed measurements is filled, an empty site of the lattice as well. A mask
% restricts this to its pixels; it names only pixels of ebsd, so the empty
% sites of a list need gridify first.
%
% A filled pixel takes the orientation and phaseId of the nearest measured
% pixel of its grain. With grainId every pixel to fill needs a grain: an
% empty site takes the grain whose outline holds its whole pixel if grains
% are given, else the grainId of the nearest pixel. A pixel on a grain
% boundary, grainId 0, stays or becomes notIndexed, and so do the pixels of
% notIndexed grains. Without grainId the nearest measured pixel decides.

% TODO: this will not work for maps not in the xy plane

mask = getClass(varargin,'logical',[]);
if ~isempty(mask) && numel(mask) ~= length(ebsd)
  error('The mask needs one entry per pixel of the map.');
end
if isempty(mask) && ~isa(ebsd,'EBSDgrid') && ~check_option(varargin,'gridify')
  [ebsd,isNew] = addLatticeSites(ebsd);
else
  if isempty(mask) && ~isa(ebsd,'EBSDgrid'), ebsd = ebsd.gridify; end
  isNew = isnan(ebsd.phaseId(:));
end

% the scan is the convex hull of the indexed measurements
xy = [ebsd.pos.x(:), ebsd.pos.y(:)];
isMeasured = ~isNew & ebsd.isIndexed(:) & ~isnan(ebsd.rotations(:));
inScan = isMeasured;
if nnz(isMeasured) > 2
  h = convhull(xy(isMeasured,1),xy(isMeasured,2));
  in = find(isMeasured); h = in(h);
  inScan = inpolygon(xy(:,1),xy(:,2),xy(h,1),xy(h,2));
end
if isempty(mask), mask = true(size(inScan)); end

% empty lattice sites take grainId and phaseId of the grain they lie in,
% within the scan the others are notIndexed as the measurements on a boundary
grains = getClass(varargin,'grain2d',[]);
if ebsd.hasGrainId && ~isempty(grains)
  isEmpty = find(isnan(ebsd.grainId(:)) & mask(:));
  grains = grains(ismember(grains.id,ebsd.grainId));
  eE = ebsd; eE.phaseId(isEmpty) = 1; % subSet of a grid drops NaN phases
  [iE,iG] = find(checkInside(grains,eE.subSet(isEmpty)));
  ebsd.phaseId(isEmpty(iE)) = grains.phaseId(iG);
  ebsd.prop.grainId(isEmpty(iE)) = grains.id(iG);
  inScan(isEmpty(iE)) = true;
  rest = isEmpty(inScan(isEmpty) & ~ismember(isEmpty,isEmpty(iE)));
  ebsd.phaseId(rest) = 1;
  ebsd.prop.grainId(rest) = 0;
elseif ebsd.hasGrainId
  % without grains an empty site of the scan takes the grain of its nearest pixel
  isEmpty = find(isnan(ebsd.grainId(:)) & inScan & mask(:));
  has = find(~isnan(ebsd.grainId(:)));
  if ~isempty(isEmpty) && numel(has) > 2
    nn = has(nearestId(xy(has,:),xy(isEmpty,:)));
    ebsd.prop.grainId(isEmpty) = ebsd.grainId(nn);
    ebsd.phaseId(isEmpty) = ebsd.phaseId(nn);
  end
end

rot = ebsd.rotations(:);
tgt = find((isnan(rot) | ~ebsd.isIndexed(:)) & inScan & mask(:));
if ebsd.hasGrainId, gId = ebsd.grainId(:); else, gId = zeros(size(rot)); end
gId(isnan(gId)) = -1; % pixels without grainId form a group of their own

% nearest neighbor with the grains shifted apart by more than the map diameter
ext = ebsd.extent;
L = 2 * norm(ext([2 4]) - ext([1 3])) + 1;
src = find(~isnan(rot) & ebsd.isIndexed(:));
ebsd = copyNearest(ebsd,rot,[xy(:,1) + L*gId, xy(:,2)],src,tgt,L/2);

% drop the empty sites that were not filled
if ~isa(ebsd,'EBSDgrid')
  if ebsd.hasGrainId, keep = ~isnan(ebsd.grainId(:)); else, keep = ~isNew | ~isnan(ebsd.rotations(:)); end
  ebsd = ebsd.subSet(keep);
end

end

% -------------------------------------------------------------------------
function ebsd = copyNearest(ebsd,rot,xy,src,tgt,maxDist)
% copy orientation, phaseId and grainId from the nearest source

if numel(src) < 3 || isempty(tgt), return; end
nn = nearestId(xy(src,:),xy(tgt,:));
ok = vecnorm(xy(src(nn),:) - xy(tgt,:),2,2) < maxDist;
ebsd.rotations(tgt(ok)) = rot(src(nn(ok)));
ebsd.phaseId(tgt(ok)) = ebsd.phaseId(src(nn(ok)));
if ebsd.hasGrainId, ebsd.prop.grainId(tgt(ok)) = ebsd.prop.grainId(src(nn(ok))); end

end
