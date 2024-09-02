function varargout = size(plane,varargin)
% overloads size

[varargout{1:nargout}] = size(plane.a,varargin{:});
