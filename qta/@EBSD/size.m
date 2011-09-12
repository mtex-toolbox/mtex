function varargout = size(ebsd,varargin)
% overloads size

[varargout{1:nargout}] = size(ebsd.rotations,varargin{:});
