function job = calcGBVotes(job,varargin)
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
%  numFit      - number of fits to be computed
%  onlyParents - consider only parent / child grain boundaries
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
end

% child-child - votes
if ~check_option(varargin,'onlyParents')
  grainPairs = neighbors(job.childGrains, job.childGrains);
  
  % extract the corresponding mean orientations
  oriChild = job.grains('id',grainPairs).meanOrientation;
    
  % compute for each parent/child pair of grains the best fitting parentId
  [parentId, fit] = calcParent(oriChild,job.p2c,'numFit',numFit,'id');
    
  % add to table
  job.votes = [job.votes; ...
    table(grainPairs(:), reshape(parentId,[],numFit), repmat(fit,2,1), ...
    'VariableNames',{'grainId','parentId','fit'})];

end

end