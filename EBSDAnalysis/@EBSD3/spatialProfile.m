function [ebsd,distList] = spatialProfile(ebsd,line,varargin)
% select EBSD data along line segments
% 
% Syntax
%
%   ebsdLine = spatialProfile(ebsd,[xStart,xEnd],[yStart yEnd])
% 
%   [ebsdLine,dist] = spatialProfile(ebsd,x,y)
%
%   xy = ginput(2)
%   [ebsdLine,dist] = spatialProfile(ebsd,xy)
%
% Input
%  ebsd  - @EBSD
%  xStart, xEnd, yStart, yEnd - double
%  x, y  - coordinates of the line segments
%  xy - list of spatial coordinates |[x(:) y(:)]| 
%
% Output
%  ebsdLine - @EBSD restricted to the line of interest
%  dist - double distance along the line to the initial point
%
% Example


error('not yet implemented')

