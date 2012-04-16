function varargout = size(v,varargin)
% overloads size

[varargout{1:nargout}] = size(v.x,varargin{:});
