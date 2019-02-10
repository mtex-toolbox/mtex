function [v,interface,options] = loadVector3d(fname,varargin)
% obsolete, use vector3d.load

warning('loadVector3d is depreciated. Please use instead vector3d.load');
[v,interface,options] = vector3d.load(fname,varargin{:});