function varargout = contour(v,data,varargin )
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

% where to plot
[ax,v,data,varargin] = splitNorthSouth(v,data,varargin{:},'contour');
if isempty(ax), return;end

% plot
[varargout{1:nargout}] = smooth(ax,v,data,'contours',10,...
  'LineStyle','-','LineColor','auto','fill','off',varargin{:});
