function grains = subSet(grains,ind, varargin)
% 
%
% Input
%  grains - @grain2d
%  ind    - indices
%
% Output
%  grains - @grain2d
%
% Options
%  keepOrder - deprecated, has no effect - faces are always in walk order
%


% restrict boundary
if islogical(ind)
  % the problem is grainId is with respect to grain.id
  % but ind is with respect to the order of the grains
  % therefore we have to enlarge ind
  indLarge = false(max(grains.boundary.grainId(:)),1);
  indLarge(grains.id) = ind;
  
  grId = grains.boundary.grainId;
  grId(grId>0) = indLarge(grId(grId>0));
  indBd = any(grId,2);
  %repeat for inner Boundary
  indinLarge = false(max(grains.innerBoundary.grainId(:)),1);
  indinLarge(grains.id) = ind;
  
  grinId = grains.innerBoundary.grainId;
  grinId(grinId>0) = indinLarge(grinId(grinId>0));
  indinnerBd = any(grinId,2);

else
  indBd = any(ismember(grains.boundary.grainId,grains.id(ind)),2);
  indinnerBd = any(ismember(grains.innerBoundary.grainId,grains.id(ind)),2);
end

grains = subSet@dynProp(grains,ind);

grains.poly = grains.poly(ind);
grains.inclusionId = grains.inclusionId(ind);
grains.id = grains.id(ind);
grains.phaseId = reshape(grains.phaseId(ind),[],1);
grains.numPixel = grains.numPixel(ind);

%if ~islogical(ind)
%  grains.prop.meanRotation = reshape(grains.prop.meanRotation, size(ind));
%end

grains.boundary = subSet(grains.boundary,indBd);
grains.innerBoundary = subSet(grains.innerBoundary,indinnerBd);

% boundary segments used to be sorted into walk order here, but only for a
% single grain, which made grains(k).boundary ordered while grains.boundary
% was not. Segments are now stored in walk order throughout and subSet
% preserves it, so there is nothing left to do - and 'keepOrder' has no
% effect any more.
