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
%  lower       - plot only points on the upper hemisphere (default)
%  upper       - plot only points on the lower hemisphere
%  DOTS        - single points (default) 
%  SMOOTH      - interpolated plot 
%  CONTOUR     - contour plot
%  EAREA       - equal--area projection (default)
%  EDIST       - equal--distance projection  
%  PLAIN       - no projection    
%  LOGARITHMIC - log plot
%
%% See also
% savefigure

% -------------------- GET OPTIONS ----------------------------------------

% data
data = reshape(get_option(varargin,'DATA',ones(1,length(S2G))),...
  size(S2G));

% log plot? 
if check_option(varargin,'logarithmic')
  data = log(data);
  data(imag(data) ~= 0) = -inf;
end

data(isinf(data)) = NaN;

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
