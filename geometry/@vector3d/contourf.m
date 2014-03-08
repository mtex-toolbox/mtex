function contourf( v, data, varargin )
% spherical filled contour plot
%
% Syntax
%   contourf(v,data)
%
% Input
%  v - @vector3d
%  data - double
%
% Options
%  contours - number of contours
%
% See also
% vector3d/plot vector3d/contour

v.smooth(data,'contours',10,'LineStyle','none','fill','on',varargin{:});

v.smooth(data,'contours',10,'LineStyle','-','LineColor','k','fill','off','hold',varargin{:});

% TODO: data may not set
