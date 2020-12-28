function job = clusterGraph(job, varargin)

p = get_option(varargin,'inflationPower', 1.6);
      
job.graph = mclComponents(job.graph,p);
      
end
    