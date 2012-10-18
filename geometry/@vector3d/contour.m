function varargout = contour( v, varargin )
% spherical contour plot
%
%% Syntax
%   contour(v,data)
%
%% Input
%  v - @vector3d
%  data - double
%
%% Options
%  contours - number of contours
%
%% See also
% vector3d/plot vector3d/contourf

[varargout{1:nargout}] = smooth(v,varargin{:},'contours',10,...
  'LineStyle','-','LineColor','auto','fill','off');
