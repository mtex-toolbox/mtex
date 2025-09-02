function S2F = cat(dim,varargin)
% overloads cat

% remove empty arguments
varargin(cellfun('isempty',varargin)) = [];
S2F = varargin{1};

for i = 2:numel(varargin)

  if ~isa(varargin{i},'S2FunMLS')
    S2F = cat(dim,S2FunHandle(S2F),varargin{i:end});
    return
  end

  N = numel(S2F.nodes);
  assert(N == numel(varargin{i}.nodes) &&  all(S2F.nodes(:) == varargin{i}.nodes(:)),...
    "I can only combine S2FunMLS with the same nodes");

  ensureCompatibleSymmetries(S2F,varargin{i});

  S2F.values = cat(1+dim, S2F.values, varargin{i}.values);
  
end
