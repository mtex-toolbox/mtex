function varargout = contourf( v, data, varargin )
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

if nargin == 1, data = []; end
if ischar(data)
  varargin = [data,varargin];
  data = [];
end

% in older matlab version we have to plot contour and countour lines
% seperately to avoid artefacts
if verLessThan('matlab','8.5')
 
  [varargout{1:nargout}] = v.smooth(data,'contours',10,'LineStyle','none',varargin{:});

  v.smooth(data,'contours',10,'fill','off','LineStyle','-','LineColor','k','hold',varargin{:});
else
  [varargout{1:nargout}] = v.smooth(data,'contours',10,'LineStyle','-','LineColor','k',varargin{:});
end

if nargout == 0, clear h; end

% TODO: data may not set
