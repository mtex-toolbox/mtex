function SO3F = cat(dim,varargin)
% overloads cat

% remove empty arguments
varargin(cellfun('isempty',varargin)) = [];
SO3F = varargin{1};

for i = 2:numel(varargin)

  ensureCompatibleSymmetries(SO3F,varargin{i});

  SO3F.fun = @(rot) cat(1+dim, reshape(SO3F.eval(rot),[numel(rot) size(SO3F)]) , reshape(varargin{i}.eval(rot),[numel(rot) size(varargin{i})]) ); 
  
end
