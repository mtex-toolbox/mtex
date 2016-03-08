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

varargin = [m.CS.plotOptions,varargin];
h = surf@vector3d(m,cdata,varargin{:},m.CS);

if nargout == 0, clear h; end
