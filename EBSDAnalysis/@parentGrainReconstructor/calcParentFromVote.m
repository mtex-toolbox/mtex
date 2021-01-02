function job = calcParentFromVote(job,varargin)
% reconstruct parent orientations from boundary or triple point votes
%
% Syntax
%
%   % take majority vote
%   job.calcParentFromVote('minFit',2*degree,'minVotes',2)
%
%   % all votes must be equal
%   job.calcParentFromVote('strict','minVotes',2)
%
%   % go by probability
%   job.calcParentFromVote('probability','threshold',1.5*degree,'tolerance',1.5*degree,'minProb',0.6)
%
% Input
%  job - @parentGrainReconstructor
%
% Output
%  job - @parentGrainReconstructor
%
% Options
%  probability - 
%  strict - require all votes to be equal
%  minFit - minimum required fit
%  maxFit - maximum second best fit
%  minVotes - minimum number of required votes
%  minProb  - minimum probability


assert(~isempty(job.votes),'You need to compute votes first.');


if check_option(varargin,'probability')
  
   threshold = get_option(varargin,'threshold',2*degree);
   tol = get_option(varargin,'tolerance',1.5*degree);
 
   prob = 1 - 0.5 * (1 + erf(2*(job.votes.fit - threshold)./tol));
   prob(prob<1e-2) = 0;
   if any(strcmp(job.votes.Properties.VariableNames,'weights'))
     prob = prob .* sqrt(job.votes.weights); 
   end
   
   % perform voting
   [parentId, numVotes] = majorityVote( repmat(job.votes.grainId,1,size(prob,2)), ...
     job.votes.parentId, max(job.grains.id),'weights',prob);

   % which child grains to transform
   doTransform = numVotes > get_option(varargin,'minProb',0);
   vdisp(['  votes prob > minProb: ',xnum2str(100*nnz(doTransform)/nnz(numVotes)) '%'],varargin{:});
   
else

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
  doTransform = numVotes >= get_option(varargin,'minVotes',1);
  vdisp(['  numVotes >= minVotes: ',xnum2str(100*nnz(doTransform)/nnz(numVotes)) '%'],varargin{:});
  
end
vdisp(' ',varargin{:})

% compute new parent orientation from parentId
pOri = variants(job.p2c, job.grains(doTransform).meanOrientation, parentId(doTransform));

% change orientations of consistent grains from child to parent
job.grains(doTransform).meanOrientation = pOri;

% update all grain properties that are related to the mean orientation
job.grains = job.grains.update;

job.votes = [];

end