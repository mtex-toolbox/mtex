function grains = subSet(grains,ind)
% 
%
% Input
%  grains - @grain2d
%  ind    - indices
%
% Output
%  grains - @grain2d
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
grains.grainSize = grains.grainSize(ind);


grains.boundary = subSet(grains.boundary,indBd);
grains.innerBoundary = subSet(grains.innerBoundary,indinnerBd);

% if we have only one grain - sort boundary segments
if length(grains) == 1
  FNew = [grains.poly{1}(1:end-1).',grains.poly{1}(2:end).'];
  
  % remove inclusion embeddings
  if grains.inclusionId > 0
    ie = any(FNew == FNew(1),2);
    ie([1,end-grains.inclusionId]) = false;
    FNew(ie,:) = [];
  end

  % sort minimum entry first
  FNew = sort(FNew,2);
    
  % sort such the order of F follows the boundary
  [~,ind1] = sortrows(grains.boundary.F);
  [~,ind2] = sortrows(FNew);
  inverseorder(ind2) = ind1;
  
  grains.boundary = grains.boundary(inverseorder);
  
  
end