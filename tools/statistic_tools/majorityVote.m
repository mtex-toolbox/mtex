function [vote, numVotes] = majorityVote(id,votes,varargin)
% returns
%
% Syntax 
%
%   [vote, numVotes] = majorityVote(idList,voteList)
%
% Input
%  idList   - list of ids 
%  voteList - list of votes
%
% Output
%  vote     - most frequent vote in voteList(idList == id) for each id
%  numVotes - number occurences of vote in voteList(idList == id) for each id
%
% Options
%  strict - only assign a vote if all votes coincide, otherwise set in to nan
%
% Example
%
%   idList = [1 1 1 1 1 2 3 2 3 2 3];
%   voteList = [5 9 5 9 9 4 1 4 2 4 1];
% 
%   majorityVote(idList,voteList)
%
%   majorityVote(idList,voteList,'strict')
%
% See also
%

if nargin > 2 && isnumeric(varargin{1})
  maxId = varargin{1};
else
  maxId = max(id(:));
end

% only vote if all voteIds are equal
if check_option(varargin,'strict')

  % check for equal voteIds
  isEqual = accumarray(id(:),votes(:),[maxId 1],@equal);

  % find the unique voteId
  vote = accumarray(id(:),votes(:),[maxId 1],@(x) x(1));

  vote(~isEqual) = nan;
  
  % second output argument is the number of votes for the unique voteId
  if nargout == 2
    numVotes = accumarray(id(:),votes(:),[maxId 1],@(x) nnz(x==x(1)));
    numVotes(~isEqual) = 0;
  end
  
elseif check_option(varargin,'weights')
  % compute a probability for each vote
  
  % get the probabilities for each voteId
  w = get_option(varargin,'weights');
  
  % probability matrix
  % columns are different voteIds
  % rows are the different votings
  % value is the probability
  W = sparse(id,votes,w,maxId,max(votes(:)));
  
  % numVote is likelyhood
  % vote the voteId with maximum likelihood
  [numVotes, vote] = max(W,[],2);
  
  % second best probability
  W(sub2ind(size(W),1:length(vote),vote.')) = 0;
  prob2 = full(max(W,[],2));
  
  %numVotes = full(numVotes) ./ (1e-3 + full(sum(W,2)));
  numVotes = full(numVotes) ./ (1e-3 + prob2 + full(numVotes));
    
else
  % take the voteId with the most votes
  
  hasVote = accumarray(id(:),votes(:),[maxId 1]);
  
  vote = accumarray(id(:),votes(:),[maxId 1],@(x) mode(x));
  
  vote(~hasVote) = nan;

  if nargout == 2
    numVotes = accumarray(id(:),votes(:),[maxId 1],@(x) nnz(x==mode(x)));
  end
  
end

