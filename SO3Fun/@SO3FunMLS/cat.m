function SO3F = cat(dim,varargin)
% overloads cat

% remove empty arguments
varargin(cellfun('isempty',varargin)) = [];
SO3F = varargin{1};

for i = 2:numel(varargin)

  N = numel(SO3F.nodes);
  assert(N == numel(varargin{i}.nodes),...
    "I can only combine SO3FunRBF with the same center");

  ensureCompatibleSymmetries(SO3F,varargin{i});

  SO3F.values = cat(1+dim, SO3F.values, varargin{i}.values);
end
