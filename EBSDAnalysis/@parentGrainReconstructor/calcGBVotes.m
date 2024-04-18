function out = calcGBVotes(job,varargin)
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
%  bestFit   - best fitting parent wins
%  threshold - threshold fitting angle between job.p2c and the boundary OR
%  tolerance - range over which the probability increases from 0 to 1 (default 1.5)
%  numFit    - number of fits to be computed
%  reconsiderAll - reconsider also already reconstructed grains
%

numFit = get_option(varargin,'numFit',2);
noOpt = ~check_option(varargin,{'p2c','c2c'});

% maybe we should consider only some of the grains
if nargin > 1 && isnumeric(varargin{1})

  id = varargin{1};
  wasChild = true(size(id));
  
else
  
  id = job.grains.id;
  
  % only the prior child grains needs to be considered
  wasChild = job.grainsPrior.phaseId==job.childPhaseId;

end

% if we reconsider all grains we need a seperate algorithm
if check_option(varargin,'reconsiderAll')

  
  % the original child orientation
  ori = job.grainsPrior('id',id(wasChild)).meanOrientation;

  % all variants
  oriV = variants(job.p2c, ori);
  numV = size(oriV,2);

  % fit with neighboring grains
  % TODO: this can be done better
  A = job.grains('id',id(wasChild)).neighbors('matrix','maxId',max(job.grains.id));
  A = A(id(wasChild),:);
  [grainInd,nId] = find(A);
  grainInd = grainInd(:); nId = nId(:);

  % compute boundary weights
  if check_option(varargin,'curvatureFactor')
    w = calcBndWeights(job.grains.boundary, [id(grainInd),nId],varargin{:});
  else
    w = 1;
  end
  
  % some neighbors correspond to parent and some to child grains
  nInd = job.grains.id2ind(nId);
  isParent = job.grains.phaseId(nInd) == job.parentPhaseId;
  oriP = job.grains(nInd(isParent)).meanOrientation;

  % this is if we want to check fit towards childs as well
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

  
  i2i = cumsum(~wasChild); i2i = i2i(wasChild);
  grainInd = grainInd + i2i(grainInd);

  % accumulate votes, i.e. compute a probability for each grain / parentId
  % combination
  votes = accumVotes(repmat(grainInd,1,numV), repmat(1:numV,length(grainInd),1), fit,...
    length(job.grains), 'weights', repmat(w,1,numV), varargin{:},'numFit',numV);
  
else
  
  % parent-child - votes
  if ~isempty(job.parentGrains) && (noOpt || check_option(varargin,'p2c'))
  
    % extract parent to child grain pairs with the coresponding orientations
    % averaged along the boundary
    [grainPairs, oriParent, oriChild] = getP2CPairs(job,varargin{:});
    grainId1 = repmat(grainPairs(:,2),1,numFit);

    % compute for each parent/child pair of grains the best fitting parentId
    [parentId1, fit1] = calcParent(oriChild,oriParent,job.p2c,'numFit',numFit,'id');

  else
    parentId1 = [];
    fit1 = [];
    grainId1 = [];
  end

  % child-child - votes
  if noOpt || check_option(varargin,'c2c')

    % extract child to child grain pairs with the corresponding orientations
    % averaged along the boundary
    [grainId2, oriChild, w2] = getC2CPairs(job,'minDelta',2*degree,varargin{:});
    
    % compute for each parent/child pair of grains the best fitting parentId
    [parentId2, fit2] = calcParent(oriChild,job.p2c,'numFit',numFit,'id');
    grainId2 = repmat(grainId2,1,1,numFit);
    w2 = repmat(w2,1,1,numFit);
    fit2 = repmat(reshape(fit2,[],1,numFit),1,2,1);
    
    % TODO: the curvature weight is currently not considered!!


  else
    parentId2 = [];
    fit2 = [];
    grainId2 = [];
  end

  % turn grainId into grainInd
  grainInd = job.grains.id2ind([grainId1(:);grainId2(:)]);

  % accumulate votes, i.e. compute a probability for each grain / parentId
  % combination
  votes = accumVotes(grainInd, [parentId1(:);parentId2(:)], ...
    [fit1(:); fit2(:)], length(job.grains), varargin{:});

end

% output
if nargin > 1 && isnumeric(varargin{1})
  out = votes;
else
  job.votes = votes;  
  out = job;
end