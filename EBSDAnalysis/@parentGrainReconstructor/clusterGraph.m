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
%  job.graph - the reduced graph
%
% Options
%  inflationPower - controls the size of the clusters, default 1.6
%
% See also
% MaParentGrainReconstruction mclComponents
%

if job.hasVariantGraph
  job.clusterVariantGraph(varargin{:});
  
else

  p = get_option(varargin,'inflationPower', 1.6);
      
  job.graph = mclComponents(job.graph,p);

end
    
end
    