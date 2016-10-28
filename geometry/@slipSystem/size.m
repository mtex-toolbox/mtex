function varargout = size(sS,varargin)
% overloads size

[varargout{1:nargout}] = size(sS.b.x,varargin{:});
