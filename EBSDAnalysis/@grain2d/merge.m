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
%   % merge by a list of pairs of grainIds
%   [grainsMerged,parentId] = merge(grains,gid)
%
%   % merge grains with small misorientation angle
%   [grainsMerged,parentId] = merge(grains,'threshold',delta)
% 
%   % merge all inclusions with a maximum pixel size
%   [grainsMerged,parentId] = merge(grains,'inclusions','maxSize',5)
%
% Input
%  grains   - @grain2d
%  boundary - @grainBoundary
%  M        - merge matrix M(i,j)==1 indicates the grains to be merged
%  tpList   - @triplePointList
%  gid      - n x 2 list of grainIds
%
% Output
%  grainsMerged - @grain2d
%  parentId     - a list of the same size as grains containing the ids of the merged grains
%
% Options
%  threshold - maximum misorientation angle to be merged as similar
%  maxSize   - maximum number of pixels to be merged as an inclusion 
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
    
  elseif isnumeric(varargin{k}) && all(size(varargin{k}) == size(A)-1) 
    % adjecency matrix
    
    % this supindexing is required as varargin{k} is only maxId x maxId
    A(1:maxId,1:maxId) = A(1:maxId,1:maxId) + varargin{k};
    
  elseif  isnumeric(varargin{k}) && size(varargin{k},2) == 2 
    % pairs of grains
    
    A = sparse(varargin{k}(:,1),varargin{k}(:,2),1,maxId+1,maxId+1);
    
  elseif ischar(varargin{k}) && strcmpi(varargin{k},'inclusions')
    
    [isIncl, hostId] = grains.isInclusion;
    isIncl = isIncl & grains.grainSize < get_option(varargin,'maxSize',inf);
    
    % additional condition on the inclusion
    cond = get_option(varargin,'inclusions');
    if numel(cond) == length(grains), isIncl = isIncl & cond; end
    
    % additional condition on the host
    cond = get_option(varargin,'host');
    if ~isempty(cond)
      isIncl(isIncl) = cond(grains.id2ind(hostId(isIncl)));
    end

    A = sparse(grains.id(isIncl),hostId(isIncl),1,maxId+1,maxId+1);
    bSize = grains.boundarySize;
    
    varargin = [varargin,'calcMeanOrientation','inclusion'];     %#ok<AGROW>
    
  elseif ischar(varargin{k}) && strcmpi(varargin{k},'threshold')

    delta = get_option(varargin,'threshold');
    
    grainPairs = unique(grains.boundary.grainId,'rows');
    indPairs = id2ind(grains,grainPairs);
    grainPairs = grainPairs(all(indPairs ~= 0,2),:);
    indPairs = indPairs(all(indPairs ~= 0,2),:);
    
    for phId = grains.indexedPhasesId
      
      ind = all(grains.phaseId(indPairs)==phId,2);
      
      % extract the meanorientations
      oriPairs = orientation(grains.prop.meanRotation(indPairs(ind,:)),grains.CSList{phId});
      oriPairs = reshape(oriPairs,[],2);
      
      % check mean orientation difference is below a threshold
      ind(ind) = angle(oriPairs(:,1),oriPairs(:,2)) < delta;
  
      A = A + sparse(grainPairs(ind,1),grainPairs(ind,2),1,maxId+1,maxId+1); 
      
    end

    varargin = [varargin,'calcMeanOrientation'];     %#ok<AGROW>

  end
end

% remove everything that is not in grains
A = A(1:maxId,1:maxId);
isInGrains = false(1,maxId);
isInGrains(grains.id) = true;
A(~isInGrains,:) = 0;
A(:,~isInGrains) = 0;

% maybe we provide old2newId directly
if isnumeric(varargin{1}) && length(varargin{1}) == length(grains) && size(varargin{1},2)==1
  
  old2newId = varargin{1};
  
  keepId = [];
  keepInd = [];
  
else

  % ids of the grains to merge
  doMerge = any(A,1) | any(A,2).';

  % 2. determine grains not to touch and sort them first
  keepId = find(~doMerge & isInGrains);
  keepInd = grains.id2ind(keepId);
  old2newId = zeros(maxId,1);
  old2newId(keepId) = 1:numel(keepId);

  % 3. determine which grains to merge
  subA = A(doMerge,doMerge);
  subA = subA | subA.';
  old2newId(doMerge) =  numel(keepId) + connectedComponents(subA); 
  
end

% and in the old grains
parentId = old2newId(grains.id);

if check_option(varargin,'testRun'), grainsMerged = []; return; end

