function [ori,interface,options] = loadOrientation(fname,varargin)

warning('loadOrientation is depreciated. Please use instead orientation.load');
[ori,interface,options] = orientation.load(fname,varargin{:});
