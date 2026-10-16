function s = size(F,varargin)
% overloads size

if numel(F.nodes) == numel(F.values)
  s = [1 1];
else
  s = size(F.values);
  s = s(2:end);
end

if isscalar(s), s = [s 1]; end
if nargin > 1, s = s(varargin{1}); end

end
