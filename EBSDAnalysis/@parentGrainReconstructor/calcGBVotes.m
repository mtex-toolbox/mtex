function job = calcGBVotes(job,varargin)
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

numFit = get_option(varargin,'numFit',2);
noOpt = ~check_option(varargin,{'p2c','c2c'});

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

  % extract child to child grain pairs with the coresponding orientations
  % averaged along the boundary
  [grainId2, oriChild] = getC2CPairs(job,'minDelta',2*degree,varargin{:});
  
  % compute for each parent/child pair of grains the best fitting parentId
  [parentId2, fit2] = calcParent(oriChild,job.p2c,'numFit',numFit,'id');
  grainId2 = repmat(grainId2,1,1,numFit);
  fit2 = repmat(reshape(fit2,[],1,numFit),1,2,1);
  
else
  parentId2 = [];
  fit2 = [];
  grainId2 = [];    
end

% turn grainId into grainInd
grainInd = job.grains.id2ind([grainId1(:);grainId2(:)]);

% accumulate votes, i.e. compute a probability for each grain / parentId
% combination
job.votes = accumVotes(grainInd, [parentId1(:);parentId2(:)], ...
  [fit1(:); fit2(:)], length(job.grains), varargin{:});

end
