function [A,varargout] = selectMinbyRow(A,varargin)
% find maximum in each column

% find maximum values
ind = A == repmat(min(A,[],2),1,size(A,2));

% select only the first minimum
ind = ind & ind == cumsum(ind,2);

% transpose to keep order
A = A.';
ind = ind.';

% return results
A = A(ind);

for i = 1:nargout-1
  varargout{i} = varargin{i}.';
  varargout{i} = varargout{i}(ind);
end
