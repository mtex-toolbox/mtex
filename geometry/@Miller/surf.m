function h = surf(m,cdata,varargin)
%
% Syntax
%
% Input
%
% Output
%
% Options
%
% See also
%

h = surf@vector3d(m,cdata,...
  'xAxisDirection','east','zAxisDirection','outOfPlane',varargin{:});

if nargout == 0, clear h; end
