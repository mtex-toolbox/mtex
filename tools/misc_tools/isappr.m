function b = isappr(x,y,varargin)
% check double == double

b = isnull(abs(x-y),varargin{:});
