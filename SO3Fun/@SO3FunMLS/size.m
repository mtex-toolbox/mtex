function s = size(SO3F, varargin)
% overloads size


% trivial case for SO3F being scalar
 
if (numel(SO3F.nodes) == numel(SO3F.values))
  s = [1, 1]; 

% if nodes are a Nx1 or 1xN vector, then values is numel(nodes) x ...
elseif (size(SO3F.nodes, 1) == 1 || size(SO3F.nodes, 2) == 1)
  s = size(SO3F.values);
  s = s(2 : end);

else
  % if nodes are not a vector, then values is size(nodes) x ...
  values_size = size(SO3F.values);
  values_size_cumprod = cumprod(values_size);
  id = find(numel(SO3F.nodes) == values_size_cumprod, 1, 'first');
  s = values_size(id+1 : end);
end

if isscalar(s), s = [s 1]; end
if nargin > 1, s = s(varargin{1}); end

end
