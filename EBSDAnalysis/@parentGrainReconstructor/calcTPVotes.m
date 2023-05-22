function job = calcTPVotes(job,varargin)
% compute votes from triple points
%
% Syntax
%   job.calcTPVotes
%
%   % only consider triple junctions with the best fit is below 2.5 degree
%   % and the second best fit is worse then 5 degree
%   job.calcTPVotes('minFit',2.5*degree,'maxFit',5*degree)
%
% Input
%  job - @parentGrainReconstructor
%
% Output
%  job.votes - table of votes
%
% Options
%  threshold - threshold fitting angle between job.p2c and the boundary OR
%  tolerance - range over which the probability increases from 0 to 1 (default 1.5)
%  minFit - minimum required fit for a TP to produce votes
%  maxFit - maximum second best fit for a TP to produce votes
%  numFit    - number of fits to compute (default 2)
%

% exctract child - child - child triplepoints
tP = job.grains.triplePoints;
tP = tP(all(tP.phaseId == job.childPhaseId,2));

% compute for each triple point the best fitting parentId and how well the fit is
childOri = job.grains(tP.grainId).meanOrientation;

% ensure all child orientations are sufficiently different
%ind = min(angle(childOri(:,[2 3 1]),childOri),[],2) > 10*degree;
%childOri = childOri(ind,:);

[parentId, fit] = calcParent(childOri, job.p2c,'numFit',2,...
  'id','threshold',5*degree,varargin{:});
fit = repmat(reshape(fit,[],1,2),1,3,1);

% turn grainId into grainInd
grainInd = job.grains.id2ind(repmat(tP.grainId,1,1,size(parentId,3)));

% accumulate votes, i.e. compute a probability for each grain / parentId
% combination
job.votes = accumVotes(grainInd, parentId, fit, length(job.grains), varargin{:});

end