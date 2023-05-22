function job = calcParentFromVote(job,varargin)
% reconstruct parent orientations from boundary or triple point votes
%
% Syntax
%
%   % compute votes
%   job.calcGBVotes('threshold',1.5*degree,'tolerance',1.5*degree)
%
%   % take vote with highest probability for reconstruction
%   job.calcParentFromVote
%
%   % require probability to be at least 0.6
%   job.calcParentFromVote('minProb',0.6)
%
% Input
%  job - @parentGrainReconstructor
%
% Output
%  job - @parentGrainReconstructor
%
% Options
%  minVotes - minimum number of required votes
%  minProb  - minimum probability (default - 0)
%  minAlpha - minimum factor between best and second best probability
%  minDelta - minimum difference between best and second best probability
%
% References
%
% * <https://doi.org/10.1107/S1600576721011560 Parent grain reconstruction
% from partially or fully transformed microstructures in MTEX>, J. Appl.
% Cryst. 55, 2022.
%

assert(~isempty(job.votes),'You need to compute votes first!');

% which to transform
switch job.votes.Properties.VariableNames{2}
  case 'fit'

    doTransform = job.votes.fit(:,1) < get_option(varargin,'minFit',5*degree);
      
    if check_option(varargin,'minDelta')  
      doTransform = doTransform & ...
        job.votes.fit(:,2)-job.votes.fit(:,1) > get_option(varargin,'minDelta',0);
    end
    
    if check_option(varargin,'minAlpha')  
      doTransform = doTransform & ...
        job.votes.fit(:,1) > get_option(varargin,'minAlpha',0) * job.votes.fit(:,2);
    end
  
  case 'prob'
  
    doTransform = job.votes.parentId(:,1)>0 & ...
      job.votes.prob(:,1) > get_option(varargin,'minProb',0);

    if check_option(varargin,'minDelta')  
      doTransform = doTransform & ...
        job.votes.prob(:,1)-job.votes.prob(:,2) > get_option(varargin,'minDelta',0);
    end
    
  case 'count'
  
    doTransform = job.votes.count(:,1) >= get_option(varargin,'minCount',0);
    
    if check_option(varargin,'maxCount')  
      doTransform = doTransform & ...
        job.votes.count(:,2) < get_option(varargin,'maxCount',inf);
    end

end

% compute new parent orientation from parentId
if any(job.isParent(doTransform))
  pOri = variants(job.p2c, job.grainsPrior(doTransform).meanOrientation, job.votes.parentId(doTransform,1));
else
  pOri = variants(job.p2c, job.grains(doTransform).meanOrientation, job.votes.parentId(doTransform,1));
end

% change orientations of consistent grains from child to parent
job.grains(doTransform).meanOrientation = pOri;

% update all grain properties that are related to the mean orientation
job.grains = job.grains.update;

% remove votes
switch job.votes.Properties.VariableNames{2}
  case 'fit'
    job.votes.fit(doTransform,:) = nan;
  case 'prob'
    job.votes.prob(doTransform,:) = nan;
  case 'count'
    job.votes.count(doTransform,:) = nan;
end