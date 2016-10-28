function varargout = contour(v,data,varargin)
% spherical contour plot
%
% Syntax
%   contour(v,data)
%
% Input
%  v - @vector3d
%  data - double
%
% Options
%  contours - number of contours
%
% See also
% vector3d/plot vector3d/contourf

% plot
[varargout{1:nargout}] = v.smooth(data,'contours',10,...
  'LineStyle','-','fill','off','linecolor','flat',varargin{:});
