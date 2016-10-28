function varargout = size(f,varargin)
% overloads size

[varargout{1:nargout}] = size(f.r,varargin{:});
