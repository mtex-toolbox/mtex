function s = size(S2F, varargin)
% overloads size

% trivial case for  S2F being scalar
if (numel(S2F.nodes) == numel(S2F.values))
  s = [1, 1]; 

% if nodes are a vector (1xN or Nx1), then values is N x ...
% it suffices to check if the first 2 dimensions contain a 1, because we squeeze
%   the nodes in the constructor
elseif (size(S2F.nodes, 1) == 1 || size(S2F.nodes, 2) == 1)
  s = size(S2F.values);
  s = s(2 : end);

else
  % if nodes are not a vector, then values is size(nodes) x ...
  values_size = size(S2F.values);
  values_size_cumprod = cumprod(values_size);
  id = find(numel(S2F.nodes) == values_size_cumprod, 1, 'first');
  s = values_size(id+1 : end);
end

if isscalar(s), s = [s 1]; end
if nargin > 1, s = s(varargin{1}); end
  
end
