function plotEllipse(grains,varargin)
% plot ellipses of principalcomponents
%
% Syntax
%  plotEllipse(grains)
%  plotEllipse(grains,'lineColor','w')
%  plotEllipse(grains,'hull')
%
% Input
%  grains - @grain
%
% Options
%  scale     - scalefactor of ellipsis 
%  hull      - consider convex hull
%  lineColor - colorspec
%
% See also
% grain2d/plot grainBoundary/plot grain2d/principalComponents
%

% compute ellipses
[omega,a,b] = principalComponents(grains,varargin{:});

% rescale axes length
scale = get_option(varargin,'scale',1);
a = a*scale; 
b = b*scale;  

% angle discretisation
phi = [linspace(0,2*pi,100),nan];  

% coordinates
[x,y] =  centroid(grains);
xx = (repmat(x,1,101) + cos(omega) .* a * sin(phi) - sin(omega) .* b * cos(phi)).';
yy = (repmat(y,1,101) + sin(omega) .* a * sin(phi) + cos(omega) .* b * cos(phi)).';

% plot
c = get_option(varargin,'lineColor','k');
h = optiondraw(line(xx(:),yy(:),'color',c),varargin);

% if no DisplayName is set remove from legend
if ~check_option(varargin,'DisplayName')
  set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
else
  legend('-DynamicLegend','location','NorthEast');
end