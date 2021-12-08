function [pairs,ori] = getP2PPairs(job,varargin)
% 

pairs = neighbors(job.parentGrains, job.parentGrains);
pairs = sortrows(sort(pairs,2,'ascend'));

% maybe there is nothing to do
if isempty(pairs)
  ori = reshape(orientation(job.csParent),[],2);
  return
end

% compute the corresponding mean orientations
if job.useBoundaryOrientations 
  
  % identify boundaries by grain pairs
  [gB,pairId] = job.grains.boundary.selectByGrainId(pairs);
  
  % extract boundary parent orientations
  oriBnd =  job.ebsd('id',gB.ebsdId).orientations;
  
  % average parent orientations along the boundaries
  ori(:,1) = accumarray(pairId,oriBnd(:,1));
  ori(:,2) = accumarray(pairId,oriBnd(:,2));
  
else 
  
  % simply the mean orientations of the grains
  %ori = job.grains('id',pairs).meanOrientation;
  ori = orientation(job.grains.prop.meanRotation(job.grains.id2ind(pairs)),...
    job.csParent);
  ori = reshape(ori,size(pairs));
  
end

% translate to index if required
if check_option(varargin,'index'), pairs = job.grains.id2ind(pairs); end

end