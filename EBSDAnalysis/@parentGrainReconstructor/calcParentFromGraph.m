function job = calcParentFromGraph(job,varargin)
% compute parent orientations frome a merge graph
%
% Syntax
%   job.calcParentFromGraph
%   job.calcParentFromGraph('threshold',5*degree)
%
% Input
%  job - @parentGrainReconstructor
%
% Output
%  job.parentGrains - reconstructed parent grains
%
% Options
%
%  threshold - child / parent grains with a misfit larger then the threshold will not be merged
%

% steps of the algorithm
%  (1) fake merge - to identify the grains to be merged
%  (2) fit parent grain orientation to the merged grains
%  (3) identify merged grains with a good fit
%  (4) perform the actual merge
%
% TODO:
%  - misfit computation: currently we take the maximum, we consider only the childorientations 
%  -

assert(~isempty(job.graph), 'No merge graph found. Please use the command ...');

% remember child orientations
wasChildGrain = job.grains.phaseId == job.childPhaseId;
wasParentGrain = job.grains.phaseId == job.parentPhaseId;

childOri = orientation.nan(length(job.grains),1,job.csChild);
childOri(wasChildGrain) = job.grains.meanRotation(wasChildGrain);

parentOri = orientation.nan(length(job.grains),1,job.csParent);
parentOri(wasParentGrain) = job.grains.meanRotation(wasParentGrain);

% weights are previous grainSize
weights = job.grains.grainSize;

% (1) fake merge
[~, mergeId] = merge(job.grains,job.graph,'testRun');
    
% (2) parent orientation reconstruction
% the parent orientation we are going to compute
fit = inf(size(parentOri));
fit(~wasParentGrain & ~wasChildGrain ) = NaN;
clusterSize = ones(size(parentOri));

% compute parent grain orientation by looping through all merged grains
for k = 1:max(mergeId) %#ok<*PROPLC>
  
  % check if only parent orientations
  if all(wasParentGrain(mergeId==k))
     fit(mergeId==k) = nan;
     continue;
  end
  
  % check if empty or single grain
  if nnz(mergeId==k)<=1 
    continue; 
  end
  
  if all(wasChildGrain(mergeId==k)) % only child orientations
    
    ind = mergeId == k;
    pOri = calcParent(childOri(ind), job.p2c, 'weights', weights(ind));

    [parentOri(ind),fit(ind)] = calcParent(childOri(ind),pOri,job.p2c);
    
    clusterSize(ind) = nnz(ind);
    
  elseif all(wasChildGrain(mergeId==k) | wasParentGrain(mergeId==k))
    % parent and child orientations
        
    % compute mean parent orientation
    ind = mergeId==k & wasParentGrain;
    pOri = mean(parentOri(ind), 'weights', weights(ind), 'robust');
    fit(ind) = angle(parentOri(ind),pOri);
    
    % compute for child ori a parent ori
    ind = mergeId==k & wasChildGrain;
    [parentOri(ind),fit(ind)] = calcParent(childOri(ind), ...
      pOri, job.p2c,'weights', weights(ind));

  end
      
  progress(k,max(mergeId),'computing parent grain orientations: ');
end
    
% set reconstructed parentorientations
job.grains(~isnan(parentOri)).meanOrientation = parentOri(~isnan(parentOri));
job.grains.prop.fit = fit;
job.grains.prop.clusterSize = clusterSize;

% update all grain properties that are related to the mean orientation
job.grains = job.grains.update;

job.graph = [];

end
