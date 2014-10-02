function varargout = pcolor(v,data,varargin )
% spherical contour plot
%
% Syntax
%   pcolor(v,data)
%
% Input
%  v - @vector3d
%  data - double
%
% See also
% vector3d/plot vector3d/contourf

% plot
[varargout{1:nargout}] = smooth(v,data,'pcolor',varargin{:});
