function job = calcTPVotes(job,varargin)
%
% Syntax
%   job.calcTPVotes
%
% Input
%  job - @parentGrainReconstructor
%
% Output
%  job.votes - table of votes
%
% Options
%  threshold - maximum allowed mean misfit
%  numFit    - number of fits to compute (default 2)
%

% exctract child - child - child triplepoints
tP = job.grains.triplePoints;
tP = tP(all(tP.phaseId == job.childPhaseId,2));

% compute for each triple point the best fitting parentId and how well the fit is
childOri = job.grains(tP.grainId).meanOrientation;

[parentId, fit] = calcParent(childOri, job.p2c,'numFit',2,...
  'id','threshold',5*degree,varargin{:});

job.votes = table(tP.grainId(:), reshape(parentId,3*length(tP),[]), repmat(fit,3,1), ...
  'VariableNames',{'grainId','parentId','fit'});

end