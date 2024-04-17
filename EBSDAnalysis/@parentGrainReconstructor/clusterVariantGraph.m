function job = clusterVariantGraph(job,varargin)
% the MCL algorithm generalized to hyper graphs
%
% Syntax
%
%   job.calcVariantGraph
%   job.clusterVariantGraph
%   job.calcParentFromVote('minProb',0.5)
%
% Input
%  job - @parentGrainReconstructor
%
% Output
%  job.votes - computed parent votes
%
% Options
%  inflationPower - inflation power of the MCL algorithm (default=1.05)
%  numIter        - number of iterations (default=10)
%  cutOff         - default 0.0001
%  withDiagonal   -
%  keepGraph      - do not kill graph after clustering 
%  includeSimilar - similarly oriented variants share probability
%  includeTwins   - potential twins share probability
%  minCluster     - minimum cluster size (default 4)
%
% References
%
% * <https://arxiv.org/abs/2201.02103 The variant graph approach to
% improved parent grain reconstruction>, arXiv, 2022
%

% ensure we have a variant graph
if isempty(job.graph), job.calcVariantGraph(varargin{:}); end

% extract parameters
p = get_option(varargin,'inflationPower', 1.05);
numIter = get_option(varargin,'numIter', 10);
cutOff = get_option(varargin,'cutOff',0.0001);

% some constants
A = job.graph;
nVG = size(A,1); % size of the variant graph
job.graph = [];
p2cV = variants(job.p2c,'parent');
numV = length(p2cV);

% indices to the variant graph
isCP = job.isChild | job.isParent; % only child and parent phases go into the variant graph

% rep2VG - how often it repeats to fit in the variant graph [numV numV 1 numV 0 1 numV ...]
rep2VG = numV * job.isChild + job.isParent;

% VG2ind - variant graph index -> grain index
VG2ind = 1:length(job.grains);
VG2ind = repelem(VG2ind(isCP), rep2VG(isCP));

% indeces of the pseudo diagonal
if check_option(varargin,'noPseudoDiagonal')

  % position of variant 1 of each child grain in the Matrix
  indV1 = [0;cumsum(rep2VG)];
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
  
  if check_option(varargin,'sym')
    A = sqrt(A.' .* A);
    normalize
  end
  
  % column re-normalisation
  normalize
  
  if check_option(varargin,'test2')
    A = sqrt(diag(diag(A)) * A);
    normalize
  end

  if check_option(varargin,'verbose'), disp(nnz(A)); end
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

% ensure minimum cluster size
minCluster = get_option(varargin,'minCluster',4);
s = s .* (full(sum(A>0,2))>=minCluster);

% store in numGrains x numVariant matrix
isVGChild = job.isChild(VG2ind); % isChild in variant graph
pIdP = nan(length(job.grains),numV);
pIdP(job.isChild,:) = reshape(s(isVGChild),numV,[]).';

% some post processing
if check_option(varargin,'includeTwins')
  
  % define theoretical twinning of the packet
  tp2cV = p2cV(:) .* orientation.byAxisAngle(round(p2cV \ Miller(0,1,1,p2cV.SS),'maxHKL',1),60*degree);
  
  M = 0.5*triu(angle_outer(p2cV,tp2cV,'noSym2') < 5 * degree);
  
  M(~sum(M),~sum(M)) = eye(nnz(~sum(M)));
  pIdP = pIdP * M;
end

if check_option(varargin,'includeSimilar')
  %M = triu(angle_outer(job.p2c.variants('parent'),job.p2c.variants('parent'),'noSym2')<5*degree);
  %M(:,sum(M)==1) = 0;
  
  M = angle_outer(p2cV,p2cV,'noSym2')<5*degree;
  M = 0.9*M + 0.1*eye(size(M));
  
  pIdP = pIdP * M;
  
elseif check_option(varargin,'mergeSimilar')

  M = angle_outer(p2cV,p2cV,'noSym2')<5*degree;   
  pIdP = pIdP * M;

end

% sort the table and store the highest probabilities in the job class
[pIdP,pId] = sort(pIdP,2,'descend');
job.votes = table(pId,pIdP,'VariableNames',{'parentId','prob'});

if check_option(varargin,'keepGraph')
  job.graph = A;
end


  function normalize2 %#ok<DEFNU>
    
    % column re-normalization
    % sum over all targets
    s = full(sum(A));
  
    % sum over all variants
    s = accumarray(VG2ind.',s);
    s = repelem(s,rep2VG(isPC));
  
    % create sparse diagonal matrix for
    dinv = spdiags(1./s,0,nVG,nVG);
    A = A * dinv;
    
  end

  function normalize
    
    % column re-normalisation
    % sum over all targets
    s = full(sum(A,2)).';
  
    % sum over all variants
    s = accumarray(VG2ind.',s);
    s = repelem(s(isCP),rep2VG(isCP));
  
    % create sparse diagonal matrix for
    dinv = spdiags(1./s,0,nVG,nVG);
    A = dinv * A;
    
  end
end 
