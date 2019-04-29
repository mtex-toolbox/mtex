function [odf,interface,options] = loadODF(fname,varargin)
% obsolete, use ODF.load

warning('loadODF is depreciated. Please use instead ODF.load');
[odf,interface,options] = ODF.load(fname,varargin{:});


