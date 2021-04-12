function job = calcHyperGraph(job, varargin)
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

% get parameters
numFit = get_option(varargin,'numFit',4);
threshold = get_option(varargin,'threshold',2*degree);
tol = get_option(varargin,'tolerance',1.5*degree);

% init graph
numG = max(job.grains.id);
numV = length(variants(job.p2c,'parent'));
job.graph = cell(numV,numV);
for k = 1:numel(job.graph), job.graph{k} = sparse(numG,numG); end
 
% consider parent to child boundaries first
if ~isempty(job.parentGrains) && ~check_option(varargin,'noP2C')
  
  % all parent to child pairs
  grainPairs = neighbors(job.parentGrains, job.childGrains);
  
  % extract the corresponding mean orientations
  oriParent = job.grains('id',grainPairs(:,1) ).meanOrientation;
  oriChild  = job.grains('id',grainPairs(:,2) ).meanOrientation;
    
  % compute for each parent/child pair of grains the best fitting parentId
  parentId = ones(length(oriParent),2,numFit);
  [parentId(:,2,:), fit] = calcParent(oriChild,oriParent,job.p2c,'numFit',numFit,'id');
    
  % weight votes according to boundary length
  if check_option(varargin,'weights')
    
    [~,pairId] = job.grains.boundary.selectByGrainId(grainPairs);
    weights = accumarray(pairId,1,[size(grainPairs,1) 1]);
    
    job.votes.weights = weights;
  end

  add2Graph;
  
end

% child to child probabilities
if ~check_option(varargin,'noC2C')
 
  % get all child to child grain pairs
  grainPairs = neighbors(job.childGrains, job.childGrains);
 
  % extract the corresponding mean orientations
  oriChild = job.grains('id',grainPairs).meanOrientation;
 
  % compute for each parent/child pair of grains the best fitting parentId
  [parentId, fit] = calcParent(oriChild,job.p2c,'numFit',numFit,'id');
  
  add2Graph;
end

  function add2Graph
    
    % turn fit into probability
    prob = 1 - 0.5 * (1 + erf(2*(fit - threshold)./tol));
    
    for k1 = 1:numV
      for k2 = 1:numV
        for f = 1:numFit
          
          ind = (parentId(:,1,f) == k1 & parentId(:,2,f) == k2);
          
          job.graph{k1,k2} = job.graph{k1,k2} + ...
            sparse(grainPairs(ind,1),grainPairs(ind,2),prob(ind,f),numG,numG);
          
          % symmetrise
          job.graph{k2,k1} = job.graph{k2,k1} + ...
            sparse(grainPairs(ind,2),grainPairs(ind,1),prob(ind,f),numG,numG);
        end
      end
    end
  end
end
 
 