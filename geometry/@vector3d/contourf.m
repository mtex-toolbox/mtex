function h = contourf( v, data, varargin )
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

h = v.smooth(data,'contours',10,'LineStyle','none','fill','on',varargin{:});

h = [h,v.smooth(data,'contours',10,'LineStyle','-','LineColor','k','fill','off','hold',varargin{:})];

if nargout == 0, clear h; end

% TODO: data may not set
