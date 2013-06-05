function varargout = pcolor(v,data,varargin )
% spherical contour plot
%
%% Syntax
%   pcolor(v,data)
%
%% Input
%  v - @vector3d
%  data - double
%
%% See also
% vector3d/plot vector3d/contourf

% where to plot
[ax,v,data,varargin] = splitNorthSouth(v,data,varargin{:},'pcolor');
if isempty(ax), return;end

% plot
[varargout{1:nargout}] = smooth(ax,v,data,'pcolor',varargin{:});
