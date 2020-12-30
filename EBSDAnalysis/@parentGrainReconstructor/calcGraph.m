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
 %
 % Description
 % The weights of the graph are computed from a cummulative gaussion
 % distribution with mean given by the option |'threshold'| and variance
 % given by the option |'tolerance'|
 %
 
 threshold = get_option(varargin,'threshold',2*degree);
 tol = get_option(varargin,'tolerance',1.5*degree);
 
 % child to child misorientations
 pairs = neighbors(job.grains(job.csChild),job.grains(job.csChild));
 
 c2c = inv(job.grains(pairs(:,2)).meanOrientation) .* ...
   job.grains(pairs(:,1)).meanOrientation;
 
 c2cFit = min(angle_outer(c2c,job.p2c * inv(variants(job.p2c))),[],2); %#ok<MINV>
 
 prob = 1 - 0.5 * (1 + erf(2*(c2cFit - threshold)./tol));
 
 % child 2 child neighbours
 grainPairs = job.grains(job.csChild).neighbors;
 
 % the corresponding similarity matrix
 job.graph = sparse(grainPairs(:,1),grainPairs(:,2),prob,...
   length(job.grains),length(job.grains));
 
 % parent to child neighbours
 grainPairs = neighbors(job.grains(job.csParent),job.grains(job.csChild));
 
 childOri = job.grains(job.grains.id2ind(grainPairs(:,2))).meanOrientation;
 parentOri = job.grains(job.grains.id2ind(grainPairs(:,1))).meanOrientation;
 
 p2cFit = angle(job.p2c, inv(childOri).*parentOri);
 
 prob = 1 - 0.5 * (1 + erf(2*(p2cFit - threshold)./tol));
 
 job.graph = job.graph + sparse(grainPairs(:,1),grainPairs(:,2),prob,...
   length(job.grains),length(job.grains));
 
 end