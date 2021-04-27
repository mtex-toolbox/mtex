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
%  minDelta - minimum difference between best and second best probability

assert(~isempty(job.votes),'You need to compute votes first!');

% which to transform
doTransform = job.isChild & job.votes.parentId(:,1)>0 & ...
  job.votes.prob(:,1) > get_option(varargin,'minProb',0) & ...
  job.votes.prob(:,1)-job.votes.prob(:,2) > get_option(varargin,'minDelta',0);

% compute new parent orientation from parentId
pOri = variants(job.p2c, job.grains(doTransform).meanOrientation, job.votes.parentId(doTransform,1));

% change orientations of consistent grains from child to parent
job.grains(doTransform).meanOrientation = pOri;

% update all grain properties that are related to the mean orientation
job.grains = job.grains.update;

% remove votes
job.votes = [];

end