function SO3F = subSet(SO3F,varargin)
% subindex SO3FunMLS

num_dims_nodes = ndims(SO3F.nodes);

% if nodes are 2d, then values is numel(nodes) x ...
if (num_dims_nodes == 2)
  SO3F.values = SO3F.values(:,varargin{:});
  return;
end

% if nodes are 2d, then values is size(nodes) x ...
idx = [repmat({':'}, 1, num_dims_nodes), varargin{:}];
SO3F.values = SO3F.values(idx{:});

end
