function job = calcVariantGraph(job, varargin)
% set up variant graph for parent grain reconstruction
%
% Syntax
%   job.calcVariantGraph
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
%  C2C       - consider only child to child grain boundaries
%  P2C       - consider only parent to child grain boundaries
%  mergeSimilar - merge similar variants in the graph
%
% Description
% 
% The weights of the graph are computed from a cummulative Gaussian
% distribution with mean given by the option |'threshold'| and variance
% given by the option |'tolerance'|. The options |'C2C'| and |'P2C'| may be
% used to restrict the graph to specific neighborhood relationships.
% The option |mergeSimilar| creates a variant graph that does not
% distinguish between similar variants. 
% 
% References
%
% * <https://arxiv.org/abs/2201.02103 The variant graph approach to
% improved parent grain reconstruction>, arXiv, 2022
%

% get parameters
threshold = get_option(varargin,'threshold',2*degree);
tol = get_option(varargin,'tolerance',1.5*degree);
noOpt = ~check_option(varargin,{'p2c','p2p','c2c'});

% init graph
[p2cV, bestFriend] = variants(job.p2c,'parent');
if check_option(varargin,'mergeSimilar')
else
  bestFriend = 1:length(p2cV);
end
numV = length(p2cV);

% index of variant 1
indV1 = [1;1+cumsum(numV * job.isChild + job.isParent)];
nVG = indV1(end)-1;

if check_option(varargin,'noDiagonal')
  job.graph = sparse(nVG,nVG);
else
  job.graph = speye(nVG,nVG);
end


% parent to parent probabilities
if ~isempty(job.parentGrains) && (check_option(varargin,'p2p') || noOpt)
 
  % get all parent to parent grain pairs
  [grainPairs, oriParent] = getP2PPairs(job,'index',varargin{:});
  
  % compute fit
  fit = angle(oriParent(:,1), oriParent(:,2));
  prob = 1 - 0.5 * (1 + erf(2*(fit - threshold)./tol));
  ind = prob > 0.1;
  
  % write to graph
  indP = reshape(indV1(grainPairs(ind,:)),[],2);
  job.graph = job.graph + max(...
    sparse(indP(:,1),indP(:,2),prob(ind),nVG,nVG),...
    sparse(indP(:,2),indP(:,1),prob(ind),nVG,nVG));
  
end

% parent to child probabilities
if ~isempty(job.parentGrains) && (check_option(varargin,'P2C') || noOpt)
 
  % get all child to child grain pairs
  [grainPairs, oriParent, oriChild] = getP2CPairs(job,'index',varargin{:});
  
  % the corresponding indeces in the sparse matrix
  indP = indV1(grainPairs(:,1));
  indC = indV1(grainPairs(:,2));
  
  for k2 = 1:numV
      
    % compute fit
    fit = angle(oriParent, oriChild * p2cV(k2));
    prob = 1 - 0.5 * (1 + erf(2*(fit - threshold)./tol));
    ind = prob > 0.1;
    
    job.graph = max(job.graph, ...
      sparse(indP(ind), indC(ind) + bestFriend(k2) - 1, prob(ind), nVG, nVG));
    
    % symmetrise graph
    job.graph = max(job.graph, ...
      sparse(indC(ind) + bestFriend(k2) - 1, indP(ind), prob(ind), nVG, nVG));
    
  end
end

% child to child probabilities
if check_option(varargin,'C2C') || noOpt
 
  % get all child to child grain pairs
  [grainPairs, oriChild, weights] = getC2CPairs(job,'index',varargin{:});
  
  % the corresponding indeces in the sparse matrix
  indC = indV1(grainPairs);
    
  oriChild2 = oriChild(:,2) * p2cV;
  oriChild1 = oriChild(:,1) * p2cV;
  
  % these will be the rows, cols, and values of the sparse matrix
  i = []; j = []; p = [];
  
  for k1 = 1:length(p2cV)
    for k2 = 1:length(p2cV)

      % compute the fit
      fit = angle(oriChild1(:,k1),oriChild2(:,k2));
    
      % compute fit
      prob = weights .* (1 - 0.5 * (1 + erf(2*(fit - threshold)./tol)));
      
      ind = prob > 0.1;

      i = [i;indC(ind,1) + bestFriend(k1)-1;indC(ind,2) + bestFriend(k2)-1]; %#ok<*AGROW> 
      j = [j;indC(ind,2) + bestFriend(k2)-1;indC(ind,1) + bestFriend(k1)-1];
      p = [p;prob(ind);prob(ind)];
    
    end
  end

  job.graph = max(job.graph, sparse(i, j , p, nVG, nVG));

end
 
% if job.votes contains information consider only those variants with
% positive probability
if ~isempty(job.votes) 

    [p2cV, bestFriend] = variants(job.p2c,'parent');
    numV = length(p2cV);
    indV1 = [1;1+cumsum(numV * job.isChild + job.isParent)];
    ind_corvar = zeros(numV,1);
    ind_corvar(bestFriend(~ismember((1:numV)',bestFriend))) = ...
        find(~ismember((1:numV)',bestFriend));

    %best fitting variant ids and their closest variant
    pos = indV1(1:end-1) + job.votes.parentId(:,1) - 1;
    pos(:,2) = indV1(1:end-1) + ind_corvar(job.votes.parentId(:,1)) - 1;

    D = sparse(pos,pos,1,length(job.graph),length(job.graph));
    job.graph = D * job.graph * D;

end


% remove diagonal entries that are completely isolated
if ~check_option(varargin,'noDiagonal')
  job.graph(sum(job.graph>0)==1,:) = 0;
end
