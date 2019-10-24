function varargout = fitEllipse(grains,varargin)
% fit ellipses to grains using the method described in Mulchrone&
% Choudhury,2004 (https://doi.org/10.1016/S0191-8141(03)00093-2)
% 
% Syntax
%
%   [omega,a,b] = fitEllipse(grains);
%   plotEllipse(grains.centroid,a,b,omega,'lineColor','r')
%
% Input:
%  grains   - @grain2d
%
% Output:
%  omega    - angle giving trend of ellipse long axis
%  a        - long axis radius
%  b        - short axis radius
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
% grains = grains(grains.grainSize>20)
% [omega,a,b] = fitEllipse(grains(grains));
% plotEllipse(grains.centroid,a,b,omega,'lineColor','w','linewidth',2)
% hold off

[varargout{1:nargout}] = principalComponents(grains,varargin{:});