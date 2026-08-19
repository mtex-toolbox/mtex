function [T,interface,options] = loadTensor(fname,varargin)
% obsolete, use tensor.load

warning('loadTensor is depreciated. Please use instead tensor.load');
[T,interface,options] = tensor.load(fname,varargin{:});
