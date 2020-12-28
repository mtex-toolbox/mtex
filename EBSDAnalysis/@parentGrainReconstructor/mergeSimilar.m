 function job = mergeSimilar(job, varargin)
 % merge neighbouring grains with similar orientation
 %
 % Syntax
 %   job.mergeSimilar('threshold',5*degree)
 %
 % Input
 %  job - @parentGrainReconstructor
 %
 % Output
 %  job.grains  - merged grains
 %  job.mergeId - job.grainsMeasured 
 %
 % Options
 %  threshold - misorientation angle up to which grains are merged
 %
      
 [job.grains, mergeId] = merge(job.grains, 'threshold',5*degree, varargin{:});
 job.mergeId = mergeId(job.mergeId); %#ok<*PROPLC>
 job.ebsd('indexed').grainId = mergeId(job.ebsd('indexed').grainId);
 
 end