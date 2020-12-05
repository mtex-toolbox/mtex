 function job = mergeInclusions(job, varargin)

 [job.grains, mergeId] = merge(job.grains, 'inclusions', varargin{:});
 job.mergeId = mergeId(job.mergeId); %#ok<*PROPLC>
 job.ebsd('indexed').grainId = mergeId(job.ebsd('indexed').grainId);
 
 end