function [vote, numVotes] = majorityVote(id,votes,varargin)



if isnumeric(varargin{1})
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

