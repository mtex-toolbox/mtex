function plotCustom(v,pcmd,varargin)
%
% Syntax
%   plotcustom(v,@(x,y) drawCommand(x,y))  %
%
% Input
%  v  - @vector3d
%  s  - string
%
% Options
%
% Output
%
% See also

% initialize spherical plot
sP = newSphericalPlot(v,varargin{:});

for j = 1:numel(sP)

  % project data
  [x,y] = project(sP(j).proj,v,varargin{:});

  % plot custom
  for i = 1:length(x), pcmd{1}(sP(j).hgt,x(i),y(i)); end
end
