function h = plotSphericalGrid(ax,varargin)
% draw the meridians and small circles of a spherical grid in 3d
%
% The three dimensional counterpart of the polar grid @sphericalPlot draws
% on a projected plot. It is used by plotEmptySphere for the backdrop of a
% three dimensional scatter plot, and by vector3d/plot3d to lay a grid over
% a pole density function.
%
% Syntax
%
%   plotSphericalGrid(ax)
%   plotSphericalGrid(ax,'grid_res',10*degree)
%   plotSphericalGrid(ax,'radius',1.002)
%
% Input
%  ax - axes handle
%
% Options
%  grid_res  - angular spacing of the grid lines, default 15 degree
%  radius    - radius of the sphere the grid is drawn on, default 1
%  center    - center of that sphere, default the origin, @vector3d
%  gridColor - line color, default light gray
%
% Output
%  h - handles of the two line objects drawn
%
% See also
% plotEmptySphere vector3d/plot3d sphericalPlot

dgrid = get_option(varargin,'grid_res',15*degree);
r = get_option(varargin,'radius',1);
c = get_option(varargin,'center',vector3d(0,0,0));
if ~isa(c,'vector3d'), c = vector3d(0,0,0); end
color = get_option(varargin,'gridColor',[1 1 1] * 0.8);

opt = {'color',color,'parent',ax,'tag','sphericalGrid',...
  'handlevisibility','off'};

% the small circles - one line object holding all of them
th = -pi/2+dgrid:dgrid:pi/2-dgrid;
rh = linspace(0,2*pi,100);
[th,rh] = meshgrid(th,rh);
[x,y,z] = sph2cart(rh,th,r);

h = line(x + c.x, y + c.y, z + c.z, opt{:});

% the meridians - transposed, so that a line runs along a meridian and not
% around the sphere
rh = 0:dgrid:2*pi-dgrid;
th = linspace(-pi/2,pi/2,50);
[th,rh] = meshgrid(th,rh);
[x,y,z] = sph2cart(rh,th,r);

h = [h; line((x + c.x).', (y + c.y).', (z + c.z).', opt{:})];

if nargout == 0, clear h; end

end
