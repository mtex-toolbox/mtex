function job = calcParent2Child(job, varargin)
%
% Syntax
%   job.calcParent2Child
%
% Input
%  job - @parentGrainReconstructor
%
% Output
%  job.p2c - fitted parent to child orientation relationship
%  job.fit - fit between the c2c misorientations to the fitted p2c
%
% Options
%  noC2C - do not consider child to child orientation relationships
%  noP2C - do not consider parent to child orientation relationships
%  dampingFactor - 
%  threshold     - 
%
      
% get p2c from parent 2 child OR
if nnz(job.ebsd.phaseId==job.parentPhaseId) > 0.01 * length(job.ebsd)
  
  p2cPairs = neighbors(job.grains(job.csParent),job.grains(job.csChild));

  p2cData = mean(inv(job.grains(p2cPairs(:,2)).meanOrientation) .* job.grains(p2cPairs(:,1)).meanOrientation,'robust');
  p2c0 = p2cData;
  
else % some default parent2child orientation relationship
  
  p2cData = [];
  p2c0 = orientation.KurdjumovSachs(job.csParent,job.csChild);
  
end

if check_option(varargin,'noC2C')

  job.p2c = p2c0;
  
else % consider also child to child 
  
  % get neighbouring grain pairs
  c2cPairs = job.grains(job.csChild).neighbors;

  if ~isempty(job.p2c), p2c0 = job.p2c; end
  p2c0 = getClass(varargin,'orientation',p2c0);

  oriChild = reshape(job.grains('id',c2cPairs).meanOrientation,[],2);
  mori = inv(oriChild(:,1)).*oriChild(:,2);

  % ignore pairs with misorientation angle smaller then 5 degree
  mori(mori.angle < 5 * degree) = [];
    
  % compute an optimal parent to child orientation relationship
  if check_option(varargin,'v3')
    
   job.p2c = fitP2C(mori,p2c0);
    
  elseif check_option(varargin,'v2')
    
    [job.p2c, job.fit] = calcParent2Child2(mori,p2c0);
    
  else
   
    [job.p2c, job.fit] = calcParent2Child(mori,p2c0,varargin{:});
    
  end
  
  % combine p2c and c2c orientation relationships
  if ~isempty(p2cData) && ~check_option(varargin,'noP2C')
    
    job.p2c = mean([job.p2c,p2cData],'weights',[length(c2cPairs),length(p2cPairs)]);
    
  end
    
end
   
end