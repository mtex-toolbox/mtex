function job = calcParent2Child(job, varargin)
      
% get p2c from parent 2 child OR
if nnz(job.ebsd.phaseId==job.parentPhaseId) > 0.01 * length(job.ebsd)
  
  pairs = neighbors(job.grains(job.csParent),job.grains(job.csChild));

  p2c0 = inv(job.grains(pairs(:,2)).meanOrientation) .* job.grains(pairs(:,1)).meanOrientation;
  
else
  
  %alpha = 0.001;
  p2c0 = orientation.KurdjumovSachs(job.csParent,job.csChild);
  
end

if check_option(varargin,'noC2C')

  job.p2c = mean(p2cAll,'robust');
  
else % consider also child 2 child 
  
  % get neighbouring grain pairs
  grainPairs = job.grains(job.csChild).neighbors;

  if ~isempty(job.p2c), p2c0 = job.p2c; end
  p2c0 = getClass(varargin,'orientation',p2c0);

  % compute an optimal parent to child orientation relationship
  [job.p2c, job.fit] = calcParent2Child(job.grains(grainPairs).meanOrientation,p2c0);
  
end
   
end