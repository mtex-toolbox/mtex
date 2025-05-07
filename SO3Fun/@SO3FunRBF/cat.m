function SO3F = cat(dim,varargin)
% overloads cat

% remove empty arguments
varargin(cellfun('isempty',varargin)) = [];
SO3F = varargin{1};

for i = 2:numel(varargin)

  N = numel(SO3F.center);
  assert(N == numel(varargin{i}.center) && all(SO3F.center(:) == varargin{i}.center(:)),...
    "I can only combine SO3FunRBF with the same center");
    
  ensureCompatibleSymmetries(SO3F,varargin{i});

  SO3F.c0 = cat(dim, SO3F.c0, varargin{i}.c0);
  SO3F.weights = cat(dim+1, SO3F.weights,varargin{i}.weights);

end
