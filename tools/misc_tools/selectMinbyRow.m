function [A,varargout] = selectMinbyRow(A,varargin)
% find minimum in each row

s = size(A);
[A,ind] = min(A,[],2);
ind = sub2ind(s,1:s(1),ind.');

for i = 1:nargout-1
  varargout{i} = varargin{i}(ind.');
end
