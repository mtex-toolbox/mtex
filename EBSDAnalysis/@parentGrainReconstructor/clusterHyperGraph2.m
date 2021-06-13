function job = clusterHyperGraph2(job,varargin)
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
if isempty(job.graph), job.calcHyperGraph2(varargin{:}); end

% extract parameters
p = get_option(varargin,'inflationPower', 1);
numIter = get_option(varargin,'numIter', 3);
cutOff = get_option(varargin,'cutOff',0.0001);

% some constants
A = job.graph;
job.graph = [];
p2cV = variants(job.p2c,'parent');
numV = length(p2cV);

% index of variant 1
nHyper = size(A,1);

% h2ind 
h2ind = 1:length(job.grains);
h2ind = h2ind(job.isChild | job.isParent);
h2ind = repelem(h2ind, numV * job.isChild + job.isParent);

isChild = job.isChild;
isChild = isChild(job.isChild | job.isParent);
isChild = repelem(isChild, numV * job.isChild + job.isParent);

% indeces of the pseudo diagonal
if check_option(varargin,'noPseudoDiagonal')

  % position of variant 1 of each child grain in the Matrix
  indV1 = [0;cumsum(numV * job.isChild + job.isParent)];
  indV1(end) = [];
  indV1 = indV1(job.isChild);
  
  % a numV x numV matrix without diagonal
  [i,j] = meshgrid(1:numV,1:numV);
  i(eye(numV)==1) = [];
  j(eye(numV)==1) = [];

  pseudoDiag = sparse(indV1 + i(:).',indV1 + j(:).',true,size(A,1),size(A,2));
end

normalize

% this is an adaptation of the MCL algorithm
for iter = 1:numIter

  % expansion
  A = A * A;
  
  % remove pseudo diagonal entries, i.e., A(j+k,j+l)
  if exist('pseudoDiag','var'), A(pseudoDiag) = 0; end
  
  % inflation by Hadamard potentiation
  A = A.^p;
  
  % prune elements of A that are below minval
  %A = (A > cutOff) .* A;
  A = spfun(@(x) (x > cutOff) .* x,A);
  
  % column re-normalisation
  normalize
  
  if check_option(varargin,'test2')
    A = sqrt(diag(diag(A)) * A);
    normalize
  end
  
  disp(nnz(A))
end 

if check_option(varargin,'test1')
  A = diag(diag(A)) * A;
  normalize
end

if check_option(varargin,'sym')
  A = sqrt(A.' .* A);
  normalize
end

% create a table of probabilities for the different parentIds of each child
% grains
if p>1
  s = full(sum(A,2)); % sum columns
else
  s = full(sum(A,2) - diag(A)); % sum columns
end
s = s(isChild);

pIdP = nan(length(job.grains),numV);
pIdP(job.isChild,:) = reshape(s,numV,[]).';

% some post processing
if check_option(varargin,'includeTwins')
  
  % define theoretical twinning of the packet
  p2cV = job.p2c.variants('parent');
  tp2cV = p2cV(:) .* orientation.byAxisAngle(round(p2cV \ Miller(0,1,1,p2cV.SS),'maxHKL',1),60*degree);
  
  M = 0.5*triu(angle_outer(p2cV,tp2cV,'noSym2') < 5 * degree);
  
  M(~sum(M),~sum(M)) = eye(nnz(~sum(M)));
  pIdP = pIdP * M;
end


if check_option(varargin,'includeSimilar')
  %M = triu(angle_outer(job.p2c.variants('parent'),job.p2c.variants('parent'),'noSym2')<5*degree);
  %M(:,sum(M)==1) = 0;
  
  M = angle_outer(job.p2c.variants('parent'),job.p2c.variants('parent'),'noSym2')<5*degree;
  M = 0.9*M + 0.1*eye(size(M));
  
  pIdP = pIdP * M;
  
end

% sort the table and store the highest probabilities in the job class
[pIdP,pId] = sort(pIdP,2,'descend');
job.votes = table(pId,pIdP,'VariableNames',{'parentId','prob'});

if check_option(varargin,'keepGraph')
  job.graph = A;
end


  function normalize2
    
    % column re-normalisation
    % sum over all targets
    s = full(sum(A));
  
    % sum over all variants
    s = accumarray(h2ind.',s);
    s = repelem(s,numV * job.isChild + job.isParent);
  
    % create sparse diagonal matrix for
    dinv = spdiags(1./s,0,nHyper,nHyper);
    A = A * dinv;
    
  end
  function normalize
    
    % column re-normalisation
    % sum over all targets
    s = full(sum(A,2)).';
  
    % sum over all variants
    s = accumarray(h2ind.',s);
    s = repelem(s,numV * job.isChild + job.isParent);
  
    % create sparse diagonal matrix for
    dinv = spdiags(1./s,0,nHyper,nHyper);
    A = dinv * A;
    
  end
end 
