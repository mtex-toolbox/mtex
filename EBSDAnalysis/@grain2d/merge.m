function [grains_merged,parentId] = merge(grains, gB)
% merge grains along certain grain boundaries
%
% The function merges grains where the special boundary is determined by
% the function <GrainSet.specialBoundary.html specialBoundary>
%
% Input
%  grains   - @grain2d
%  boundary - @grainBoundary
%
% Output
%  grains_merged - @grain2d
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
A = full(A + A.');
ind = any(A,1);
old2newId(ind) =  numel(keepId) + connectedComponents(A(ind,ind));

% 4. set up new grain variable 
numNewGrains = max(old2newId);
grains_merged = grains;
grains_merged.id = (1:numNewGrains).';
grains_merged.poly = cell(numNewGrains,1);
grains_merged.phaseId = zeros(numNewGrains,1);
grains_merged.grainSize = zeros(numNewGrains,1);
grains_merged.prop.meanRotation = idRotation(numNewGrains,1);

% 5. set new grainIds in grains.boundary
ind = grains.boundary.grainId > 0;
grains_merged.boundary.grainId(ind) = old2newId(grains.boundary.grainId(ind));

% and in the old grains
parentId = old2newId(grains.id);

% 6. remove "new inner" grain boundaries 
inner = diff(grains_merged.boundary.grainId,1,2) == 0;
grains_merged.boundary(inner) = [];

% 7. set up unmerged polygons
newInd = old2newId(keepId);
grains_merged.poly(newInd) = grains.poly(keepInd);
grains_merged.phaseId(newInd) = grains.phaseId(keepInd);
grains_merged.grainSize(newInd) = grains.grainSize(keepInd);
grains_merged.prop.meanRotation(newInd) = grains.prop.meanRotation(keepInd);

% 8. set up merged polygons
I_FG = grains_merged.boundary.I_FG;
I_FG(:,1:numel(keepId)) = [];

newInd = numel(keepId)+(1:size(I_FG,2));
grains_merged.poly(newInd) = ...
  calcPolygons(I_FG,grains_merged.boundary.F,grains_merged.boundary.V);

% new grain size is sum of old grain sizes
gS = sparse(old2newId(grains.id),grains.id,grains.grainSize);
grains_merged.grainSize= sum(gS,2);
  
% new phase id is max of old phase ids
phaseId = sparse(old2newId(grains.id),grains.id,grains.phaseId);
grains_merged.phaseId = max(phaseId,[],2);
  
% update meanRotation
for i = 1:numel(newInd)
  ind = parentId == newInd(i);
  cs = grains.CSList{grains_merged.phaseId(newInd(i))};
  grains_merged.prop.meanRotation(newInd(i)) = rotation(...
    mean(orientation(grains.prop.meanRotation(ind),cs),'weights',grains.grainSize(ind)));
end
