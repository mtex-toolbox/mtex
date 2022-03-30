 function job = calcGraph(job, varargin)
 % set up similarity graph for parent grain reconstruction
 %
 % Syntax
 %   job.calcGraph
 %
 % Input
 %  job - @parentGrainReconstructor
 %
 % Output
 %  job.graph - adjacency matrix of the graph
 %
 % Options
 %  threshold - misfit at which the probability is set to 0.5, default is 2 degree
 %  tolerance - range around the threshold where the probability increases from 0 to 1
 %  noC2C     - ignore child to child grain boundaries
 %  noP2C     - ignore parent to child grain boundaries
 %
 % Description
 % The weights of the graph are computed from a cummulative gaussion
 % distribution with mean given by the option |'threshold'| and variance
 % given by the option |'tolerance'|
 %
 
 threshold = get_option(varargin,'threshold',2*degree);
 tol = get_option(varargin,'tolerance',1.5*degree);
 
 % OR fit of grain neighbors
 [fit, grainPairs] = calcGBFit(job,varargin{:});
 
 % turn into probability
 prob = 1 - 0.5 * (1 + erf(2*(fit - threshold)./tol));
 
 % write into similarity matrix
 job.graph = sparse(grainPairs(:,1),grainPairs(:,2),prob,...
   length(job.grains),length(job.grains));
 
 % ensure graph is symmetric
 job.graph = max(job.graph, job.graph.');
 
 end