function plotCustom(v,pcmd,varargin)
% draw custom graphics at directions in a spherical projection
%
% Syntax
%
%   plotCustom(v,{@(ax,x,y) drawCommand(ax,x,y)})   % call the command at the projection of every direction
%
% Input
%  v    - @vector3d
%  pcmd - cell holding a function handle @(ax,x,y), called with the axes and the projected coordinates
%
% See also
% vector3d/scatter vector3d/text

% initialize spherical plot
sP = newSphericalPlot(v,varargin{:});

for j = 1:numel(sP)

  % project data
  [x,y] = project(sP(j).proj,v,varargin{:});

  % plot custom
  for i = 1:length(x), pcmd{1}(sP(j).ax,x(i),y(i)); end

  % bring the axes labels in front of the custom graphics
  sP(j).doLabelsInFront;
end
