function [grainsMerged,parentId] = merge(grains,gB,varargin)
% merge grains along special grain boundaries
%
% Whenever two grains share a grain boundary that is in the list |gB| both
% grains are merged and the common grain boundary is removed. All the 
% properties of the unmerged grains are removed in the merged grains, since
% there is no common convention for a mean. In case of merging allong small
% angle grain boundaries one can force MTEX to compute a new
% meanOrientation using the option |calcMeanOrientation|.
%
% Syntax
%   [grainsMerged,parentId] = merge(grains,gB)
%
%   % compute new meanOrientations for the grains
%   [grainsMerged,parentId] = merge(grains,gB,'calcMeanOrientation')
%
% Input
%  grains   - @grain2d
%  boundary - @grainBoundary
%
% Output
%  grainsMerged - @grain2d
%  parentId      - a list of the same size as grains containing the ids of the merged grains
%
% Example:
%
%   mtexdata small
%   grains = smooth(calcGrains(ebsd))
%
%   % merge all neigbouring Diopside grains
%   gB = grains.boundary('Diopside','Diopside')
%   [grains_m,parentId] = merge(grains,gB)


% 1. determine grainId of gB except for inner gB and gB with specimen boundary
mergeId = gB.grainId;
mergeId(any(mergeId==0,2) | diff(mergeId,[],2) == 0,:) = [];

% 2. determine grains not to touch
[keepId,keepInd] = setdiff(grains.id,mergeId(:));
old2newId = zeros(max(grains.id),1);
old2newId(keepId) = 1:numel(keepId);

% 3. determine which grains to merge
A = sparse(mergeId(:,1),mergeId(:,2),1,length(grains),length(grains));
ind = any(A,1) | any(A,2).';
subA = A(ind,ind);
subA = subA | subA.';
old2newId(ind) =  numel(keepId) + connectedComponents(subA);

% 4. set up new grain variable 
numNewGrains = max(old2newId);
grainsMerged = grains;
grainsMerged.id = (1:numNewGrains).';
grainsMerged.poly = cell(numNewGrains,1);
grainsMerged.phaseId = zeros(numNewGrains,1);
grainsMerged.grainSize = zeros(numNewGrains,1);
grainsMerged.prop.meanRotation = rotation.id(numNewGrains,1);

% 5. set new grainIds in grains.boundary
ind = grains.boundary.grainId > 0;
grainsMerged.boundary.grainId(ind) = old2newId(grains.boundary.grainId(ind));

% and in the old grains
parentId = old2newId(grains.id);

% 6. remove "new inner" grain boundaries 
inner = diff(grainsMerged.boundary.grainId,1,2) == 0;
grainsMerged.boundary(inner) = [];

% 7. set up unmerged polygons
newInd = old2newId(keepId);
grainsMerged.poly(newInd) = grains.poly(keepInd);
grainsMerged.phaseId(newInd) = grains.phaseId(keepInd);
grainsMerged.grainSize(newInd) = grains.grainSize(keepInd);
grainsMerged.prop.meanRotation(newInd) = grains.prop.meanRotation(keepInd);

% 8. set up merged polygons
I_FG = grainsMerged.boundary.I_FG;
I_FG(:,1:numel(keepId)) = [];

newInd = numel(keepId)+(1:size(I_FG,2));
grainsMerged.poly(newInd) = ...
  calcPolygons(I_FG,grainsMerged.boundary.F,grainsMerged.boundary.V);

% new grain size is sum of old grain sizes
gS = sparse(old2newId(grains.id),grains.id,grains.grainSize);
grainsMerged.grainSize= full(sum(gS,2));
  
% new phase id is max of old phase ids
phaseId = sparse(old2newId(grains.id),grains.id,grains.phaseId);
grainsMerged.phaseId = max(phaseId,[],2);

% should we compute meanOrientation?
if check_option(varargin,'calcMeanOrientation')

  % remove all other properties
  grainsMerged.prop = struct('meanRotation',grainsMerged.prop.meanRotation);
  
  % update meanRotation 
  for i = 1:numel(newInd)
    ind = parentId == newInd(i);
    cs = grains.CSList{grainsMerged.phaseId(newInd(i))};
    grainsMerged.prop.meanRotation(newInd(i)) = rotation(...
      mean(orientation(grains.prop.meanRotation(ind),cs),'weights',grains.grainSize(ind)));
  end
else
  % remove all other properties
  grainsMerged.prop = struct;
end

% update triple points
grainsMerged.boundary.triplePoints = grainsMerged.boundary.calcTriplePoints(grainsMerged.phaseId);