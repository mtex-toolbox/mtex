function bM = cat(dim,varargin)
% 


mori = cellfun(@(c) c.mori, varargin, 'UniformOutput', false);
N1 = cellfun(@(c) c.N1, varargin, 'UniformOutput', false);

bM = varargin{1};

bM.mori = cat(dim,mori{:});
bM.N1 = cat(dim,N1{:});

