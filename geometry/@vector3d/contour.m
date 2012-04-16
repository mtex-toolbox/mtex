function [ output_args ] = contour( v, varargin )
%CONTOUR Summary of this function goes here
%   Detailed explanation goes here




smooth(v,varargin{:},'contours',10,'LineStyle','-','LineColor','auto','fill','off')
