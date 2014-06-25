function contour(v,data,varargin)
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
v.smooth(data,'contours',10,...
  'LineStyle','-','fill','off',varargin{:});
