function [pf,interface,options] = loadPoleFigure(fname,varargin)
% obsolete, use PoleFigure.load

warning('loadPoleFigure is depreciated. Please use instead PoleFigure.load');
[pf,interface,options] = PoleFigure.load(fname,varargin{:});