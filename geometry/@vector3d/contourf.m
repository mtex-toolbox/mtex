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

if isnumeric(varargin{1})
  data = varargin(1);
  varargin(1) = [];
else
  data = {};
end


hold(ax,'all');

h1 = smooth(ax,v,data{:},'contours',10,'LineStyle','none','fill','on',varargin{:});
h2 = smooth(ax,v,data{:},'contours',10,'LineStyle','-','LineColor','k','fill','off',varargin{:});

hold(ax,'off');

% output
if nargout > 0
  varargout{1} = [h1,h2];
end
