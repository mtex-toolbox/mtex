function h = plot(tP,varargin)
% plot grain boundaries
%
% The function plots grain boundaries where the boundary is determined by
% the function <GrainSet.specialBoundary.html specialBoundary>
%
% Syntax
%   plot(grains.boundary)
%   plot(grains.innerBoundary,'linecolor','r')
%   plot(gB('Forsterite','Forsterite'),gB('Forsterite','Forsterite').misorientation.angle)
%
% Input
%  grains  - @grainBoundary
%  
% Options
%  linewidth
%  linecolor
%

hold on

plot(tP.V(:,1),tP.V(:,2),varargin{:});

hold off