function out = calcGrainVotes(job,varargin)
% compute votes from grain boundaries
%
% Syntax
%
%   % compute votes from all p2c and c2c boundaries
%   job.calcGBVotes('threshold', 2*degree)
%
%   % compute votes only from p2c boundaries -> growth algorithm
%   job.calcGBVotes('p2c', 'threshold', 3*degree, 'tol', 1.5*degree)
%
% Input
%  job - @parentGrainReconstructor
%
% Output
%  job.votes - table of votes
%
% Options
%  p2c  - consider only parent / child grain boundaries
%  c2c  - consider only child / child grain boundaries
%  threshold - threshold fitting angle between job.p2c and the boundary OR
%  tolerance - range over which the probability increases from 0 to 1 (default 1.5)
%  numFit - number of fits to be computed
%

% noOpt = ~check_option(varargin,{'p2c','c2c'});

if nargin > 1 && isnumeric(varargin{1})
  id = varargin{1};
else
  id = job.grains.id;
end

% the original child orientation
ori = job.grainsPrior('id',id).meanOrientation;

% all variants
oriV = variants(job.p2c, ori);
numV = size(oriV,2);

% fit with neighboring grains
A = job.grains('id',id).neighbors('matrix','maxId',max(job.grains.id));
A = A(id,:);
[grainInd,nId] = find(A);
grainInd = grainInd(:); nId = nId(:);

% some neighbors correspond to parent and some to child grains
nInd = job.grains.id2ind(nId);
isParent = job.grains.phaseId(nInd) == job.parentPhaseId;
oriP = job.grains(nInd(isParent)).meanOrientation;

% TODO -> this is currently not considered
%isChild = job.grains.phaseId(nInd) == job.childPhaseId;
%oriChildV = variants(job.p2c,job.grains(nInd(isChild)).meanOrientation);

% compute fits to all neighbors
fit = nan(length(nId),numV);
for iV = 1:numV
 
  % parent - parent fit
  fit(isParent,iV) = angle(oriV(grainInd(isParent),iV), oriP);
  
  % parent - child fit
  %fit(isChild,iV) = min(angle(oriV(grainInd(isChild),iV), oriChildV),[],2);
  
end

% accumulate votes, i.e. compute a probability for each grain / parentId
% combination
votes = accumVotes(repmat(grainInd,1,numV), repmat(1:numV,length(grainInd),1), fit,...
  max(grainInd), varargin{:});

% output 
if nargin > 1 && isnumeric(varargin{1})
  out = votes;
else
  job.votes = votes;  
  out = job;
end

end