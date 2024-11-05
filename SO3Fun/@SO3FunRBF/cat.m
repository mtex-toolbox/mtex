function SO3F = cat(dim,varargin)
% overloads cat

% remove empty arguments
varargin(cellfun('isempty',varargin)) = [];
SO3F = varargin{1};

for i = 2:numel(varargin)

  N = numel(SO3F.center);
  assert(N == numel(varargin{i}.center),...
    "I can only combine SO3FunRBF with the same center");
    
  ensureCompatibleSymmetries(SO3F,varargin{i});

  SO3F.weights = cat(1+dim, ...
    reshape(SO3F.weights,N,[],size(SO3F.weights,3)), ...
    reshape(varargin{i}.weights,N,[],size(varargin{i}.weights,3)));
end
