function varargout = contourf( v, varargin )
% spherical filled contour plot
%
%% Syntax
%   contourf(v,data)
%
%% Input
%  v - @vector3d
%  data - double
%
%% Options
%  contours - number of contours
%
%% See also
% vector3d/plot vector3d/contour

% where to plot
[ax,v,varargin] = splitNorthSouth(v,varargin{:},'contourf');
if isempty(ax), return;end

hold(ax,'all');

% number of contour lines
cl = get_option(varargin,'contours',10);


h1 = smooth(ax,v,varargin{:},'contours',cl,'LineStyle','none','fill','on');
h2 = smooth(ax,v,varargin{:},'contours',cl,'LineStyle','-','LineColor','k','fill','off');

hold off

% output
if nargout > 0
  varargout{1} = [h1,h2];
end
