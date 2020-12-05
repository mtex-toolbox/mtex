function job = calcParentFromVote(job,varargin)
%
% Input
%  job - @parentGrainReconstructor
%
% Output
%  job - @parentGrainReconstructor
%
% Options
%  strict - require all votes to be equal
%  minFit - minimum required fit
%  maxFit - maximum second best fit
%  minVotes - minimum number of required votes


assert(~isempty(job.votes),'You need to compute votes first.');

% consider only consistent votes
minFit = get_option(varargin,'minFit',inf);
maxFit = get_option(varargin,'maxFit',-inf);

consistenVotes = job.votes.fit(:,1) < minFit;
vdisp(' ',varargin{:})
vdisp(['  votes   fit < misFit: ',xnum2str(100*nnz(consistenVotes)/length(consistenVotes)) '%'],varargin{:});
if size(job.votes.fit,2)>1
  consistenVotes = consistenVotes & job.votes.fit(:,2) > maxFit;
  vdisp(['  votes  fit2 > maxFit: ',xnum2str(100*nnz(consistenVotes)/length(consistenVotes)) '%'],varargin{:});
end

job.votes = job.votes(consistenVotes,:);

% perform voting
[parentId, numVotes] = majorityVote( job.votes.grainId, ...
  job.votes.parentId(:,1), max(job.grains.id),varargin{:});

% which child grains to transform
doTransform = numVotes > get_option(varargin,'minVotes',0);
vdisp(['  numVotes > minVotes:  ',xnum2str(100*nnz(doTransform)/nnz(numVotes)) '%'],varargin{:});
vdisp(' ',varargin{:})

% compute new parent orientation from parentId
pOri = variants(job.p2c, job.grains(doTransform).meanOrientation, parentId(doTransform));

% change orientations of consistent grains from child to parent
job.grains(doTransform).meanOrientation = pOri;

% update all grain properties that are related to the mean orientation
job.grains = job.grains.update;

job.votes = [];

end