function [pairs,ori] = getC2CPairs(job,varargin)
% 

pairs = neighbors(job.childGrains, job.childGrains);
pairs = sortrows(sort(pairs,2,'ascend'));

% maybe there is nothing to do
if isempty(pairs)
  ori = reshape(orientation(job.csChild),[],2);
  return
end

% compute the corresponding mean orientations
if job.useBoundaryOrientations 
  
  % identify boundaries by grain pairs
  [gB,pairId] = job.grains.boundary.selectByGrainId(pairs);
  
  % extract boundary child orientations
  oriBnd =  job.ebsdPrior('id',gB.ebsdId).orientations;
  
  % average child orientations along the boundaries
  ori(:,1) = accumarray(pairId,oriBnd(:,1));
  ori(:,2) = accumarray(pairId,oriBnd(:,2));
  
else 
  
  % simply the mean orientations of the grains
  ori = job.grains('id',pairs).meanOrientation;
  
end

end