function F = cat(dim,varargin)
% overloads cat
%
% MLS functions on the same nodes are concatenated as an MLS function,
% anything else as a function handle.

varargin(cellfun('isempty',varargin)) = [];
F = varargin{1};

for i = 2:numel(varargin)

  G = varargin{i};
  if ~isa(G,'MLSFun') || numel(F.nodes) ~= numel(G.nodes) || ~all(F.nodes(:) == G.nodes(:))
    F = cat(dim,F.toHandle,varargin{i:end});
    return
  end

  ensureCompatibleSymmetries(F,G);
  F.values = cat(1+dim,F.values,G.values);

end

end
