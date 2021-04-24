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
%  minProb   - minimum probability (default - 0.5)
%  threshold - child / parent grains with a misfit larger then the threshold will not be merged
%


% ensure we have a graph
if isempty(job.graph), job.calcHyperGraph(varargin{:}); end

% extract parameters
minProb = get_option(varargin,'minProb',0.0);
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
  if iter < numIter
    for k = 1:numel(A), A{k} = A{k} * dinv; end
    %for k = 1:numel(A), A{k} =  sqrt(dinv) * A{k} * sqrt(dinv); end
  end

  disp('.')
end 
job.graph = A;

% create a table of probabilities for the different parentIds of each child
% grains
pIdP = zeros(numG,numV);

for k2 = 1:numV
  for k1 = 1:numV
    pIdP(:,k2) = pIdP(:,k2) + sum(A{k1,k2},1).';
  end
  %pIdP(:,k2) = diag(A{k2,k2});
end

% sort the table and store the highest probabilities in the job class
[pIdP,pId] = sort(pIdP,2,'descend');

job.grains.prop.parentId = pId(:,1:3); 
job.grains.prop.pParentId = pIdP(:,1:3); 

% we could use here some threshold on the probability
% note, by normalization the probabilities for a single child grain
% sum up to 1
doTransform = pIdP(:,1) >= minProb & job.grains.phaseId == job.childPhaseId;

% compute new parent orientation from parentId
pOri = variants(job.p2c, job.grains(doTransform).meanOrientation, pId(doTransform,1));

% change orientations of consistent grains from child to parent
job.grains(doTransform).meanOrientation = pOri;

% update all grain properties that are related to the mean orientation
job.grains = job.grains.update;

% delete graph 
%job.graph = [];



function B = expansion(A)

if check_option(varargin, 'withDiagonal')
  
  B = cell(size(A));
  for l1 = 1:length(A)
    for l2 = 1:length(A)      
      B{l1,l2} = sparse(size(A{l1,l2},1),size(A{l1,l2},1));
      for l = 1:length(A), B{l1,l2} = B{l1,l2} + A{l1,l} * A{l,l2}; end
    end
  end
  
else
  
  B = A;
  for l1 = 1:length(A)
    for l2 = 1:length(A)
      for l = 1:length(A), B{l1,l2} = B{l1,l2} + A{l1,l} * A{l,l2}; end
    end
  end
end
end 
end