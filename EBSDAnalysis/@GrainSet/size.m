function varargout = size(grains,varargin)
% overloads size

[varargout{1:nargout}] = size(grains.meanRotation,varargin{:});