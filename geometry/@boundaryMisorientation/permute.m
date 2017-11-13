function bM = permute(bM,varargin) 
% overloads permute

bM.mori = permute(bM.mori,varargin{:});
bM.N = permute(bM.N,varargin{:});

