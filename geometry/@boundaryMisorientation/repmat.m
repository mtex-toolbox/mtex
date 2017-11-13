function bM = repmat(bM,varargin) 
% overloads repmat

bM.mori = repmat(bM.mori,varargin{:});
bM.N1 = repmat(bM.N1,varargin{:});
