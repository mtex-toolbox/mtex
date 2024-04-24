function [c,a,b] = fitEllipse(grains,varargin)
% fit ellipses to grains using the method described in Mulchrone&
% Choudhury,2004 (https://doi.org/10.1016/S0191-8141(03)00093-2)
% 
% Syntax
%
%   [c,a,b] = fitEllipse(grains);
%   plotEllipse(c,a,b,omega,'lineColor','r')
%
% Input:
%  grains   - @grain2d
%
% Output:
%  c - centroid
%  a - long axis
%  b - short axis
% 
% Options
%  boundary - scale to fit boundary length
%
% Example
%
% mtexdata csl
% grains = calcGrains(ebsd('indexed'))
% grains = smooth(grains,10)
% plot(ebsd('indexed'),ebsd('indexed').orientations,'micronbar','off')
% hold on
% plot(grains.boundary,'lineWidth',2)
% [c,a,b] = fitEllipse(grains(grains.grainSize>20));
% plotEllipse(c,a,b,'lineColor','w','lineWidth',2)
% hold off
%

c = grains.centroid;
[a,b] = principalComponents(grains,varargin{:});