% 4. set up new grain variable 
numNewGrains = max(old2newId);
grainsMerged = grains;
grainsMerged.id = (1:numNewGrains).';
grainsMerged.poly = cell(numNewGrains,1);
grainsMerged.phaseId = zeros(numNewGrains,1);
grainsMerged.grainSize = zeros(numNewGrains,1);
grainsMerged.inclusionId = zeros(numNewGrains,1);

% set up properties
for fn = fieldnames(grains.prop).'
  if isnumeric(grains.prop.(char(fn)))
    grainsMerged.prop.(char(fn)) = nan(numNewGrains,1);
  else
    grainsMerged.prop.(char(fn)) = grains.prop.(char(fn)).nan(numNewGrains,1);
  end
end

% 5. set new grainIds in grains.boundary and grains.innerBoundary
ind = grains.boundary.grainId > 0;
grainsMerged.boundary.grainId(ind) = old2newId(grains.boundary.grainId(ind));
ind = grains.innerBoundary.grainId > 0;
grainsMerged.innerBoundary.grainId(ind) = old2newId(grains.innerBoundary.grainId(ind));

% 6. remove "new inner" grain boundaries 
inner = diff(grainsMerged.boundary.grainId,1,2) == 0;
grainsMerged.boundary(inner) = [];

% 7. set up unmerged polygons
newInd = old2newId(keepId);
grainsMerged.poly(newInd) = grains.poly(keepInd);
grainsMerged.phaseId(newInd) = grains.phaseId(keepInd);
grainsMerged.grainSize(newInd) = grains.grainSize(keepInd);
grainsMerged.inclusionId(newInd) = grains.inclusionId(keepInd);

% copy properties
for fn = fieldnames(grains.prop).'
  grainsMerged.prop.(char(fn))(newInd) = grains.prop.(char(fn))(keepInd);
end

% 8. set up merged polygons
I_FG = grainsMerged.boundary.I_FG;
I_FG(:,1:numel(keepId)) = [];

newInd = numel(keepId)+(1:size(I_FG,2));
[grainsMerged.poly(newInd), grainsMerged.inclusionId(newInd)] = ...
  calcPolygons(I_FG,grainsMerged.boundary.F,grainsMerged.allV);

% 9. update properties

% new grain size is sum of old grain sizes
gS = sparse(old2newId(grains.id),grains.id,grains.grainSize);
grainsMerged.grainSize= full(sum(gS,2));
  
% new phase id is max of old phase ids
phaseId = sparse(old2newId(grains.id),grains.id,grains.phaseId);
grainsMerged.phaseId = full(max(phaseId,[],2));

% should we compute meanOrientation?
if check_option(varargin,'calcMeanOrientation')

  updateOriFun = get_option(varargin,'calcMeanOrientation');
    
  for i = newInd
    
    % compute new mean orientation
    if isa(updateOriFun,'function_handle')
      
      oriNew = updateOriFun(grains.subSet(parentId == i));
      
    elseif ischar(updateOriFun) && strcmpi(updateOriFun,'inclusion')
    
      % the host grain is the one with the biggest circumstance
      ind = find(parentId == i);
      [~,hInd] = max(bSize(ind));
      ind = ind(hInd);
      
      % take the host orientation for the merged grain
      cs = grains.CSList{grains.phaseId(ind)};
      oriNew = orientation(grains.prop.meanRotation(ind),cs);
      
    else % compute the mean between the merged orientationss
      
      ind = parentId == i;
      cs = grains.CSList{max(grains.phaseId(ind))};
      oriNew = mean(orientation(grains.prop.meanRotation(ind),cs),'weights',grains.grainSize(ind));
            
    end
  
    % set new mean rotation
    grainsMerged.prop.meanRotation(i) = rotation(oriNew);
  
    % get new phaseId
    if exist('cs','var') && ischar(cs) 
      grainsMerged.phaseId(i) = 1;
    else
      newPhase = cellfun(@(x) isa(x,'symmetry') && x==oriNew.CS,grains.CSList);
      grainsMerged.phaseId(i) = find(newPhase);
    end
  end
end

% update boundary phases
phaseId = zeros(size(grainsMerged.boundary.phaseId));
notZero = grainsMerged.boundary.grainId ~= 0;
phaseId(notZero) =  grainsMerged.phaseId(grainsMerged.boundary.grainId(notZero));
grainsMerged.boundary.phaseId = phaseId;

% 10. update triple points
grainsMerged.boundary.triplePoints = grainsMerged.boundary.calcTriplePoints;

end


