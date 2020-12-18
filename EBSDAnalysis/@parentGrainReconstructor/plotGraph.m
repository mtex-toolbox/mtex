function varargout = plotGraph(job,varargin)
% 

assert(~isempty(job.graph), 'No graph computed. Please use the command ...');

grainPairs = job.grains.neighbors;

v = full(job.graph(sub2ind(size(job.graph),grainPairs(:,1),grainPairs(:,2))));
      
[gB,pairId] = job.grains.boundary.selectByGrainId(grainPairs);

[varargout{1:nargout}] = plot(gB, v(pairId), varargin{:});
