function SO3F = cat(dim,varargin)
% overloads cat

% remove empty arguments
varargin(cellfun('isempty',varargin)) = [];
SO3F = varargin{1};

for i = 2:numel(varargin)

  if ~isa(varargin{i},'SO3FunMLS')
    SO3F = cat(dim,SO3FunHandle(SO3F),varargin{i:end});
    return
  end

  N = numel(SO3F.nodes);
  assert(N == numel(varargin{i}.nodes) &&  all(SO3F.nodes(:) == varargin{i}.nodes(:)),...
    "I can only combine SO3FunMLS with the same nodes");

  ensureCompatibleSymmetries(SO3F,varargin{i});

  SO3F.values = cat(1+dim, SO3F.values, varargin{i}.values);
  
end
