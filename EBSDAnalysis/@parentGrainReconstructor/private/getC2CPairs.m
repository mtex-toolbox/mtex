function [pairs,ori,weights] = getC2CPairs(job,varargin)
% 

% all child to child pairs
pairs = neighbors(job.grains);

ind = all(ismember(pairs, job.grains.id(job.isChild)), 2);
pairs = pairs(ind,:);

% remove self boundaries
pairs(pairs(:,1)==pairs(:,2)) = [];
pairs = sortrows(sort(pairs,2,'ascend'));

if  check_option(varargin,'quick') && length(pairs) > 10000
  ind = unique(randi(length(pairs),10000,1));
  pairs = pairs(ind,:);
end

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

% remove pairs of similar orientations
% as they will not vote reliably for a parent orientation
if check_option(varargin,'minDelta')
  ind = angle(ori(:,1),ori(:,2)) < get_option(varargin,'minDelta');

  ori(ind,:) = [];
  pairs(ind,:) = [];
end

if check_option(varargin,'curvatureFactor')
  weights = calcBndWeights(job.grains.boundary, pairs, varargin{:});  
else  
  weights = 1;      
end

% translate to index if required
if check_option(varargin,'index'), pairs = job.grains.id2ind(pairs); end
