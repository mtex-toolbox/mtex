function varargout = size(bM,varargin)
% overloads size

[varargout{1:nargout}] = size(bM.mori,varargin{:});
