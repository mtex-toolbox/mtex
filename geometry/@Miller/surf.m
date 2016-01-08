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

opt = m.plotOptions;
h = surf@vector3d(m,cdata,opt{:},varargin{:});

if nargout == 0, clear h; end
