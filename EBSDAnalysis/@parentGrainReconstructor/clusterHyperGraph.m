function job = clusterHyperGraph(job,varargin)
% the MCL algorithms generalized to hyper graphs
%
% Syntax
%
%   job.calcHyperGraph
%   job.clusterHyperGraph
%   job.calcParentFromVote('minProb',0.5)
%
% Input
%  job - @parentGrainReconstructor
%
% Output
%  job.parentGrains - reconstructed parent grains
%
% Options
%  inflationPower - default 1.4
%  numIter        - number of iterations
%  cutOff         - default 0.0001
%  withDiagonal   -

% ensure we have a graph
if isempty(job.graph), job.calcHyperGraph(varargin{:}); end

% extract parameters
p = get_option(varargin,'inflationPower', 1.4);
numIter = get_option(varargin,'numIter', 6);
cutOff = get_option(varargin,'cutOff',0.0001);

% some constants
A = job.graph;
job.graph = [];
numG = size(A{1},1);
numV = size(A,1);

% prune elements of A that are below minval
for k = 1:numel(A), A{k} = (A{k} > cutOff) .* A{k}; end

% this is an adaptation of the MCL algorithm
for iter = 1:numIter

  % expansion
  A = expansion(A);
  
  % inflation by Hadamard potentiation
  for k = 1:numel(A), A{k} = A{k}.^p; end
  
  % prune elements of A that are below minval
  for k = 1:numel(A), A{k} = (A{k} > cutOff) .* A{k}; end
    
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

% create a table of probabilities for the different parentIds of each child
% grains
pIdP = zeros(numG,numV);

for k2 = 1:numV
  for k1 = 1:numV
    pIdP(:,k2) = pIdP(:,k2) + sum(A{k1,k2},1).';
  end
  %pIdP(:,k2) = diag(A{k2,k2});
end

if check_option(varargin,'includeTwins')
  
  % define theoretical twinning of the packet
  p2cV = job.p2c.variants('parent');
  tp2cV = p2cV(:) .* orientation.byAxisAngle(round(p2cV \ Miller(0,1,1,p2cV.SS),'maxHKL',1),60*degree);
  
  M = 0.5*triu(angle_outer(p2cV,tp2cV,'noSym2') < 5 * degree);
  
  M(~sum(M),~sum(M)) = eye(nnz(~sum(M)));
  pIdP = pIdP * M;
end


if check_option(varargin,'includeSimilar')
  M = triu(angle_outer(job.p2c.variants('parent'),job.p2c.variants('parent'),'noSym2')<5*degree);
  M(:,sum(M)==1) = 0;
  pIdP = pIdP * M;
  
end

% sort the table and store the highest probabilities in the job class
[pIdP,pId] = sort(pIdP,2,'descend');
job.votes = table(pId,pIdP,'VariableNames',{'parentId','prob'});

% --------------------------------------------------------------------------
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