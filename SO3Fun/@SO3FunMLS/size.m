function s = size(SO3F,varargin)
% overloads size

s = size(SO3F.values);
s = s(2:end);
if isscalar(s), s = [s 1]; end
if nargin > 1, s = s(varargin{1}); end
  
end
