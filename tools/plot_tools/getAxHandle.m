function [ax,v,varargin] = getAxHandle(v,varargin)
% seperate axis handle from input

if ishandle(v)
  ax = {v};
  v = varargin{1};
  varargin(1) = [];
else
  ax = {};
end


