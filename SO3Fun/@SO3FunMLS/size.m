function s = size(SO3F, varargin)
% overloads size


if (numel(SO3F.nodes) == numel(SO3F.values))
  s = [1, 1]; 
  return;
end


% if nodes are 2D array, then values is numel(nodes) x ...
if (ndims(SO3F.nodes) == 2)
  s = size(SO3F.values);
  s = s(2 : end);
  if isscalar(s)
    s = [s, 1];
  end
  return;
end


% if nodes are not 2D array, then values is size(nodes) x ...
values_size = size(SO3F.values);
values_size_cumprod = cumprod(values_size);
id = find(numel(SO3F.nodes) == values_size_cumprod, 1, 'first');


s = values_size(id+1 : end);

if isscalar(s), s = [s 1]; end
if nargin > 1, s = s(varargin{1}); end
  
end
