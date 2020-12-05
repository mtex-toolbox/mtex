function job = revert(job,ind)
% revert parent orientations to measured child orientations
%
% Syntax
%
%   % revert all 
%   job.calcGraph
%   ind = job.graph.clusterSize < 3
%   job.revert(ind)
%
% Input
%  job - @parentGrainReconstructor
%  ind - true/false of which parent grains should be reverted to child grains
%
% Output
%  job - @parentGrainReconstructor
%
% See also
%

% ensure grains are indeed parent grains
assert(all(job.grains.phaseId(ind) == job.parentPhaseId));

% ensure grains have not yet been merged
job.mergeId