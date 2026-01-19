function S2F = subSet(S2F,varargin)
% subindex S2FunMLS

num_dims_nodes = ndims(S2F.nodes);

% if nodes are 2d, then values is numel(nodes) x ...
if (num_dims_nodes == 2)
  S2F.values = S2F.values(:,varargin{:});
  return;
end

% if nodes are 2d, then values is size(nodes) x ...
idx = [repmat({':'}, 1, num_dims_nodes), varargin{:}];
S2F.values = S2F.values(idx{:});

end
