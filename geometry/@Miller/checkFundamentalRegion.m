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

[h0,h1,h2,h3,h4,N] = getFundamentalRegionPF(m.CS,varargin{:}); %#ok<*ASGLU>

ind = all(dot_outer(vector3d(m),N) >= -1e-6,2);
