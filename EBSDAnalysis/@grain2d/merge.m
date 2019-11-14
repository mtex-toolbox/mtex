function [grainsMerged,parentId] = merge(grains,varargin)
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
%   [grainsMerged,parentId] = merge(grains,M)
%
%   [grainsMerged,parentId] = merge(grains,tpList)
%
%   [grainsMerged,parentId] = merge(grains,gid)
%
% Input
%  grains   - @grain2d
%  boundary - @grainBoundary
%  M        - merge matrix M(i,j)==1 indicates the grains to be merged
%  tpList   - @triplePointList
%  gid      - nx2list of grainIds
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


% 1. set up merge matrix
maxId = max(grains.id); % initial, empty merge matrix
A = sparse(maxId+1,maxId+1); % not indexed will be stored to maxId+1s

for k = 1:length(varargin)  
  
  if isa(varargin{k},'grainBoundary')
    
    % determine grainId of gB except for inner gB and gB with specimen boundary
    mergeId = varargin{k}.grainId;    
    mergeId(any(mergeId==0,2) | diff(mergeId,[],2) == 0,:) = [];
    
    % set up merge matrix
    A = A | sparse(mergeId(:,1),mergeId(:,2),1,maxId+1,maxId+1);
      
  elseif isa(varargin{k},'triplePointList')
    
    mergeId = varargin{k}.grainId;
    mergeId(mergeId==0) = maxId+1;
    
    A = A | sparse(mergeId(:,1),mergeId(:,2),1,maxId+1,maxId+1);
    A = A | sparse(mergeId(:,2),mergeId(:,3),1,maxId+1,maxId+1);
    A = A | sparse(mergeId(:,1),mergeId(:,3),1,maxId+1,maxId+1);
    
  elseif isnumeric(varargin{k}) && all(size(varargin{k}) == size(A))
    A = varargin{k};
  elseif  isnumeric(varargin{k}) && size(varargin{k},2) == 2
    A = sparse(varargin{k}(:,1),varargin{k}(:,2),1,maxId,maxId);
  end
end
A = A(1:maxId,1:maxId);

% ids of the grains to merge
doMerge = any(A,1) | any(A,2).';

% 2. determine grains not to touch and sort them first
keepId = find(~doMerge);
keepInd = grains.id2ind(keepId);
old2newId = zeros(maxId,1);
old2newId(keepId) = 1:numel(keepId);

% 3. determine which grains to merge
subA = A(doMerge,doMerge);
subA = subA | subA.';
old2newId(doMerge) =  numel(keepId) + connectedComponents(subA);

% 4. set up new grain variable 
numNewGrains = max(old2newId);
grainsMerged = grains;
grainsMerged.id = (1:numNewGrains).';
grainsMerged.poly = cell(numNewGrains,1);
grainsMerged.phaseId = zeros(numNewGrains,1);
grainsMerged.grainSize = zeros(numNewGrains,1);
grainsMerged.prop.meanRotation = rotation.nan(numNewGrains,1);
grainsMerged.inclusionId = zeros(numNewGrains,1);


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
grainsMerged.inclusionId(newInd) = grains.inclusionId(keepInd);

% 8. set up merged polygons
I_FG = grainsMerged.boundary.I_FG;
I_FG(:,1:numel(keepId)) = [];

newInd = numel(keepId)+(1:size(I_FG,2));
[grainsMerged.poly(newInd), grainsMerged.inclusionId(newInd)] = ...
  calcPolygons(I_FG,grainsMerged.boundary.F,grainsMerged.boundary.V);

% 9. update properties

% new grain size is sum of old grain sizes
gS = sparse(old2newId(grains.id),grains.id,grains.grainSize);
grainsMerged.grainSize= full(sum(gS,2));
  
% new phase id is max of old phase ids
phaseId = sparse(old2newId(grains.id),grains.id,grains.phaseId);
grainsMerged.phaseId = full(max(phaseId,[],2));

% should we compute meanOrientation?
if check_option(varargin,'calcMeanOrientation')

  updateOriFun = getClass(varargin,'function_handle',@updateOri);
  
  for i = newInd
    
    % compute new mean orientation
    oriNew = updateOriFun(grains.subSet(parentId == i));
  
    % set new mean rotation
    grainsMerged.prop.meanRotation(i) = rotation(oriNew);
  
    % get new phaseId
    newPhase = cellfun(@(x) isa(x,'symmetry') && x==oriNew.CS,grains.CSList);
    grainsMerged.phaseId(i) = find(newPhase);
  end
end

% update boundary phases
phaseId = zeros(size(grainsMerged.boundary.phaseId));
notZero = grainsMerged.boundary.grainId ~= 0;
phaseId(notZero) =  grainsMerged.phaseId(grainsMerged.boundary.grainId(notZero));
grainsMerged.boundary.phaseId = phaseId;

% 10. update triple points
grainsMerged.boundary.triplePoints = grainsMerged.boundary.calcTriplePoints(grainsMerged.phaseId);

end

function ori = updateOri(grains)

cs = grains.CSList{max(grains.phaseId)};
ori = mean(orientation(grains.prop.meanRotation,cs),'weights',grains.grainSize);

end
