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
numG = length(job.grains);
numV = length(p2cV);
job.graph = cell(numV,numV);
for k = 1:numel(job.graph), job.graph{k} = sparse(numG,numG); end

% parent to parent probabilities
if ~isempty(job.parentGrains) && (check_option(varargin,'p2p') || noOpt)
 
  % get all parent to parent grain pairs
  [grainPairs, oriParent] = getP2PPairs(job,'index',varargin{:});
  
  % compute fit
  fit = angle(oriParent(:,1), oriParent(:,2));
  prob = 1 - 0.5 * (1 + erf(2*(fit - threshold)./tol));
  ind = prob > 0.1;
  
  % write to graph
  job.graph{1,1} = speye(numG) + max(...
    sparse(grainPairs(ind,1),grainPairs(ind,2),prob(ind),numG,numG),...
    sparse(grainPairs(ind,2),grainPairs(ind,1),prob(ind),numG,numG));
  
end

% set diagonal elements to 1, i.e.,
% each parentId has the same chance to begin with
if check_option(varargin,'withDiagonal')
  
  childId = job.grains.id(job.grains.phaseId == job.childPhaseId);
  
  % fit between the parent variants of the same child
  %fit = angle_outer(p2cV,p2cV);
  %prob = 1 - 0.5 * (1 + erf(2*(fit - threshold)./tol));
  
  %for k = find(prob > 0.1).'
  %  job.graph{k} = sparse(childId,childId,prob(k),numG,numG);
  %end  
  
  for k = 1:numV
    job.graph{k,k} = max(job.graph{k,k},...
      sparse(childId,childId,1,numG,numG));
  end
  
end

% parent to child probabilities
if ~isempty(job.parentGrains) && (check_option(varargin,'P2C') || noOpt)
 
  % get all child to child grain pairs
  [grainPairs, oriParent, oriChild] = getP2CPairs(job,'index',varargin{:});
    
  for k2 = 1:numV
      
    % compute fit
    fit = angle(oriParent, oriChild * p2cV(k2));
    prob = 1 - 0.5 * (1 + erf(2*(fit - threshold)./tol));
    ind = prob > 0.1;
    
    job.graph{1,k2} = max(job.graph{1,k2}, ...
      sparse(grainPairs(ind,1),grainPairs(ind,2),prob(ind),numG,numG));
    
    % symmetrise graph
    job.graph{k2,1} = max(job.graph{k2,1}, ...
      sparse(grainPairs(ind,2),grainPairs(ind,1),prob(ind),numG,numG));
    
  end
end

% child to child probabilities
if check_option(varargin,'C2C') || noOpt
 
  % get all child to child grain pairs
  [grainPairs, oriChild] = getC2CPairs(job,'index',varargin{:});
    
  p2cV = variants(job.p2c,'parent');
  for k1 = 1:length(p2cV)
    for k2 = 1:length(p2cV)
      
      % compute fit
      fit = angle(oriChild(:,1) * p2cV(k1),oriChild(:,2) * p2cV(k2));
      prob = 1 - 0.5 * (1 + erf(2*(fit - threshold)./tol));
      ind = prob > 0.1;
            
      job.graph{k1,k2} = max(job.graph{k1,k2}, ...
        sparse(grainPairs(ind,1),grainPairs(ind,2),prob(ind),numG,numG));
      
      % symmetrise graph
      job.graph{k2,k1} = max(job.graph{k2,k1}, ...
        sparse(grainPairs(ind,2),grainPairs(ind,1),prob(ind),numG,numG));
      
    end
  end
end

end
 