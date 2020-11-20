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

if check_option(varargin,'strict')

  isEqual = accumarray(id(:),votes(:),[maxId 1],@equal);

  vote = accumarray(id(:),votes(:),[maxId 1],@(x) x(1));

  vote(~isEqual) = nan;
  
  if nargout == 2
    numVotes = accumarray(id(:),votes(:),[maxId 1],@(x) nnz(x==x(1)));
    numVotes(~isEqual) = 0;
  end
  
else
  
  hasVote = accumarray(id(:),votes(:),[maxId 1]);
  
  vote = accumarray(id(:),votes(:),[maxId 1],@(x) mode(x));
  
  vote(~hasVote) = nan;

  if nargout == 2
    numVotes = accumarray(id(:),votes(:),[maxId 1],@(x) nnz(x==mode(x)));
  end
  
end

