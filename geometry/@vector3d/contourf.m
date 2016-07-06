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

if nargin == 1, data = []; end

% in older matlab version we have to plot contour and countour lines
% seperately to avoid artefacts
if verLessThan('matlab','9.0')
 
  h = v.smooth(data,'contours',10,'LineStyle','none',varargin{:});

  h = [h,v.smooth(data,'contours',10,'fill','off','LineStyle','-','LineColor','k','hold',varargin{:})];
else
  h = v.smooth(data,'contours',10,'LineStyle','-','LineColor','k',varargin{:});
end

if nargout == 0, clear h; end

% TODO: data may not set
