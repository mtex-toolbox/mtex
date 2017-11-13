function bM = reshape(bM,varargin) 
% overloads reshape

bM.mori = reshape(bM.mori,varargin{:});
bM.N1 = reshape(bM.N1,varargin{:});
