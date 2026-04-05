function s = size(S2F, varargin)
% overloads size

if (numel(S2F.nodes) == numel(S2F.values))
  s = [1, 1]; 
else
  sizes = size(S2F.values);
  s = sizes(2 : end);
end

if (isscalar(s)), s = [s, 1]; end
if nargin > 1, s = s(varargin{1}); end
  
end
