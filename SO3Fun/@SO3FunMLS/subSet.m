function SO3F = subSet(SO3F,varargin)
% subindex SO3FunMLS

% if nodes are 1xN or Nx1 vector, then values is numel(nodes) x ...
if (size(SO3F.nodes, 1) == 1 || size(SO3F.nodes, 2) == 1)
  SO3F.values = SO3F.values(:,varargin{:});
  return;
end

% if nodes are not a vector, then values is size(nodes) x ...
idx = [repmat({':'}, 1, ndims(SO3F.nodes)), varargin{:}];
SO3F.values = SO3F.values(idx{:});

end
