function ind = checkFundamentalRegion(m,varargin)
% checks Miller indice to be within the fundamental region
%
% Syntax
%  ind = checkFundamentalRegion(m)
%
% Input
%  m - @Miller
%
% Output
%  ind - boolean
%
% Options
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]

sR = fundamentalSector(m.CS,varargin{:});

ind = sR.checkInside(vector3d(m));
