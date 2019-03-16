function [ebsd,interface,options] = loadEBSD(fname,varargin)

warning('loadEBSD is depreciated. Please use instead EBSD.load');
[ebsd,interface,options] = EBSD.load(fname,varargin{:});