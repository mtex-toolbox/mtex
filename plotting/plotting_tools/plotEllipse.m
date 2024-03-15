function plotEllipse(c,a,b,varargin)
% plot multiple ellipses
%
% Syntax
%
%   [a,b] = principalComponents(grains);
%   plotEllipse(grains.centroid,a,b,'lineColor','r')
%
% Input
%  c - center of the ellipse @vector3d
%  a,b - half axes of the ellipse @vector3d
%
% Options
%  lineColor - colorspec
%
% See also
% grain2d/plot grainBoundary/plot grain2d/principalComponents
%

% angle discretisation
phi = [linspace(0,2*pi,100),nan]; 

% ellipse discretisation
v = (a(:) * cos(phi) + b(:)*sin(phi) + c(:)).';

% plot
c = get_option(varargin,'lineColor','k');
varargin = delete_option(varargin,'lineColor');

if isnumeric(c) && numel(c)>3 % plot multiple ellipses with different colors

  for i = 1:size(c,1)
    h(i) = optiondraw(line(v.x(:,i),v.y(:,i),v.z(:,i),'color',c(i,:)),varargin{:});
    set(get(get(h(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
  end
  
else % plot only one object
  
  h = optiondraw(line(v.x(:),v.y(:),v.z(:),'color',c),varargin{:});

  % if no DisplayName is set remove from legend
  if ~check_option(varargin,'DisplayName')
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
  else
    legend('-DynamicLegend','location','NorthEast');
  end
  
% set plot to mtex plotting settings
setCamera default

end
