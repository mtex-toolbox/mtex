function s = size(SO3F, varargin)
% overloads size

if (numel(SO3F.nodes) == numel(SO3F.values))
  s = [1, 1]; 
else
  sizes = size(SO3F.values);
  s = sizes(2 : end);
end

if (isscalar(s)), s = [s, 1]; end
if nargin > 1, s = s(varargin{1}); end
  
end
