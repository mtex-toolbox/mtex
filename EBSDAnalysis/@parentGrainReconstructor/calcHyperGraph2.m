function job = calcHyperGraph2(job, varargin)
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
%  C2C     - consider only child to child grain boundaries
%  P2C     - consider only parent to child grain boundaries
%
% Description
% The weights of the graph are computed from a cummulative Gaussian
% distribution with mean given by the option |'threshold'| and variance
% given by the option |'tolerance'|
%

% get parameters
threshold = get_option(varargin,'threshold',2*degree);
tol = get_option(varargin,'tolerance',1.5*degree);
noOpt = ~check_option(varargin,{'p2c','p2p','c2c'});

% init graph
p2cV = variants(job.p2c,'parent');
numV = length(p2cV);

% index of variant 1
indV1 = [1;1+cumsum(numV * job.isChild + job.isParent)];
nHyper = indV1(end)-1;

if check_option(varargin,'noDiagonal')
  job.graph = sparse(nHyper,nHyper);
else
  job.graph = speye(nHyper,nHyper);  
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
  indP = indV1(grainPairs(ind,:));
  job.graph = job.graph + max(...
    sparse(indP(:,1),indP(:,2),prob(ind),nHyper,nHyper),...
    sparse(indP(:,2),indP(:,1),prob(ind),nHyper,nHyper));
  
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
      sparse(indP(ind), indC(ind) + k2 - 1, prob(ind), nHyper, nHyper));
    
    % symmetrise graph
    job.graph = max(job.graph, ...
      sparse(indC(ind) + k2 - 1, indP(ind), prob(ind), nHyper, nHyper));
    
  end
end

% child to child probabilities
if check_option(varargin,'C2C') || noOpt
 
  % get all child to child grain pairs
  [grainPairs, oriChild] = getC2CPairs(job,'index',varargin{:});
  
  % the corresponding indeces in the sparse matrix
  indC = indV1(grainPairs);
    
  for k1 = 1:length(p2cV)
    for k2 = 1:length(p2cV)
      
      % compute fit
      fit = angle(oriChild(:,1) * p2cV(k1),oriChild(:,2) * p2cV(k2));
      prob = 1 - 0.5 * (1 + erf(2*(fit - threshold)./tol));
      ind = prob > 0.1;
            
      job.graph = max(job.graph, ...
        sparse(indC(ind,1) + k1-1, indC(ind,2) + k2-1, prob(ind), nHyper, nHyper));
      
      % symmetrise graph
      job.graph = max(job.graph, ...
        sparse(indC(ind,2) + k2-1, indC(ind,1) + k1-1, prob(ind), nHyper, nHyper));
      
    end
  end
end

end
 