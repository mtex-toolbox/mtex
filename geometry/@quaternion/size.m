function varargout = size(q,varargin)
% overloads size

[varargout{1:nargout}] = size(q.a,varargin{:});
