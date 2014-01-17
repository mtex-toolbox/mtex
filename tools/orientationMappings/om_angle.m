function [c,options] = om_angle(o,varargin)
% converts orientations to angle

c = angle(o) ./ degree;
options = {};