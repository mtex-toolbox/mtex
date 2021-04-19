function job = calcParentFromHyperGraph(job,varargin)
% compute parent orientations frome a merge graph
%
% Syntax
%   job.calcParentFromGraph
%   job.calcParentFromGraph('threshold',5*degree)
%
% Input
%  job - @parentGrainReconstructor
%
% Output
%  job.parentGrains - reconstructed parent grains
%
% Options
%
%  threshold - child / parent grains with a misfit larger then the threshold will not be merged
%

% steps of the algorithm
%  (1) fake merge - to identify the grains to be merged
%  (2) fit parent grain orientation to the merged grains
%  (3) identify merged grains with a good fit
%  (4) perform the actual merge
%
% TODO:
%  - misfit computation: currently we take the maximum, we consider only the childorientations 
%  -

% extract parameters
p = get_option(varargin,'inflationPower', 1.4);
numIter = get_option(varargin,'numIter', 6);
minval = 0.0001;

% some constants
A = job.graph;
numG = size(A{1},1);
numV = size(A,1);

% prune elements of A that are below minval
for k = 1:numel(A), A{k} = (A{k} > minval) .* A{k}; end

% this is an adaptation of the MCL algorithm
for iter = 1:numIter

  % expansion
  A = expansion(A);
  
  % inflation by Hadamard potentiation
  for k = 1:numel(A), A{k} = A{k}.^p; end
  
  % prune elements of A that are below minval
  for k = 1:numel(A), A{k} = (A{k} > minval) .* A{k}; end
    
  % column re-normalisation
  s = 0;
  for k1 = 1:numV
    for k2 = 1:numV
      s = s + sum(A{k1,k2});
    end
  end
  dinv = spdiags(1./s.',0,numG,numG);
  for k = 1:numel(A), A{k} = A{k} * dinv; end

  disp('.')
end 

% create a table of probabilities for the different parentIds of each child
% grains
pIdP = zeros(numG,numV);

for k2 = 1:numV
  for k1 = 1:numV   
    pIdP(:,k2) = pIdP(:,k2) + sum(A{k1,k2},1).';
  end
end

% store it in the job class
job.grains.prop.pParentId = pIdP; 

% for the reconstruction simple take the parent Id with the maximum
% probability
[P,parentId] = max(pIdP,[],2);

% we could use here some threshold on the probability
% note, by normalization the probabilities for a single child grain
% sum up to 1
doTransform = P > 0.0 & job.grains.phaseId == job.childPhaseId;

% compute new parent orientation from parentId
pOri = variants(job.p2c, job.grains(doTransform).meanOrientation, parentId(doTransform));

% change orientations of consistent grains from child to parent
job.grains(doTransform).meanOrientation = pOri;

% update all grain properties that are related to the mean orientation
job.grains = job.grains.update;

job.graph = [];


end

function B = expansion(A)

B = A;
for k1 = 1:length(A)
  for k2 = 1:length(A)
    
    for k = 1:length(A)
      
      B{k1,k2} = B{k1,k2} + A{k1,k} * A{k,k2};
      
    end
   
  end
end

end

 