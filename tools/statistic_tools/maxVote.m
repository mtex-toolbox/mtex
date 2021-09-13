function maxInd = maxVote(ind,data,varargin)
% returns
%
% Syntax 
%
%   maxInd = maxVote(ind,data)
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
%   ind  = [1,2,3,1,3,2,1];
%   data = [2,3,1,1,2,1,3]; 
%   maxInd = [7, 2, 5]
%   maxInd = maxVote(ind,data)
%
% See also
%

[~,a] = sort(data,varargin{:});

newInd = (1:length(data)).';

maxInd = accumarray(reshape(ind(a),[],1),reshape(newInd(a),[],1),...
  [],@(x) x(end));
