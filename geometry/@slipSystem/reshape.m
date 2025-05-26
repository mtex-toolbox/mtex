function sS = reshape(sS,varargin) 
% overloads reshape

sS.b = reshape(sS.b,varargin{:});
sS.n = reshape(sS.n,varargin{:});
sS.CRSS =  reshape(sS.CRSS,varargin{:});