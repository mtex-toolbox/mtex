function plotEllipse(cxy,a,b,omega,varargin)
% plot multiple ellipses
%
% Syntax
%
%   [omega,a,b] = principalComponents(grains);
%   plotEllipse(grains.centroid,a,b,omega,'lineColor','r')
%
% Input
%  cxy - center of the ellipse 
%  a,b - length of the half axes
%  omega - orientation of the ellipse
%
% Options
%  lineColor - colorspec
%
% See also
% grain2d/plot grainBoundary/plot grain2d/principalComponents
%

% angle discretisation
phi = [linspace(0,2*pi,100),nan];  

% coordinates
x = (repmat(cxy(:,1),1,101) + cos(omega(:)) .* a(:) * sin(phi) - ...
  sin(omega(:)) .* b(:) * cos(phi)).';
y = (repmat(cxy(:,2),1,101) + sin(omega(:)) .* a(:) * sin(phi) + ...
  cos(omega(:)) .* b(:) * cos(phi)).';

% plot
c = get_option(varargin,'lineColor','k');
varargin = delete_option(varargin,'lineColor');

if isnumeric(c) && numel(c)>3 % plot multiple ellipses with different colors
  
  for i = 1:size(c,1)
    h(i) = optiondraw(line(x(:,i),y(:,i),'color',c(i,:)),varargin{:});
    set(get(get(h(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
  end
  
else % plot only one object

  h = optiondraw(line(x(:),y(:),'color',c),varargin{:});
  % if no DisplayName is set remove from legend
  if ~check_option(varargin,'DisplayName')
    set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
  else
    legend('-DynamicLegend','location','NorthEast');
  end


end

