function SO3F = cat(dim,varargin)
% overloads cat

% remove empty arguments
varargin(cellfun('isempty',varargin)) = [];
SO3F = SO3FunHarmonic(varargin{1});
bw = SO3F.bandwidth;

for i = 2:numel(varargin)
  
  f = SO3FunHarmonic(varargin{i});

  bw2 = f.bandwidth;
  if bw > bw2
    f.bandwidth = bw;
  else
    bw = bw2;
    SO3F.bandwidth = bw2;
  end

  ensureCompatibleSymmetries(SO3F,f);

  SO3F.fhat = cat(1+dim, SO3F.fhat, f.fhat);

end
