function job = mergeByGraph(job,varargin)
% merge grains according to the adjecency matrix A
%
% Syntax
%   mergeByGraph(job)
%   mergeByGraph(job,'threshold',5*degree)
%
% Input
%  job - @parentGrainReconstructor
%
% Output
%  job.grains - reconstructed parent grains
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


% the remember child orientations
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
recOri = orientation.nan(max(mergeId),1,job.csParent);
fit = inf(size(recOri));

% compute parent grain orientation by looping through all merged grains
for k = 1:max(mergeId) %#ok<*PROPLC>
  
  % check if empty or single grain
  if nnz(mergeId==k)<=1, continue; end
  
  if all(wasParentGrain(mergeId==k)) % only parent orientations
    
    recOri(k) = mean(parentOri(mergeId==k), 'weights', weights(mergeId == k));
    fit(k) = 0;
        
  elseif all(wasChildGrain(mergeId==k)) % only child orientations
    
    [recOri(k),fit(k)] = calcParent(childOri(mergeId == k),...
      job.p2c, 'weights', weights(mergeId == k));
        
  elseif all(wasChildGrain(mergeId==k) | wasParentGrain(mergeId==k))
    % parent and child orientations
        
    % compute mean parent orientation
    pWeights = weights(mergeId==k & wasParentGrain);
    pOri = mean(parentOri(mergeId==k & wasParentGrain), 'weights', pWeights, 'robust');
        
    % extract child orientations
    cOri = childOri(mergeId==k & wasChildGrain);
    cWeights = weights(mergeId==k & wasChildGrain);
    
    % compute for child ori a parent ori
    [ori,fitLocal] = calcParent(cOri, pOri, job.p2c,'weights', cWeights);
    
    % compute mean parent ori
    recOri(k) = mean([pOri;ori], 'robust', 'weigts',[sum(pWeights);cWeights]);
    fit(k) = max(fitLocal);
    
  end
      
  progress(k,max(mergeId),'computing parent grain orientations: ');
end
    
% only merge those grains where the parent grain 
threshold = get_option(varargin,'threshold',5*degree);
isGood = fit < threshold;

% reduce graph
job.graph(:,~isGood(mergeId)) = 0;
job.graph(~isGood(mergeId),:) = 0;

% now perform the actual merge
[job.grains, mergeId] = merge(job.grains,job.graph);
job.mergeId = mergeId(job.mergeId);

% ensure grainId in parentEBSD is set up correctly with parentGrains
job.ebsdPrior('indexed').grainId = mergeId(job.ebsdPrior('indexed').grainId);

% update mean orientation of the parent grains
job.grains(end-nnz(isGood)+1:end).meanOrientation = recOri(isGood);
job.grains = job.grains.update;

% erase merge graph
job.graph = [];

end
