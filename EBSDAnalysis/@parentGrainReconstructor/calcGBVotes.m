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
%  p2c  - consider only parent / child grain boundaries
%  c2c  - consider only child / child grain boundaries
%  weights - store boundary as weights to votes
%

numFit = get_option(varargin,'numFit',2);
noOpt = ~check_option(varargin,{'p2c','c2c'});

% parent-child - votes
if ~isempty(job.parentGrains) && (noOpt || check_option(varargin,'p2c'))
  
  % extract parent to child grain pairs with the coresponding orientations
  % averaged along the boundary
  [grainPairs, oriParent, oriChild] = getP2CPairs(job,varargin{:});

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
else
  job.votes = [];  
end

% child-child - votes
if noOpt || check_option(varargin,'c2c')

  % extract child to child grain pairs with the coresponding orientations
  % averaged along the boundary
  [grainPairs, oriChild] = getC2CPairs(job,varargin{:});
  
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
