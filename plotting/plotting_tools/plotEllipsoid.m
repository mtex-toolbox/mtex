function h = plotEllipsoid(center,a,b,c,varargin)
% plot multiple ellipses
%
% Syntax
%
%   [a,b,c] = principalComponents(grains);
%   plotEllipsoid(grains.centroid,a,b,c,'faceColor','r')
%
% Input
%  center - center of the ellipsoid @vector3d
%  a,b,c  - half axes of the ellipsoid @vector3d
%
% Options
%  faceColor - colorspec
%
% See also
% grain3d/plot grain3d/centroid grain3d/principalComponents
%

color = get_option(varargin,'faceColor','lightblue');
varargin = delete_option(varargin,'faceColor',1);

% angle discretization
rho = linspace(0,2*pi,50);
theta = linspace(0,pi,20);
[theta,rho] = meshgrid(theta,rho);


holdSate = ishold;

h = gobjects(size(center));
for k = 1:length(center)
  
  v = center(k) + c(k) * sin(theta) .* cos(rho) + ...
    b(k) * sin(theta) .* sin(rho) + ...
    a(k) * cos(theta);
  
  if size(color,1) == length(center)
    localColor = color(k,:);
  else
    localColor = color;
  end

  h(k) = optiondraw(surf(v.x,v.y,v.z,'FaceColor',str2rgb(localColor),...
    'EdgeAlpha',0.25), varargin{:});
  h(k).Annotation.LegendInformation.IconDisplayStyle = 'off';
  hold on;

end
hold(holdSate);

axis equal tight
fcw
setCamera(plottingConvention.default3D)
  
end



