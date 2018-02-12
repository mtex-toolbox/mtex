function varargout = size(dS,varargin)
% overloads size

[varargout{1:nargout}] = size(dS.b.x,varargin{:});
