function [ori,varargout] = loadOrientation(fname,varargin)

warning('loadOrientation is depreciated. Please use instead orientation.load');
[ori,varargout{1:nargout-1}] = orientation.load(fname,varargin{:});
