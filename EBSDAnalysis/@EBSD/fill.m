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
%  grains - @grain2d, empty lattice sites inside these grains are filled
%  mask   - logical, the pixels to be filled
%
% Options
%  gridify - return a gridded map
%
% Description
% Every pixel with NaN orientation takes the orientation and phaseId of
% the nearest pixel with the same grainId. Pixels of a grain without any
% such pixel, e.g. a notIndexed grain, stay NaN. Empty sites of the
% lattice are filled as well. With grainId this happens only inside the
% given grains, whose grainId they take, without grainId everywhere.
% With a mask exactly the pixels in the mask are filled, from the nearest
% pixel outside the mask of the same grain, or of any grain if there is
% none, whose grainId they take.

% TODO: this will not work for maps not in the xy plane

mask = getClass(varargin,'logical',[]);
if isempty(mask) && ~isa(ebsd,'EBSDgrid')
  if check_option(varargin,'gridify')
    ebsd = ebsd.gridify;
  else
    ebsd = addLatticeSites(ebsd);
  end
end

% empty lattice sites take grainId and phaseId of the grain they lie in
grains = getClass(varargin,'grain2d',[]);
if ebsd.hasGrainId && ~isempty(grains)
  isEmpty = find(isnan(ebsd.grainId));
  grains = grains(ismember(grains.id,ebsd.grainId));
  eE = ebsd; eE.phaseId(isEmpty) = 1; % subSet of a grid drops NaN phases
  [iE,iG] = find(checkInside(grains,eE.subSet(isEmpty)));
  ebsd.phaseId(isEmpty(iE)) = grains.phaseId(iG);
  ebsd.prop.grainId(isEmpty(iE)) = grains.id(iG);
end

rot = ebsd.rotations(:);
hasMask = ~isempty(mask);
if ~hasMask, mask = isnan(rot); end
if ebsd.hasGrainId, gId = ebsd.grainId(:); else, gId = zeros(size(rot)); end
gId(isnan(gId)) = -1; % pixels without grainId form a group of their own

% nearest neighbor with the grains shifted apart by more than the map diameter
ext = ebsd.extent;
L = 2 * norm(ext([2 4]) - ext([1 3])) + 1;
xy = [ebsd.pos.x(:), ebsd.pos.y(:)];
src = find(~mask(:) & ~isnan(rot) & ebsd.isIndexed(:));
[ebsd,tgt] = copyNearest(ebsd,rot,[xy(:,1) + L*gId, xy(:,2)],src,find(mask(:)),L/2);

% the remaining mask pixels take the nearest pixel of any grain
if hasMask, ebsd = copyNearest(ebsd,rot,xy,src,tgt,inf); end

% drop the empty sites outside all grains
if ~isa(ebsd,'EBSDgrid') && ebsd.hasGrainId, ebsd = ebsd.subSet(~isnan(ebsd.grainId)); end

end

% -------------------------------------------------------------------------
function [ebsd,tgt] = copyNearest(ebsd,rot,xy,src,tgt,maxDist)
% copy orientation, phaseId and grainId from the nearest source, return the targets left

if numel(src) < 3 || isempty(tgt), return; end
nn = nearestId(xy(src,:),xy(tgt,:));
ok = vecnorm(xy(src(nn),:) - xy(tgt,:),2,2) < maxDist;
ebsd.rotations(tgt(ok)) = rot(src(nn(ok)));
ebsd.phaseId(tgt(ok)) = ebsd.phaseId(src(nn(ok)));
if ebsd.hasGrainId, ebsd.prop.grainId(tgt(ok)) = ebsd.prop.grainId(src(nn(ok))); end
tgt = tgt(~ok);

end
