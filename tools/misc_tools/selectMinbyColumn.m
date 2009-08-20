function [A,varargout] = selectMinbyColumn(A,varargin)
% find minimum in each column

s = size(A);
[A,ind] = min(A,[],1);
ind = sub2ind(s,ind,1:s(2));


for i = 1:nargout-1
  varargout{i} = reshape(varargin{i}(ind),1,[]);
end
