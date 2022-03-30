function job = revert(job,doRevert)
% revert parent orientations to measured child orientations
%
% Syntax
%
%   % undo all reconstruction
%   job.revert
%
%   % undo grains by condition
%   ind = job.grains.fit > 5*degree
%   job.revert(ind)
%
%   % undo specific grains
%   job.revert(job.parentGrains(5))
%
% Input
%  job    - @parentGrainReconstructor
%  ind    - true/false of which parent grains should be reverted to child grains
%  grains - list of grains to be reverted
%
% Output
%  job - @parentGrainReconstructor
%
% See also
% MaParentGrainReconstruction
%

% forget votes and graph
job.votes = [];
job.graph = [];

% revert everything
if nargin == 1, doRevert = true(size(job.grains)); end

% input should be index to job.grains
if isa(doRevert,'grain2d'), doRevert = id2ind(job.grains,doRevert.id); end

% make ind a logical vector
if ~islogical(doRevert)
  doRevert = full(sparse(doRevert,1,true,length(job.grains),1));
end

% which are the original grains to revert
% doRevert = ismember(job.mergeId, ind);
doRevertPrior = doRevert(job.mergeId); %& job.isTransformed;

if ~any(doRevertPrior) % revert nothingthing
  
elseif all(doRevertPrior) % revert everything

  job.grains = job.grainsPrior;
  job.mergeId = (1:length(job.grains)).';
  
elseif max(accumarray(job.mergeId(doRevertPrior),1)) == 1 
  % no merge needs to be undone

  % reset phase and rotation
  job.grains.phaseId(doRevertPrior) = job.grainsPrior.phaseId(doRevertPrior);
  job.grains.prop.meanRotation(doRevertPrior) = job.grainsPrior.prop.meanRotation(doRevertPrior);

  % update grain boundaries and triple points
  job.grains = job.grains.update;
  
else % we do not undo the merge but we redo the merge of the remaining grains
  
  newMergeId = job.mergeId;
  
  % generate possible new ids
  id = 1:max(max(newMergeId),length(job.grainsPrior));
  id(newMergeId(~doRevertPrior)) = [];
  
  % replace grains we revert with unique merge ids
  newMergeId(doRevertPrior) = id(1:nnz(doRevertPrior));
  
  % remerge grains
  [grains, mergeId] = merge(job.grainsPrior, newMergeId);
    
  % reassign phase and rotation to the reverted grains
  keepIndNew = grains.id2ind(unique(mergeId(doRevertPrior),'stable'));  
  grains.phaseId(keepIndNew) = job.grainsPrior.phaseId(doRevertPrior); 
  grains.prop.meanRotation(keepIndNew) = job.grainsPrior.prop.meanRotation(doRevertPrior);
  
  % reassign phase and rotation to the not reverted grains
  keepIndNew = grains.id2ind(unique(mergeId(~doRevertPrior),'stable'));
  keepInd = job.grains.id2ind(unique(job.mergeId(~doRevertPrior),'stable'));
  grains.phaseId(keepIndNew) = job.grains.phaseId(keepInd);
  grains.prop.meanRotation(keepIndNew) = job.grains.prop.meanRotation(keepInd);
  
  job.grains = grains;
  job.mergeId = mergeId;

  % update grain boundaries and triple points
  job.grains = job.grains.update;
  
end
