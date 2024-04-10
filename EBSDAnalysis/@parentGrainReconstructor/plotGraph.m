function varargout = plotGraph(job,varargin)
% 

assert(~isempty(job.graph), 'No graph computed. Please use the command ''calcGraph''');

if job.hasVariantGraph
  
  error('not yet implemented')
  p2cV = variants(job.p2c,'parent'); %#ok<UNRCH>
  numV = length(p2cV);

  % h2ind 
  h2ind = 1:length(job.grains);
  h2ind = h2ind(job.isChild | job.isParent);
  h2ind = repelem(h2ind, numV * job.isChild + job.isParent);

  graph = accumarray(h2ind.',job.graph,[],@max);

else
  graph = job.graph;
end

grainPairs = job.grains.neighbors;

v = full(graph(sub2ind(size(job.graph),grainPairs(:,1),grainPairs(:,2))));
      
[gB,pairId] = job.grains.boundary.selectByGrainId(grainPairs);

[varargout{1:nargout}] = plot(gB, 'edgeAlpha', 1-v(pairId), varargin{:});
