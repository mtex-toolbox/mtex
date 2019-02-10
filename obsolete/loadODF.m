function [odf,interface,options] = loadODF(fname,varargin)
% obsolete, use ODF.load

warning('loadTensor is depreciated. Please use instead tensor.load');
[odf,interface,options] = ODF.load(fname,varargin{:});


