function job = calcGBVotes(job,varargin)
% compute votes from grain boundaries
%
% Syntax
%
%   job.calcGBVotes
%
% Input
%  job - @parentGrainReconstructor
%
% Output
%  job.votes - table of votes
%
% Options
%  numFit - number of fits to be computed
%  noC2C  - consider only parent / child grain boundaries
%  weights - store boundary as weights to votes
%

numFit = get_option(varargin,'numFit',2);

% parent-child - votes

if ~isempty(job.parentGrains)
  grainPairs = neighbors(job.parentGrains, job.childGrains);
    
  % extract the corresponding mean orientations
  oriParent = job.grains('id',grainPairs(:,1) ).meanOrientation;
  oriChild  = job.grains('id', grainPairs(:,2) ).meanOrientation;
    
  % compute for each parent/child pair of grains the best fitting parentId
  [parentId, fit] = calcParent(oriChild,oriParent,job.p2c,'numFit',numFit,'id');
    
  % store as table
  job.votes = table(grainPairs(:,2), parentId, fit, ...
    'VariableNames',{'grainId','parentId','fit'});
  
  % weight votes according to boundary length
  if check_option(varargin,'weights')
    
    [~,pairId] = job.grains.boundary.selectByGrainId(grainPairs);
    weights = accumarray(pairId,1,[size(grainPairs,1) 1]);
    
    job.votes.weights = weights;
  end
end

% child-child - votes
if ~check_option(varargin,'noC2C')
  grainPairs = neighbors(job.childGrains, job.childGrains);
  
  % extract the corresponding mean orientations
  oriChild = job.grains('id',grainPairs).meanOrientation;
    
  % compute for each parent/child pair of grains the best fitting parentId
  [parentId, fit] = calcParent(oriChild,job.p2c,'numFit',numFit,'id');
    
  c2cVotes = table(grainPairs(:), reshape(parentId,[],numFit), repmat(fit,2,1), ...
    'VariableNames',{'grainId','parentId','fit'});
  
  
  % weight votes according to boundary length
  if check_option(varargin,'weights')
    
    [~,pairId] = job.grains.boundary.selectByGrainId(grainPairs);
    weights = accumarray(pairId,1,[size(grainPairs,1) 1]);
    
    c2cVotes.weights = [weights;weights];
  end 
  
  % add to table
  job.votes = [job.votes; c2cVotes];

end

end
