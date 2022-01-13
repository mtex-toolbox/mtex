function [pairs,pOri,cOri] = getP2CPairs(job,varargin)
% 

% all parent - child neighbors
pairs = neighbors(job.grains);

isParent = ismember(pairs, job.grains.id(job.isParent));
isChild = ismember(pairs, job.grains.id(job.isChild));

ind = any(isParent,2) & any(isChild,2);
pairs = pairs(ind,:);

% ensure parent is first
doFlip = isChild(ind,1);
pairs(doFlip,:) = fliplr(pairs(doFlip,:));

if  check_option(varargin,'quick') && length(pairs) > 10000
  ind = unique(randi(length(pairs),10000,1));
  pairs = pairs(ind,:);
end

% maybe there is nothing to do
if isempty(pairs)
  pOri = orientation(job.csParent);
  cOri = orientation(job.csChild);
  return
end

% compute the corresponding mean orientations
if job.useBoundaryOrientations 
  
  % identify boundaries by grain pairs
  [gB,pairId] = job.grains.boundary.selectByGrainId(pairs);
  
  % extract boundary child orientations
  % TODO: this can be done faster
  pOri = job.ebsd('id',gB.ebsdId(:,1)).orientations; 
  cOri = job.ebsdPrior('id',gB.ebsdId(:,2)).orientations;
  
  % average child orientations along the boundaries
  pOri = accumarray(pairId,pOri);
  cOri = accumarray(pairId,cOri);
  
else 
  
  % simply the mean orientations of the grains
  pOri = job.grains('id',pairs(:,1)).meanOrientation;
  cOri = job.grains('id',pairs(:,2)).meanOrientation;
  
end

% translate to index if required
if check_option(varargin,'index'), pairs = job.grains.id2ind(pairs); end

end