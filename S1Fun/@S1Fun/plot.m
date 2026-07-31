function h = plot(sF,varargin)
% plot a S1Fun
%
% Syntax
%   N = vector3d.Z; % normal direction
%   plotSection(sF,N) % plot in equator plane
%
%   theta = pi/3;   % polar angle 
%   plotSection(sF,N,theta) % plot small circle at 30 degree from the north pole
%
%   rho = linspace(0,pi); % azimuth angle
%   plotSection(sF,N,theta,rho) % plot half small circle at 30 degree
%
% Input
%  sF - @S1Fun
%
% Options
%  'notPolar' - plot in cartesian coordinates for x in [0,2\pi]
%
 
if check_option(varargin,{'notPolar','noPolar','cartesian'})
  M = 1e5;
  x = (0:M-1)/(M-1)*2*pi;
  y = sF.eval(x);
  h = plot(x,y);
  if nargout == 0, clear h; end
  return
end

omega = linspace(0,2*pi,361);

d = real(sF.eval(omega));

h = polarplot(omega,d,varargin{:});

% set plotting convention such that the plot coincides with a map
how2plot = getClass(varargin,'plottingConvention',plottingConvention.default);
how2plot.setView(h.Parent);

if nargout == 0, clear h; end

