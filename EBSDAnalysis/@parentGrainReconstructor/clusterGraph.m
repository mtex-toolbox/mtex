function job = clusterGraph(job, varargin)
% breaks graph into clusters of parent grains
%
% Syntax
%   job.clusterGraph
%
% Input
%  job - @parentGrainReconstructor
%
% Output
%  job.graph
%
% Options
%  inflationPower - controls the size of the clusters, default 1.6
%
% See also
% MaParentGrainReconstruction mclComponents
%

p = get_option(varargin,'inflationPower', 1.6);
      
job.graph = mclComponents(job.graph,p);
      
end
    