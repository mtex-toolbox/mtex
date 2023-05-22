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
%  job.mergeId - job.grainsPrior
%  job.grains.clusterSize - number of child grains
%
% Options
%  threshold - misorientation angle up to which grains are merged
%

[job.grains, mergeId] = merge(job.grains, 'threshold',5*degree, varargin{:});
job.mergeId = mergeId(job.mergeId); %#ok<*PROPLC>

% compute cluster size
clusterSize = accumarray(job.grains.id2ind(job.mergeId),1,[length(job.grains) 1]);
job.grains.prop.clusterSize = clusterSize;
 
end