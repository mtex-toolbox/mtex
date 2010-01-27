function plot3d(S2G,varargin)
% plot spherical data
%
% *S2G/plot* allows to plot data on the sphere in vary differnt kinds
%
%% Syntax
%  plot(S2G,<options>)
%
%% Input
%  S2G - @S2Grid
%
%% Options
%  DATA     - coloring of the points [double] or {string}
%  MarkerSize - diameter for single points plot [double]
%  RANGE    - minimum and maximum for color coding [min,max]
%
%% Flags
%  NORTH       - plot only points on the north hemisphere (default)
%  SOUTH       - plot only points on the southern hemisphere
%  DOTS        - single points (default) 
%  SMOOTH      - interpolated plot 
%  CONTOUR     - contour plot
%  EAREA       - equal-area projection (default)
%  EDIST       - equal-distance projection  
%  PLAIN       - no projection    
%  GRAY        - colormap - gray 
%  LOGARITHMIC - log plot
%
%% See also
% savefigure

% -------------------- GET OPTIONS ----------------------------------------

% data
data = reshape(get_option(varargin,'DATA',ones(1,numel(S2G))),...
  size(S2G));

% log plot? 
if check_option(varargin,'logarithmic')
  data = log(data);
  data(imag(data) ~= 0) = -inf;
end

% COLORMAP
if check_option(varargin,'GRAY'),colormap(flipud(colormap('gray'))/1.2);end

%% 3d plot
sphere3d(data.',-pi,pi,-pi/2,pi/2,10,1.5,'surf','spline',.001);
shading interp
c = caxis;
arrow3d(zeros(3),eye(3)*15,15,'cylinder',[0.15,0.15]);
caxis(c);
text(16,0,0,'x','FontSize',15)
text(0,16,0,'y','FontSize',15)
text(0,0,16,'z','FontSize',15)
set(gca,'position',[-0.3,-0.3,1.6,1.6]);
xlim([-15,15])
ylim([-15,15])
zlim([-15,15])
